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
    
    // ui elements
    @IBOutlet var enableBtn: UIButton!
    
    var locationEnabled: Bool = false
    
    var manager = CLLocationManager()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoadingScreenViewController {
            vc.manager = self.manager
            vc.isInitialLaunch = true
        }
    }
    
    override func viewDidLoad() {
        self.enableBtn.layer.cornerRadius = 4
        
        self.manager.delegate = self
        self.manager.startUpdatingLocation()
    }
    
    // button to enable location services
    @IBAction func enableLocation(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            if let url = URL(string: "app-settings:root=Privacy&path=LOCATION") {
                // If general location settings are disabled then open general location settings
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
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
