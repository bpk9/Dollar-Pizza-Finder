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
    
    // location manager
    var locationManager: CLLocationManager?
    
    // all pizza places in database
    var allPlaces = [GMSMarker]()
    var openPlaces: [GMSMarker]!
    var closedPlaces: [GMSMarker]!
    
    // setting for only open places
    var onlyOpen: Bool = UserDefaults.standard.value(forKey: "onlyOpen") as? Bool ?? true
    
    // setting changed
    var didChangeOpenOnly: Bool = false
    var didChangeSorting: Bool = false
    
    // info launcher
    var infoLauncher: InfoLauncher!
    
    // search bar
    var searchSuggestions: SearchSuggestions!
    
    // directions mode
    var directionsMode: String = "transit"
    
    // load data from firebase / google places
    override func loadView() {
        super.loadView()
        
        // extend map view to bottom of screen
        let oldFrame = self.map.superview!.frame
        self.map.superview!.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: UIApplication.shared.keyWindow!.frame.height - oldFrame.origin.y)
        
        // lock to sync data loading
        var count: Int = 0
        
        // get data
        FirebaseHelper.getData() { (place_ids) -> () in
            for id in place_ids {
                GooglePlaces.getData(place_id: id) { (place, photo, photos) -> () in
                    
                    // load marker
                    let location = place!.geometry.location
                    let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.lat, location.lng))
                    marker.userData = MarkerData(place: place!, photo: Photo(image: photo!, data: photos!), routes: nil, directionsType: nil)
                        
                    // if place is open
                    let openNow = place!.opening_hours?.open_now ?? false
                    if  openNow || self.onlyOpen == false {
                        marker.map = self.map
                    }
                        
                    // add to array
                    self.allPlaces.append(marker)
                    
                    // increment counter
                    count += 1
                    
                    // if place is last signal lock
                    if count == place_ids.count {
                        // sort places by settings selection
                        self.sortMarkers()
                        
                        // select first pizza place
                        if self.onlyOpen {
                            self.map.selectedMarker = self.openPlaces.first
                        } else {
                            self.map.selectedMarker = self.allPlaces.first
                        }
                        
                        // zoom camera to first place
                        self.map.moveCamera(GMSCameraUpdate.setTarget(self.map.selectedMarker!.position))
                        self.map.animate(toZoom: 18)
                        self.map.animate(toViewingAngle: 20)
                        
                        // set up search bar
                        self.searchSuggestions = SearchSuggestions(map: self.map, markers: self.allPlaces, navBarHeight: self.navigationController!.navigationBar.intrinsicContentSize.height)
                        self.searchSuggestions.delegate = self
                    }
                    
                }
            }
        }
        
        // set up info view
        self.infoLauncher = InfoLauncher(map: self.map)
        self.infoLauncher.infoView.delegate = self
        
    }
    
    // set up ui when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up google map view
        self.map.delegate = self
        self.map.isMyLocationEnabled = true
        self.map.camera = GMSCameraPosition.camera(withLatitude: 40.7831, longitude: -73.9712, zoom: 8)
    }
    
    // show info when view appears if marker is selected
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // reselect marker and show info view
        if self.didChangeOpenOnly || self.didChangeSorting {
            if self.onlyOpen {
                self.map.selectedMarker = self.openPlaces.first
            } else {
                self.map.selectedMarker = self.allPlaces.first
            }
            self.map.moveCamera(GMSCameraUpdate.setTarget(self.map.selectedMarker!.position))
            self.didChangeSorting = false
            self.didChangeOpenOnly = false
        }
        
        if self.map.selectedMarker != nil && !self.infoLauncher.isVisible {
            self.infoLauncher.showInfo()
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // send places array to search
       if let vc = segue.destination as? PlaceInfoViewController {
            vc.currentLocation = self.map.myLocation!
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
        
        if self.searchSuggestions.isVisible {
            self.searchSuggestions.hideSearch()
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
        
        self.onlyOpen = onlyOpen
        self.didChangeOpenOnly = true
    }
    
    // update markers when sorting is changed in settings
    func didChangePlacesSorting() {
        self.sortMarkers()
        self.searchSuggestions.updateCells(markers: self.allPlaces)
        self.didChangeSorting = true
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
    
    // Get Distance in Miles
    func distance(marker: GMSMarker) -> Double {
        let data = marker.userData as! MarkerData
        let location = data.place.geometry.location
        
        // get location permission if needed
        if !CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager!.requestLocation()
        }
        
        return Double(self.map.myLocation!.distance(from: CLLocation(latitude: location.lat, longitude: location.lng)))
    }
    
    // sort markers by settings selection
    func sortMarkers() {
        // sort all markers
        let sorting = UserDefaults.standard.value(forKey: "sorting") as? Int ?? 0
        switch sorting {
        case 0:
            // sort by distance
            self.allPlaces.sort(by: { self.distance(marker: $0) < self.distance(marker: $1) })
        case 1:
            // sort by rating
            self.allPlaces.sort(by: { ($0.userData as! MarkerData).place.rating > ($1.userData as! MarkerData).place.rating })
        default:
            // sort by name
            self.allPlaces.sort(by: { ($0.userData as! MarkerData).place.name < ($1.userData as! MarkerData).place.name })
        }
        
        // seperate markers into open and closed
        self.openPlaces = []
        self.closedPlaces = []
        for marker in self.allPlaces {
            let data = marker.userData as! MarkerData
            let openNow = data.place.opening_hours?.open_now ?? false
            if openNow {
                self.openPlaces.append(marker)
            } else {
                self.closedPlaces.append(marker)
            }
        }
    }

}

