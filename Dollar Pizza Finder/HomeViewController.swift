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
    
    // UI elements
    @IBOutlet var map: GMSMapView!
    @IBOutlet var directionsBtn: UIButton!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location
    
    // all open pizza places
    var places = [GMSMarker]()
    
    // last selected place
    var lastData: MarkerData!

    
    // load data from firebase / google places
    override func loadView() {
        super.loadView()
        
        // lock method until data is finished loading
        DispatchQueue.global().async {
            let lock = DispatchSemaphore(value: 0)
            
            // get data
            FirebaseHelper.getData() { (place_ids) -> () in
                for id in place_ids {
                    GooglePlaces.lookUpPlace(place_id: id) { (place) -> () in
                        
                        // if place is open
                        if place.opening_hours!.open_now {
                            // add marker to map
                            let location = place.geometry.location
                            let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.lat, location.lng))
                            marker.userData = MarkerData(place: place, photo: nil, route: nil)
                            marker.map = self.map
                            self.places.append(marker)
                        }
                        
                        // if place is last signal lock
                        if id == place_ids.last {
                            lock.signal()
                        }
                    }
                }
            }
            
            // wait for signal
            lock.wait()
        }
    }
    
    // set up view
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
        
        // TODO highlight closest pizza place
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // if directions button is pressed
        if let vc = segue.destination as? DirectionsViewController
        {
            vc.data = self.lastData
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
        GooglePlaces.getData(place_id: location.placeId) { (place, photo) -> () in
            let data = MarkerData(place: place, photo: photo, route: nil)
            marker.userData = data
            self.lastData = data
            self.map.selectedMarker = marker
            self.updateButton(data: data)
        }
    }
    
    // called when marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        if let data = marker.userData as? MarkerData {
            self.lastData = data
            self.map.selectedMarker = marker
            self.updateButton(data: data)
        } else {
            self.updateMarker(marker: marker)
        }
        
        return true
        
    }
    
    // add info window to marker when selected
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        
        if let infoView = MapMarkerView.instanceFromNib() as? MapMarkerView {
            
            let data = self.map.selectedMarker?.userData as! MarkerData
            infoView.data = data
            infoView.loadUI()
            
            return infoView
            
        } else {
            return nil
        }
        
    }
    
    // call button action
    @IBAction func callPlace(_ sender: Any) {
        if let phoneNumber = self.lastData.place.formatted_phone_number {
            let url = URL(string: "tel://\(self.getRawNum(input: phoneNumber))")!
            self.openURL(url: url)
        } else {
            self.showAlert(title: "Phone Number Not Found", message: (self.lastData.place.name + " does not have a listed phone number"))
        }
    }
    
    // website button action
    @IBAction func visitWebsite(_ sender: Any) {
        if let website = self.lastData.place.website {
            self.openURL(url: URL(string: website)!)
        } else {
            self.showAlert(title: "Website Not Found", message: (self.lastData.place.name + " does not have a listed website"))
        }
    }
    
    // Get Distance in Miles
    func distance(marker: GMSMarker) -> Double {
        let location = marker.userData as! Location
        return Double(self.currentLocation.distance(from: CLLocation(latitude: location.lat, longitude: location.lng)))
    }
    
    // opens url
    func openURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // update button text
    func updateButton(data: MarkerData) {
        if let route = data.route {
            self.directionsBtn.setTitle("Directions -- " + route.legs.first!.duration.text, for: .normal)
        } else {
            let directions = GoogleDirections(origin: self.currentLocation.coordinate, destination: self.lastData.place.place_id, mode: "transit")
            directions.getDirections() { (route) -> () in
                var data = self.map.selectedMarker!.userData as! MarkerData
                data.route = route
                self.map.selectedMarker!.userData = data
                self.lastData = data
                self.directionsBtn.setTitle("Directions -- " + route.legs.first!.duration.text, for: .normal)
            }
        }
        
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

}

