//
//  LoadingScreen.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 8/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import CoreLocation.CLLocationManager
import GoogleMaps.GMSMarker

class LoadingScreenViewController: UIViewController {
    
    // loading bar
    @IBOutlet var progressBar: UIProgressView!
    
    // location manager
    var manager: CLLocationManager!
    
    // loaded places
    var allPlaces: [GMSMarker]!
    
    // initial launch
    var isInitialLaunch: Bool?
    
    override func viewDidAppear(_ animated: Bool) {
        
        // reset progress to 0
        self.progressBar.progress = 0
        
        // if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                performSegue(withIdentifier: "loadingToLocation", sender: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                self.manager = CLLocationManager()
                self.manager.startUpdatingLocation()
                self.loadPlaces()
            }
        } else {
            performSegue(withIdentifier: "loadingToLocation", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? HomeViewController {
                vc.allPlaces = self.allPlaces
                vc.userLocation = self.manager.location!
                vc.isInitialLaunch = self.isInitialLaunch ?? false
            }
        }
    }
    
    // load data when location is updates
    func loadPlaces() {
        
        self.allPlaces = [GMSMarker]()
        
        // get data
        FirebaseHelper.getData() { (place_ids) -> () in
            
            for id in place_ids {
                GooglePlaces.getData(place_id: id) { (place, photo, photos) -> () in
                    
                    // load marker
                    let location = place!.geometry.location
                    let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.lat, location.lng))
                    marker.userData = MarkerData(place: place!, photo: Photo(image: photo!, data: photos!), routes: nil, directionsType: nil)
                    
                    // add to array
                    self.allPlaces.append(marker)
                    
                    // update progress
                    self.progressBar.progress = Float(self.allPlaces.count) / Float(place_ids.count)
                    
                    // if place is last signal lock
                    if place!.place_id == place_ids.last {
                        
                        // update progress
                        self.progressBar.progress = 1
                        
                        // segue to home
                        self.performSegue(withIdentifier: "loadingToHome", sender: self)
                    }
                    
                }
            }
        }
    }
    
}
