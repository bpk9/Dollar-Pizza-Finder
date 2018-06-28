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
    @IBOutlet var directionsTable: UITableView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation!
    
    // destination information
    var destination_name: String! = ""
    var destination_address: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add title to view controller
        self.title = "Directions to " + destination_name
        
        // set up location services
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        self.manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        // set up google map
        self.map.isMyLocationEnabled = true
        
        // find coordinates from street address
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(destination_address) { (placemarks, error) in
            
            // get destination coordinate
            let destination = (placemarks?.first?.location?.coordinate)!
            
            // add destination pin to map
            let marker = GMSMarker()
            marker.position = destination
            marker.title = self.destination_name
            marker.map = self.map
            self.map.selectedMarker = marker
            
            // add directions to map
            self.addDirections(destination: destination)
            
        }
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // update current location
        self.currentLocation = locations.last
        
    }
    
    // draw directions line on map
    func addDirections(destination: CLLocationCoordinate2D) {
        let directions = GoogleDirections(origin: currentLocation.coordinate, destination: destination, mode: "transit")
        directions.addPolyline(map: map)
    }
    
}
