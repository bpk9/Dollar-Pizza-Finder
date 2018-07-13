//
//  DirectionsViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 6/26/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//
import UIKit
import CoreLocation
import GoogleMaps

class DirectionsViewController: UIViewController, CLLocationManagerDelegate {
    
    // View Components
    @IBOutlet var map: GMSMapView!
    @IBOutlet var directionsLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var directionsPic: UIImageView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation!
    
    // destination information
    var data: MarkerData!
    
    // step counter
    var step: Int!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // add title to view controller
        self.title = "Directions to " + self.data.place.name
        
        // set up location services
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        self.manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        // initialize counter
        self.step = -1
        
        // add destination pin to map
        let marker = GMSMarker()
        let location = self.data.place.geometry.location
        marker.position = CLLocationCoordinate2DMake(location.lat, location.lng)
        marker.title = self.data.place.name
        marker.map = self.map
        self.map.selectedMarker = marker
        
        // set up ui
        self.setOverview()
        
        
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        // enable location for google map
        self.map.isMyLocationEnabled = true
        
        // stop updating location
        self.manager.stopUpdatingLocation()
        
    }
    
    // when start/next button is tapped
    @IBAction func nextAction(_ sender: Any) {
        
        // increment step
        self.step = self.step + 1
        
        // if overview is showing then set up buttons for directions
        if self.backBtn.isHidden {
            self.backBtn.isHidden = false
        }
        
        if self.nextBtn.currentTitle == "Start" {
            self.nextBtn.setTitle("Next", for: .normal)
            self.nextBtn.backgroundColor = .green
        }
        
        // update information
        self.setDirections(num: self.step)
        
    }
    
    // when back button is tapped
    @IBAction func backAction(_ sender: Any) {
        
        // decrement step
        self.step = self.step - 1
        
        // if next button is hidden then show it again
        if self.nextBtn.isHidden || self.nextBtn.currentTitle == "Start" {
            self.nextBtn.isHidden = false
            self.nextBtn.setTitle("Next", for: .normal)
            self.nextBtn.backgroundColor = .green
        }
        
        // if on initial step, revert to overview
        if self.step >= 0 {
            self.setDirections(num: self.step)
        } else {
            self.step = -1
            self.setOverview()
        }
        
        
    }
    
    // set info for overview
    func setOverview() {
        
        self.backBtn.isHidden = true
        self.nextBtn.backgroundColor = .blue
        self.nextBtn.setTitle("Start", for: .normal)
        
        self.directionsPic.image = UIImage(named: "Launch.png")
        
        self.addPolyline()
                
        self.directionsLabel.text = "Route to " + self.data.place.name
        self.distanceLabel.text = self.data.route!.legs.first?.distance.text
        self.durationLabel.text = self.data.route!.legs.first?.duration.text

    
    }
    
    // set directions info for given step
    func setDirections(num: Int) {
                
        // get current step
        let steps = self.data.route!.legs.first!.steps
        let step = steps[num]
                
        // zoom map to step
        let start = CLLocationCoordinate2DMake(step.start_location.lat, step.start_location.lng)
        let end = CLLocationCoordinate2DMake(step.end_location.lat, step.end_location.lng)
        self.map.moveCamera(GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: start, coordinate: end)))
                
        // update duration
        self.durationLabel.text = step.duration.text
        
        // if travel mode is transit show num of stops
        if step.travel_mode == "TRANSIT" {
            self.distanceLabel.text = String(step.transit_details!.num_stops) + " stops"
                    
            // try to set image for train line
            if let line = step.transit_details?.line.icon {
                self.setDirectionsPic(path: line)
            } else if let icon = step.transit_details?.line.vehicle.icon {
                self.setDirectionsPic(path: icon)
            } else {
                self.directionsPic.image = UIImage(named: "train-logo.png")
            }
            
        } else {
            self.distanceLabel.text = step.distance.text
            self.directionsPic.image = UIImage(named: "walking.png")
        }
        
        // update directions label and hide the next button on last step
        if self.step == (steps.count - 1) {
            self.directionsLabel.text = "Walk to " + self.data.place.name
            self.nextBtn.isHidden = true
        } else {
            self.directionsLabel.text = step.html_instructions
        }

    }
    
    func addPolyline() {
        // for each step in journey
        for step in self.data.route!.legs.first!.steps {
            
            // get polyline
            let path = GMSPath(fromEncodedPath: step.polyline.points)
            
            // add polyline to map
            let polyline = GMSPolyline(path: path)
            if let details = step.transit_details {
                
                // change polyline color for transit line
                if let color = step.transit_details?.line.color {
                    polyline.strokeColor = self.hexStringToUIColor(hex: color)
                } else {
                    polyline.strokeColor = .black
                }
                
                // add departure marker to map
                let start = step.start_location
                let departure = GMSMarker(position: CLLocationCoordinate2DMake(start.lat, start.lng))
                departure.title = details.departure_time.text + " from " + details.departure_stop.name
                departure.map = map
                
                // add arrival marker to map
                let end = step.end_location
                let arrival = GMSMarker(position: CLLocationCoordinate2DMake(end.lat, end.lng))
                arrival.title = details.arrival_stop.name + " at " + details.arrival_time.text
                arrival.map = map
                
                polyline.strokeWidth = 10.0
            } else {
                polyline.strokeColor = .gray
                polyline.strokeWidth = 5.0
            }
            polyline.map = self.map
            
        }
        
        self.updateCamera()
    }
    
    func setDirectionsPic(path: String) {
        let url = URL(string: "https:" + path)
        let data = try? Data(contentsOf: url!)
        self.directionsPic.image = UIImage(data: data!)
    }
    
    // update map camera to bounds
    func updateCamera() {
        let bounds = self.data.route!.bounds
        let update = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(bounds.northeast.lat, bounds.northeast.lng), coordinate: CLLocationCoordinate2DMake(bounds.southwest.lat, bounds.southwest.lng)))
        self.map.moveCamera(update)
    }
    
    // changes hex string to UI Color for polyline
    func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
