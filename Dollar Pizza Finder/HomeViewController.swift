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
    
    // google map view
    @IBOutlet var map: GMSMapView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location

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
            self.addLocations(locations: locations)
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // if directions button is pressed
        if let vc = segue.destination as? DirectionsViewController
        {
            let place = self.map.selectedMarker?.userData as! Location
            
            vc.destination_name = place.placeId
        }
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get current location
        self.currentLocation = locations.last

        self.manager.stopUpdatingLocation() // stop updating location
        
    }
    
    // load locations from database onto google map
    func loadDatabase(completion: @escaping ([DataSnapshot]) -> ()) {
        // load locations snapshot from database
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.children.allObjects as! [DataSnapshot])
        })
    }
    
    // add locations from database to map while also checking for closest place
    func addLocations(locations: [Location]) {
        
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
        
        // init selected marker as closest place
        self.map.selectedMarker = closest
    }
    
    // look up place from place id in snapshot
    func getPlace(data: DataSnapshot, completion: @escaping (Place) -> ()) {
        let placeId = data.childSnapshot(forPath: "placeId").value as? String ?? ""
        GooglePlaces.lookUpPlace(placeId: placeId) { (place) -> () in
            completion(place)
        }
    }
    
    // add marker to google map and return marker
    func addMarker(location: Location) -> GMSMarker {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(location.lat, location.lng)
        marker.userData = location
        marker.map = self.map
        return marker
    }
    
    // get CLLocationCoordinate2D from place
    func getCoordinate(place: Place) -> CLLocationCoordinate2D {
        let coordinate = place.geometry.location
        return CLLocationCoordinate2DMake(coordinate.lat, coordinate.lng)
    }
    
    // called when marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.map.selectedMarker = marker
        
        return true
        
    }
    
    // add info window to marker when selected
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        
        self.map.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
        
        if let infoView = MapMarkerView.instanceFromNib() as? MapMarkerView {
            if let place = marker.userData as? Place {
                infoView.place = place
                infoView.loadUI()
            } else if let location = marker.userData as? Location {
                GooglePlaces.lookUpPlace(placeId: location.placeId) { (place) in
                    infoView.place = place
                    infoView.loadUI()
                    marker.userData = place
                }
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
    
    // action for phone button to call pizza place
    @IBAction func callLocation(_ sender: Any) {
        /*self.getCurrentPlace() { (place) -> () in
            let url = URL(string: "tel://\(self.getRawNum(input: place.phoneNumber!))")!
            self.openURL(url: url)
        }*/
    }
    
    // action for website button to open URL
    @IBAction func visitWebsite(_ sender: Any) {
        //self.getCurrentPlace() { (place) -> () in
        //    self.openURL(url: place.website!)
        //}
    }
    
    // Get Distance in Miles
    func distance(marker: GMSMarker) -> Double {
        let location = marker.userData as! Location
        return Double(self.currentLocation.distance(from: CLLocation(latitude: location.lat, longitude: location.lng)))
    }
    
    // only retrive digits from phone number
    func getRawNum(input: String) -> String {
        var output = ""
        for character in input {
            let char = String(character)
            if let num = Int(char) {
                output += char
            }
        }
        return output
    }
    
    // opens url
    func openURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}

