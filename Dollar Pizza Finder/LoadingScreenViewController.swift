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
import GoogleMobileAds

class LoadingScreenViewController: UIViewController, GADInterstitialDelegate {
    
    // advertisement
    var ad: GADInterstitial!
    let adId: String = "ca-app-pub-"
    
    // loading bar
    @IBOutlet var progressBar: UIProgressView!
    
    // location manager
    var manager: CLLocationManager!
    
    // loaded places
    var allPlaces = [GMSMarker]()
    
    // initial launch
    var isInitialLaunch: Bool?
    
    // error bool
    var errorDidOccur: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                performSegue(withIdentifier: "loadingToLocation", sender: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                if self.ad == nil {
                    self.loadAd()
                }
                
                if self.manager == nil {
                    self.manager = CLLocationManager()
                    self.manager.startUpdatingLocation()
                }
                
                if self.progressBar.progress == 0 {
                    self.loadPlaces()
                }
                
            }
        } else {
            performSegue(withIdentifier: "loadingToLocation", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? HomeViewController {
                vc.allPlaces = self.allPlaces
                vc.userLocation = self.manager.location
                vc.isInitialLaunch = self.isInitialLaunch ?? false
            }
        }
    }
    
    // load data when location is updates
    func loadPlaces() {
        
        // get data
        FirebaseHelper.getData() { (place_ids) -> () in
            
            if let ids = place_ids {
                
                var count: Int = ids.count
                
                for id in ids {
                    GooglePlaces.getData(place_id: id) { (data) -> () in
                        
                        if let data = data {
                            
                            let place = data.place
                            let photo = data.photo.image
                            let photos = data.photo.data
                            
                            // load marker
                            let location = place.geometry.location
                            let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.lat, location.lng))
                            marker.userData = MarkerData(place: place, photo: Photo(image: photo, data: photos), routes: nil, directionsType: nil)
                            
                            // add to array
                            self.allPlaces.append(marker)
                            
                            // update progress
                            self.progressBar.progress = Float(self.allPlaces.count) / Float(ids.count)
                            
                            // if place is last signal lock
                            if self.allPlaces.count == count {
                                
                                // update progress
                                self.progressBar.progress = 1
                                
                                // segue to home
                                if self.ad.hasBeenUsed {
                                    self.performSegue(withIdentifier: "loadingToHome", sender: self)
                                }
                            }
                        } else {
                            print(id)
                            count -= 1
                        }
                        
                    }
                } // for loop
            } else {
                self.showError()
            }
            
        } // firebase
    } // func
    
    func showError() {
        if !self.errorDidOccur {
            self.errorDidOccur = true
            performSegue(withIdentifier: "loadingError", sender: self)
        }
        
    }
    
    func loadAd() {
        self.ad = GADInterstitial(adUnitID: self.adId)
        self.ad.delegate = self
        self.ad.load(GADRequest())
    }
    
    func showAd() {
        if self.ad.isReady {
            self.ad.present(fromRootViewController: self)
        } else {
            print("Ad not ready")
        }
    }
    
    // Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        self.showAd()
    }
    
    // ad request failed
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        self.showError()
    }
    
    // runs when ad is dismissed
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if self.progressBar.progress == 1 {
            self.performSegue(withIdentifier: "loadingToHome", sender: self)
        }
    }
    
}
