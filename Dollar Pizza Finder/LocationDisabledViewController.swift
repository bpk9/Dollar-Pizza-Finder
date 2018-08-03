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
    
    var manager = CLLocationManager()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoadingScreenViewController {
            vc.manager = self.manager
            vc.isInitialLaunch = true
        }
    }
    
    override func viewDidLoad() {
        self.manager.delegate = self
        self.manager.startUpdatingLocation()
    }
    
    // button to enable location services
    @IBAction func enableLocation(_ sender: Any) {
        self.manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.locationEnabled {
            self.locationEnabled = true
            performSegue(withIdentifier: "locationToLoading", sender: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
}
