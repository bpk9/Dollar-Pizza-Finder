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
    
    // manages geocoding for address
    let geocoder = CLGeocoder()
    
    // origin information
    var origin: CLLocationCoordinate2D!
    
    // destination information
    var destination_name: String! = ""
    var destination_address: String! = ""
    
    // step counter
    var step: Int!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // initialize buttons
        self.backBtn.isHidden = true
        self.nextBtn.setTitle("Start", for: .normal)
        self.nextBtn.backgroundColor = .blue
        
        // add title to view controller
        self.title = "Directions to " + destination_name
        
        // set up location services
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        self.manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        // initialize counter
        self.step = 0
        
        // find coordinates from street address
        self.getDestination() { (destination) -> () in
            
            // add destination pin to map
            let marker = GMSMarker()
            marker.position = destination
            marker.title = self.destination_name
            marker.map = self.map
            self.map.selectedMarker = marker
            
            // set up google directions
            let directions = GoogleDirections(origin: self.origin, destination: destination, mode: "transit")
            
            // add directions to map
            directions.addPolyline(map: self.map)
            
            // set info for overview
            directions.getDirections() { (route) -> () in
                
                self.directionsLabel.text = "Route to " + self.destination_name
                self.distanceLabel.text = route.legs.first?.distance.text
                self.durationLabel.text = route.legs.first?.duration.text
                
            }
            
        }
    }
    
    // fetches destination coordinate from address string
    func getDestination(completion: @escaping (CLLocationCoordinate2D) -> ()) {
        self.geocoder.geocodeAddressString(destination_address) { (placemarks, error) in
            completion((placemarks?.first?.location?.coordinate)!)
        }
    }
    
    // fetches directions
    func getDirections(completion: @escaping (GoogleDirections) -> ()) {
        self.getDestination() { (destination) -> () in
            completion(GoogleDirections(origin: self.origin, destination: destination, mode: "transit"))
        }
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // set origin
        self.origin = locations.first?.coordinate
        
        // enable location for google map
        self.map.isMyLocationEnabled = true
        
        // stop updating location
        self.manager.stopUpdatingLocation()
        
    }
    
    // when start/next button is tapped
    @IBAction func nextAction(_ sender: Any) {
        
        // if overview is showing then set up buttons for directions
        if self.step == 0 {
            self.backBtn.isHidden = false
            self.nextBtn.backgroundColor = .green
            self.nextBtn.setTitle("Next", for: .normal)
        }
        
        // update information
        self.setDirections(num: self.step)
        
        // increment step
        self.step = self.step + 1
        
    }
    
    // set directions info for given step
    func setDirections(num: Int) {
        self.getDirections() { (directions) -> () in
            directions.getSteps() { (steps) -> () in
                
                // get current step
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
                }
                // else show distance in miles
                else {
                    self.distanceLabel.text = step.distance.text
                }
                
                // update directions label and hide the next button on last step
                if self.step == steps.count {
                    self.directionsLabel.text = "Walk to " + self.destination_name
                    self.nextBtn.isHidden = true
                } else {
                    self.directionsLabel.text = step.html_instructions
                }
                
            }
        }
    }
    
}
