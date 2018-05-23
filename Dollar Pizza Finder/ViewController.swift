//
//  ViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//  www.github.com/bpk9
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Mapkit Refrence
    @IBOutlet var map: MKMapView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D! // current location coordinate
    var currentLocation: CLLocation! // current location
    
    // Closest Pizza Place Walking from Current Location (Initialized to first location in database
    var closest: Location!

    // Info for closest place
    @IBOutlet var closestName: UILabel!
    @IBOutlet var closestStars: UILabel!
    @IBOutlet var closestPic: UIImageView!
    @IBOutlet var closestTime: UILabel!
    
    // Directions button
    @IBOutlet var directionsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set up mapkit
        map.delegate = self
        map.showsUserLocation = true
        map.showsBuildings = true
        map.showsCompass = true
        map.showsPointsOfInterest = true
        map.showsScale = true
        
        // set up location services
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        manager.requestWhenInUseAuthorization() // get permission
        manager.startUpdatingLocation() // start updating location
        currentCoordinate = manager.location!.coordinate // current location
        currentLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        
        var ref: DatabaseReference! //Database Reference
        ref = Database.database().reference()
        var locations = [Location]() // Location Data for Pizza Places
        
        // Read Location Data from Database
        ref.child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Create Location Objects and Add to Array
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let name = child.childSnapshot(forPath: "name").value as? String ?? "ERROR"
                let lat = child.childSnapshot(forPath: "lat").value as? Double ?? 0.0
                let long = child.childSnapshot(forPath: "long").value as? Double ?? 0.0
                let stars = child.childSnapshot(forPath: "stars").value as? Int ?? 0
                let imageUrl = child.childSnapshot(forPath: "imageUrl").value as? String ?? "https://www.cicis.com/media/1243/pizza_adven_zestypepperoni.png"
                let openTime = child.childSnapshot(forPath: "openTime").value as? Int ?? 0
                let closeTime = child.childSnapshot(forPath: "closeTime").value as? Int ?? 0
                locations += [Location(name: name, lat: lat, long: long, stars: stars, imageUrl: imageUrl, openTime: openTime, closeTime: closeTime)]
            }
            
            // Find Closest Pizza Place
            self.closest = locations.first!
            for location in locations.dropFirst() {
                location.distance = self.distance(location: location)
                if location.distance < self.closest.distance {
                    self.closest = location
                }
            }
            
            // Add Closest Location Pin to Map
            self.map.addAnnotation(Venue(location: self.closest))
            
            // get directions
            let originItem = MKMapItem(placemark: MKPlacemark(coordinate: self.currentCoordinate))
            let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: self.closest.coordinate))
            
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = originItem
            directionRequest.destination = destinationItem
            directionRequest.transportType = .walking
            
            // add directions to map
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: {
                response, error in
                
                let route = response?.routes[0]
                self.map.add(route!.polyline, level: .aboveRoads)
                
                let rect = route!.polyline.boundingMapRect
                var region = MKCoordinateRegionForMapRect(rect)
                region.span = MKCoordinateSpanMake(region.span.latitudeDelta + 0.001, region.span.longitudeDelta + 0.001)
                self.map.setRegion(region, animated: true)
            
                // Update Location Info in App
                self.closestName.text = self.closest.name
                self.closestStars.text = self.starString(number: self.closest.stars)
                self.directionsBtn.setTitle("Directions -- " + String(Int(route!.expectedTravelTime / 60)) + " mins walking", for: .normal)
                self.closestPic.setImageFromURl(stringImageUrl: self.closest.imageUrl)
                if self.closest.isOpen() {
                    self.closestTime.textColor = UIColor.green
                    self.closestTime.text = "OPEN until " + self.closest.getCloseTimeText()
                } else {
                    self.closestTime.textColor = UIColor.red
                    self.closestTime.text = "CLOSED until " + String(self.closest.openTime) + "AM"
                }
            })
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
    }
    
    // Get Distance in Miles
    func distance(location: Location) -> Float {
        return Float(currentLocation.distance(from: location.location) * 0.000621371)
    }
    
    // Add direction line to map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // Converts star value to string
    func starString(number: Int) -> String {
        var output = String()
        for _ in 0..<number {
            output += "★"
        }
        return output
    }
    
}

// Allows UIImageViews to be set using URL
extension UIImageView{
    
    func setImageFromURl(stringImageUrl url: String){
        
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
}
