//
//  ViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//  www.github.com/bpk9
//

import UIKit
import CoreLocation
import Firebase
import GoogleMaps

class HomeViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // ui elements
    @IBOutlet var map: GMSMapView!
    @IBOutlet var directionsBtn: UIButton!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location
    
    // last selected marker for directions
    var lastMarker: GMSMarker?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up location services
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        self.manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        // set up google map view
        self.map.delegate = self
        self.map.isMyLocationEnabled = true
        
        // load info from database
        FirebaseHelper.getData() { (locations) -> () in
            let closest = self.addLocations(locations: locations)
            self.map.camera = GMSCameraPosition.camera(withTarget: closest.position, zoom: 17)
            self.updateMarker(marker: closest)
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // if directions button is pressed
        if let vc = segue.destination as? DirectionsViewController
        {
            vc.origin = self.currentLocation.coordinate
            vc.data = self.lastMarker!.userData as! Place
        }
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get current location
        self.currentLocation = locations.last

        self.manager.stopUpdatingLocation() // stop updating location
        
    }
    
    // add locations from database to map while also checking for closest place
    func addLocations(locations: [Location]) -> GMSMarker {
        
        var closest: GMSMarker!
        
        // initialize closest marker as first place
        closest = self.addMarker(location: locations.first!)
        
        // if any other places are closer then have that be the selected marker
        for location in locations.dropFirst() {
            let marker = self.addMarker(location: location)
            if self.distance(marker: marker) < self.distance(marker: closest) {
                closest = marker
            }
        }
        
        return closest
    }
    
    // add marker to google map and return marker
    func addMarker(location: Location) -> GMSMarker {
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(location.lat, location.lng)
        marker.userData = location
        marker.map = self.map
        return marker
        
    }
    
    // look up place information and pic in google places
    func updateMarker(marker: GMSMarker) {
        
        let location = marker.userData as! Location
        GooglePlaces.lookUpPlace(placeId: location.placeId) { (place) -> () in
            marker.userData = place
            self.map.selectedMarker = marker
            self.lastMarker = marker
            self.updateButton()
        }
    }
    
    // called when marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        if ((marker.userData as? Place) != nil) {
            self.map.selectedMarker = marker
        } else {
            self.updateMarker(marker: marker)
        }
        
        return true
        
    }
    
    // add info window to marker when selected
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        
        if let infoView = MapMarkerView.instanceFromNib() as? MapMarkerView {
            
            let place = self.map.selectedMarker?.userData as! Place
            infoView.place = place
            infoView.loadUI()
            
            return infoView
            
        } else {
            return nil
        }
        
    }
    
    // Get Distance in Miles
    func distance(marker: GMSMarker) -> Double {
        let location = marker.userData as! Location
        return Double(self.currentLocation.distance(from: CLLocation(latitude: location.lat, longitude: location.lng)))
    }
    
    // update button text
    func updateButton() {
        
        let data = self.map.selectedMarker!.userData as! Place
        
        let directions = GoogleDirections(origin: self.currentLocation.coordinate, destination: data.place_id, mode: "transit")
        directions.getDirections() { (route) -> () in
            self.directionsBtn.setTitle("Directions -- " + route.legs.first!.duration.text, for: .normal)
        }
    }

}

