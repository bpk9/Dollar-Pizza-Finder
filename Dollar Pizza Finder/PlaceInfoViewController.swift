//
//  PlaceInfoViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

class PlaceInfoViewController: UITableViewController {
    
    // ui elements
    @IBOutlet var directionsBtn: UIButton!
    
    // last known location of user
    var currentLocation: CLLocationCoordinate2D!
    
    // marker data
    var data: MarkerData!
    
    // load data for place when view appears
    override func viewWillAppear(_ animated: Bool) {
        
        let directions = GoogleDirections(origin: self.currentLocation, destination: self.data.place.place_id, mode: "transit")
        directions.getDirections() { (route) -> () in
            
            if let leg = route.legs.first {
                self.data.route = route
                self.directionsBtn.setTitle("Directions -- " + leg.duration.text, for: .normal)
            } else {
                print("Directions not Available")
            }
            
        }
        
    }
    
}
