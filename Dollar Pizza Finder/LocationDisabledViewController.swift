//
//  LocationDisabledViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 8/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDisabledViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationEnabled: Bool = false
    
    var manager: CLLocationManager!
    
    // button to enable location services
    @IBAction func enableLocation(_ sender: Any) {
        self.manager.requestLocation()
        self.manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.locationEnabled {
            self.locationEnabled = true
            performSegue(withIdentifier: "locationToLoading", sender: nil)
        }
    }
    
}
