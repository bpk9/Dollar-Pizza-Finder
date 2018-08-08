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

class LoadingScreenViewController: UIViewController, GADInterstitialDelegate, CLLocationManagerDelegate {
    
    // advertisement
    var ad: GADInterstitial!
    let adId: String = "ca-app-pub-3236969879330347/5694164055"
    
    // loading bar
    @IBOutlet var progressBar: UIProgressView!
    
    // location manager
    var manager: CLLocationManager?
    
    // loaded places
    var allPlaces = [GMSMarker]()
    
    // error bool
    var errorDidOccur: Bool = false
    
    override func loadView() {
        super.loadView()
        
        self.loadAd()
        self.loadPlaces()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? HomeViewController {
                vc.allPlaces = self.allPlaces
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
                                
                                if self.ad.hasBeenUsed && CLLocationManager.authorizationStatus() != .notDetermined {
                                    print("progress")
                                    self.segueHome()
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
        }
    }
    
    // Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if !self.ad.hasBeenUsed {
            self.showAd()
        }
    }
    
    // ad request failed
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.manager = CLLocationManager()
            self.manager?.delegate = self
            self.manager?.requestWhenInUseAuthorization()
        } else if self.progressBar.progress == 1 {
            print("fail")
            self.segueHome()
        }
    }
    
    // runs when ad is dismissed
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.manager = CLLocationManager()
            self.manager?.delegate = self
            self.manager?.requestWhenInUseAuthorization()
        } else if self.progressBar.progress == 1 {
            print("dismiss")
            self.segueHome()
        }
    }
    
    // runs when location setting changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if self.progressBar.progress == 1 && self.ad.hasBeenUsed && (status == .denied || status == .authorizedWhenInUse) {
            print("status changed")
            self.segueHome()
        }
    }
    
    // load location if enabled
    func segueHome() {
        performSegue(withIdentifier: "loadingToHome", sender: self)
    }
    
}
