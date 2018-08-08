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

class HomeViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, InfoDelegate, SearchDelegate, SettingsDelegate, PlaceInfoDelegate {
    
    // UI elements
    @IBOutlet var map: GMSMapView!
    
    // location manager
    var manager: CLLocationManager?
    
    // all pizza places in database
    var allPlaces: [GMSMarker]!
    var openPlaces: [GMSMarker]!
    var closedPlaces: [GMSMarker]!
    
    // setting for only open places
    var onlyOpen: Bool = UserDefaults.standard.value(forKey: "onlyOpen") as? Bool ?? true
    
    // setting changed
    var didChangeOpenOnly: Bool = false
    var didChangeSorting: Bool = false
    var locationFound: Bool = false
    
    // info launcher
    var infoLauncher: InfoLauncher!
    
    // search bar
    var searchSuggestions: SearchSuggestions!
    
    // load data from firebase / google places
    override func loadView() {
        super.loadView()
        
        // extend map view to bottom of screen
        let oldFrame = self.map.superview!.frame
        self.map.superview!.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: UIApplication.shared.keyWindow!.frame.height - oldFrame.origin.y)
        
    }
    
    // set up ui when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up google map view
        self.map.delegate = self
        self.map.isMyLocationEnabled = true
        self.map.camera = GMSCameraPosition.camera(withLatitude: 40.7831, longitude: -73.9712, zoom: 8)
        
        // set up info launcher
        self.infoLauncher = InfoLauncher(map: self.map)
        self.infoLauncher.infoView.delegate = self
        
        // load markers
        self.loadPlaces()
    }
    
    // show info when view appears if marker is selected
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // set up location manager
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if self.manager == nil {
                self.manager = CLLocationManager()
                self.manager?.delegate = self
                self.manager?.startUpdatingLocation()
            }
            
            // if directions not avaiable
            if self.infoLauncher.isVisible && self.infoLauncher.infoView.directionsBtn.alpha == 0.5 {
                self.infoLauncher.updateInfo()
            }
            
            // if distance is hidden
            if self.searchSuggestions.markers.first?.distance.isHidden ?? true {
                self.searchSuggestions.resetCells()
            }
        }
        
        // reselect marker and show info view
        if self.didChangeOpenOnly || self.didChangeSorting {
            
            self.selectFirstPlace()
            if let marker = self.map.selectedMarker {
                self.map.moveCamera(GMSCameraUpdate.setTarget(marker.position))
            } else {
                performSegue(withIdentifier: "homeError", sender: self)
            }
            
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
            if let userLocation = self.manager?.location {
                vc.currentLocation = userLocation
            }
            vc.data = self.map.selectedMarker?.userData as! MarkerData
            vc.delegate = self
        } else if let vc = segue.destination as? DirectionsViewController {
            vc.data = self.map.selectedMarker?.userData as! MarkerData
        } else if let vc = segue.destination as? SettingsViewController {
            if vc.delegate == nil {
                vc.delegate = self
            }
        }
        
        if self.infoLauncher != nil {
            if self.infoLauncher.isVisible {
                self.infoLauncher.hideInfo()
            }
        }
        
        if self.searchSuggestions != nil {
            if self.searchSuggestions.isVisible {
                self.searchSuggestions.hideSearch()
            }
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
    
    // update info launcher when location is enabled
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.locationFound {
            if locations.last != nil {
                self.locationFound = true
                self.infoLauncher.updateInfo()
                self.searchSuggestions.resetCells()
                let sorting = UserDefaults.standard.value(forKey: "sorting") as? Int ?? 1
                if sorting == 0 {
                    self.didChangePlacesSorting()
                    self.selectFirstPlace()
                    if let marker = self.map.selectedMarker {
                        self.map.moveCamera(GMSCameraUpdate.setTarget(marker.position))
                        if !self.infoLauncher.isVisible {
                            self.infoLauncher.showInfo()
                        }
                        self.infoLauncher.updateInfo()
                    } else {
                        performSegue(withIdentifier: "homeError", sender: self)
                    }
                    
                    self.didChangeSorting = false
                }
            }
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
    func distance(userLocation: CLLocation, marker: GMSMarker) -> Double {
        let data = marker.userData as! MarkerData
        let location = data.place.geometry.location
        
        return Double(userLocation.distance(from: CLLocation(latitude: location.lat, longitude: location.lng)))
    }
    
    // load places from array
    func loadPlaces() {
        
        // load markers
        for marker in self.allPlaces {
            let data = marker.userData as! MarkerData
            
            // if place is open
            let openNow = data.place.opening_hours?.open_now ?? false
            if  !self.onlyOpen || openNow {
                marker.map = self.map
            }
            
        }
        
        // sort places by settings selection
        self.sortMarkers()
        
        // select first pizza place
        self.selectFirstPlace()
        
        // set up search bar
        self.searchSuggestions = SearchSuggestions(map: self.map, markers: self.allPlaces, navBarHeight: self.navigationController!.navigationBar.intrinsicContentSize.height)
        self.searchSuggestions.delegate = self
        
        // zoom camera to first place
        if let marker = self.map.selectedMarker {
            self.map.moveCamera(GMSCameraUpdate.setTarget(marker.position))
            self.map.animate(toZoom: 18)
            self.map.animate(toViewingAngle: 30)
        } else {
            print("no selected marker")
            performSegue(withIdentifier: "homeError", sender: self)
        }
        
        
        
    }
    
    // sort markers by settings selection
    func sortMarkers() {
        // sort all markers
        let sorting = UserDefaults.standard.value(forKey: "sorting") as? Int ?? 1
        switch sorting {
        case 0:
            if let userLocation = self.manager?.location {
                // sort by distance
                self.allPlaces.sort(by: { self.distance(userLocation: userLocation, marker: $0) < self.distance(userLocation: userLocation, marker: $1) })
            } else {
                // sort by rating
                self.allPlaces.sort(by: { ($0.userData as! MarkerData).place.rating > ($1.userData as! MarkerData).place.rating })
            }
            
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
    
    func selectFirstPlace() {
        if self.onlyOpen {
            if let firstPlace = self.openPlaces.first {
                self.map.selectedMarker = firstPlace
            } else {
                UserDefaults.standard.set(false, forKey: "onlyOpen")
                self.didChangeOnlyOpen(onlyOpen: false)
                self.map.selectedMarker = self.allPlaces.first
            }
        } else {
            self.map.selectedMarker = self.allPlaces.first
        }
    }
    
    // updates marker data with loaded photos
    func updateMarkerPhotos(_ data: MarkerData) {
        // save photo data
        if self.map.selectedMarker != nil {
            if let index = self.allPlaces.index(of: self.map.selectedMarker!) {
                self.allPlaces[index].userData = data
            }
            if let index = self.openPlaces.index(of: self.map.selectedMarker!) {
                self.openPlaces[index].userData = data
            } else if let index = self.closedPlaces.index(of: self.map.selectedMarker!) {
                self.closedPlaces[index].userData = data
            }
            self.map.selectedMarker?.userData = data
        }
    }

}

