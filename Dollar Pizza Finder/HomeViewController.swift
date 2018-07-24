//
//  ViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//  www.github.com/bpk9
//

import UIKit
import CoreLocation.CLLocation
import Firebase
import GoogleMaps

class HomeViewController: UIViewController, GMSMapViewDelegate, InfoDelegate, SearchDelegate, SettingsDelegate {
    
    // UI elements
    @IBOutlet var map: GMSMapView!
    
    // all open pizza places
    var places = [GMSMarker]()
    
    // all closed pizza places
    var closedPlaces = [GMSMarker]()
    
    // info launcher
    var infoLauncher: InfoLauncher!
    
    // search bar
    var searchSuggestions: SearchSuggestions!
    
    // directions mode
    var directionsMode: String = "transit"
    
    // load data from firebase / google places
    override func loadView() {
        super.loadView()
        
        // lock to sync data loading
        var count: Int = 0
        
        // get data
        FirebaseHelper.getData() { (place_ids) -> () in
            for id in place_ids {
                GooglePlaces.getData(place_id: id) { (place, photo, photos) -> () in
                    
                    // load marker
                    let location = place.geometry.location
                    let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.lat, location.lng))
                    marker.userData = MarkerData(place: place, photo: Photo(image: photo, data: photos), route: nil)
                    
                    // if place is open
                    if place.opening_hours!.open_now {
                        marker.map = self.map
                        self.places.append(marker)
                    } else {
                        let onlyOpen = UserDefaults.standard.value(forKey: "onlyOpen") as? Bool ?? true
                        if onlyOpen == false {
                            marker.map = self.map
                        }
                        self.closedPlaces.append(marker)
                    }
                    
                    // increment counter
                    count += 1
                    
                    // if place is last signal lock
                    if count == place_ids.count {
                        // sort places by distance
                        self.places.sort(by: { self.distance(marker: $0) < self.distance(marker: $1) })
                        
                        // select closest pizza place
                        self.map.selectedMarker = self.places.first
                        
                        // zoom camera to closest place
                        self.map.moveCamera(GMSCameraUpdate.setTarget(self.map.selectedMarker!.position))
                        self.map.animate(toZoom: 14)
                        
                        // set up search bar
                        self.searchSuggestions = SearchSuggestions(map: self.map, markers: self.places + self.closedPlaces, navBarHeight: self.navigationController!.navigationBar.intrinsicContentSize.height)
                        self.searchSuggestions.delegate = self
                    }
                }
            }
        }
        
        // extend map view to bottom of screen
        let oldFrame = self.map.superview!.frame
        self.map.superview!.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: UIApplication.shared.keyWindow!.frame.height - oldFrame.origin.y)
        
        // set up google map view
        self.map.delegate = self
        self.map.isMyLocationEnabled = true
        self.map.camera = GMSCameraPosition.camera(withLatitude: 40.7831, longitude: -73.9712, zoom: 8)
        
        // set up info view
        self.infoLauncher = InfoLauncher(map: self.map)
        self.infoLauncher.infoView.delegate = self
        
    }
    
    // show info when view appears if marker is selected
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedMarker = self.map.selectedMarker {
            if self.closedPlaces.contains(selectedMarker) {
                self.map.selectedMarker = self.places.first
            }
            self.infoLauncher.showInfo()
        }
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // send places array to search
       if let vc = segue.destination as? PlaceInfoViewController {
            vc.currentLocation = self.map.myLocation!.coordinate
            vc.data = self.map.selectedMarker?.userData as! MarkerData
        } else if let vc = segue.destination as? DirectionsViewController {
            vc.data = self.map.selectedMarker?.userData as! MarkerData
       } else if let vc = segue.destination as? SettingsViewController {
            if vc.delegate == nil {
                vc.delegate = self
            }
        }
        
        if self.infoLauncher.isVisible {
            self.infoLauncher.hideInfo()
        }
        
    }
    
    // add info when marker is selected
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        
        // show info launcher
        if !self.infoLauncher.isVisible {
            self.infoLauncher.showInfo()
        }
        self.infoLauncher.updateInfo()
        
        // load info marker
        if let infoView = MapMarkerView.instanceFromNib() as? MapMarkerView {
            
            infoView.loadUI(data: marker.userData as! MarkerData)
            
            return infoView
            
        } else {
            return nil
        }
        
    }
    
    // show more place info when info marker is tapped
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: "placeInfo", sender: nil)
    }
    
    // hide info or search when map is tapped
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if self.infoLauncher.isVisible {
            self.infoLauncher.hideInfo()
        }
        
    }
    
    // show search bar when button is tapped
    @IBAction func showSearchBar(_ sender: Any) {
        if !self.searchSuggestions.isVisible {
            self.searchSuggestions.showSearch()
        }
    }
    
    // refresh route if directions mode setting is changed
    func didChangeDirectionsMode() {
        if self.map.selectedMarker != nil {
            self.infoLauncher.updateInfo()
        }
    }
    
    // add or remove closed markers from map and search when setting is changes
    func didChangeOnlyOpen(onlyOpen: Bool) {
        if onlyOpen == true {
            for marker in self.closedPlaces {
                marker.map = nil
            }
        } else {
            for marker in self.closedPlaces {
                marker.map = self.map
            }
        }
    }
    
    // add bar to title view
    func showBar(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = searchBar
    }
    
    // remove bar from title view
    func hideBar() {
        self.navigationItem.titleView = nil
    }
    
    // go to directions view when directions button is tapped
    func runSegue(_ identifier: String) {
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    // call button action
    /*@IBAction func callPlace(_ sender: Any) {
        if let phoneNumber = self.lastData.place.formatted_phone_number {
            let url = URL(string: "tel://\(self.getRawNum(input: phoneNumber))")!
            self.openURL(url: url)
        }
    }
    
    // website button action
    @IBAction func visitWebsite(_ sender: Any) {
        if let website = self.lastData.place.website {
            self.openURL(url: URL(string: website)!)
        }
    }*/
    
    // Get Distance in Miles
    func distance(marker: GMSMarker) -> Double {
        let data = marker.userData as! MarkerData
        let location = data.place.geometry.location
        return Double(self.map.myLocation!.distance(from: CLLocation(latitude: location.lat, longitude: location.lng)))
    }
    
    // opens url
    func openURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // only retrive digits from phone number
    func getRawNum(input: String) -> String {
        var output = ""
        for character in input {
            let char = String(character)
            if Int(char) != nil {
                output += char
            }
        }
        return output
    }

}

