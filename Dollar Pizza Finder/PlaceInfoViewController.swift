//
//  PlaceInfoViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

class PlaceInfoViewController: UIViewController {
    
    // ui elements
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var navItem: UINavigationItem!
    
    // last known location of user
    var currentLocation: CLLocationCoordinate2D!
    
    // marker data
    var data: MarkerData!
    
    // load data for place when view appears
    override func viewWillAppear(_ animated: Bool) {
        
        // set title to name of place
        self.navItem.title = self.data.place.name
        
        // update button text if route exists
        if let leg = self.data.routes!.first!.legs.first {
            self.directionsBtn.setTitle("Directions -- " + leg.duration.text, for: .normal)
        } else {
            self.directionsBtn.isHidden = true
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let vc = segue.destination as? DirectionsViewController {
            vc.data = self.data
        }
    
    }
    
}
