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
import GooglePlaces

class HomeViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    // google map view
    @IBOutlet var map: GMSMapView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location
    
    // info for closest place
    @IBOutlet var closestName: UILabel!
    @IBOutlet var closestAddress: UILabel!
    @IBOutlet var closestStars: UILabel!
    @IBOutlet var closestPic: UIImageView!
    @IBOutlet var directionsBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up location services
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        self.manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        // set up google map view
        self.map.delegate = self
        
        // update UI
        self.getClosest() { (place) -> () in
            self.updateMap(place: place)
            self.updateUI(place: place)
        }
        
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // if directions button is pressed
        if let vc = segue.destination as? DirectionsViewController
        {
            vc.destination_name = self.closestName.text!
            vc.destination_address = self.closestAddress.text! + ", New York, NY"
        }
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get current location
        self.currentLocation = locations.last

        self.manager.stopUpdatingLocation() // stop updating location
        
    }
    
    // update up given a place
    func updateUI(place: GMSPlace) {
        self.updateInfo(place: place)
        self.updatePhoto(id: place.placeID)
    }
    
    // allows for access to closest pizza place
    func getClosest(completion: @escaping (GMSPlace) -> ()) {
        
        // Read Location Data from Database
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Database list of places
            let children = snapshot.children.allObjects as! [DataSnapshot]
            
            // Variable for closest pizza place initialized as first location in list
            var closestId = children[0].childSnapshot(forPath: "placeId").value as? String ?? ""
            let closestLat = children[0].childSnapshot(forPath: "latitude").value as? Double ?? 0.0
            let closestLong = children[0].childSnapshot(forPath: "longitude").value as? Double ?? 0.0
            var closestDistance = self.distance(location: CLLocationCoordinate2D(latitude: closestLat, longitude: closestLong))
            
            // add first marker to map
            let marker = GMSMarker()
            marker.title = String(children[0].key.split(separator: "-")[0])
            marker.position = CLLocationCoordinate2DMake(closestLat, closestLong)
            marker.map = self.map
            
            // loop through rest of places to see if any are closer
            for child in children.dropFirst() {
                
                // get info from database
                let placeLat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let placeLon = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let placeCoordinate = CLLocationCoordinate2D(latitude: placeLat, longitude: placeLon)
                let placeDistance = self.distance(location: placeCoordinate)
                
                // add marker to map
                let marker = GMSMarker()
                marker.title = String(child.key.split(separator: "-")[0])
                marker.position = CLLocationCoordinate2DMake(placeLat, placeLon)
                marker.map = self.map
                
                // check if its closer than the current closest place
                if placeDistance < closestDistance {
                    let placeId = child.childSnapshot(forPath: "placeId").value as? String ?? ""
                    closestId = placeId
                    closestDistance = placeDistance
                    self.map.selectedMarker = marker
                }
            }
            
            // Loop up closest info by id
            self.lookUpPlace(placeId: closestId) { (place) -> () in
                completion(place)
            }
        })
    }
    
    func lookUpPlace(placeId: String, completion: @escaping (GMSPlace) -> ()) {
        GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) -> Void in
                completion(place!)
        })
    }
    
    // update google map to be centered on coordinate
    func updateMap(place: GMSPlace) {
        
        // zoom to coordinate and show current location
        self.map.camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 12)
        self.map.isMyLocationEnabled = true
        
        // add pin to map
        let marker = GMSMarker()
        marker.position = place.coordinate
        marker.title = place.name
        marker.map = self.map
        
        // reveal marker info
        self.map.selectedMarker = marker
    }
    
    // updates info on closest pizza place
    func updateInfo(place: GMSPlace) {
        self.closestName.text = place.name
        
        let address = String(place.formattedAddress!.split(separator: ",")[0])
        self.closestAddress.text = address
        
        self.closestStars.text = self.starString(rating: place.rating)
        
        let directions = GoogleDirections(origin: self.currentLocation.coordinate, destination: place.coordinate, mode: "transit")
        directions.getDirections() { (route) -> () in
            let text = route.legs.first?.duration.text
            self.directionsBtn.setTitle("Directions -- " + text!, for: .normal)
        }
        
    }
    
    // updates photo for closest pizza place
    func updatePhoto(id: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: id) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            // TODO: handle the error.
                            print("Error: \(error.localizedDescription)")
                        } else {
                            self.closestPic.image = photo
                        }
                    })
                }
            }
        }
    }
    
    // called when marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        // show as selected
        self.map.selectedMarker = marker
        
        // find placeid in database
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
          
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                if marker.title == String(child.key.split(separator: "-")[0]) {
                    if Double(marker.position.latitude) == child.childSnapshot(forPath: "latitude").value as? Double && Double(marker.position.longitude) == child.childSnapshot(forPath: "longitude").value as? Double {
                        self.lookUpPlace(placeId: child.childSnapshot(forPath: "placeId").value as! String) { (place) -> () in
                            
                            self.updateUI(place: place)
                            
                        }
                    }
                }
                
            }
            
        })
        
        return true
        
    }
    
    // find placeid in database from name and address
    func getCurrentPlace(completion: @escaping (GMSPlace) -> ()) {
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let address = child.childSnapshot(forPath: "address").value as? String
                if self.closestAddress.text == String((address?.split(separator: ",")[0])!) {
                    self.lookUpPlace(placeId: child.childSnapshot(forPath: "placeId").value as! String) { (place) -> () in
                        completion(place)
                    }
                }
            
            }
        })
    }
    
    // action for phone button to call pizza place
    @IBAction func callLocation(_ sender: Any) {
        self.getCurrentPlace() { (place) -> () in
            let url = URL(string: "tel://\(self.getRawNum(input: place.phoneNumber!))")!
            self.openURL(url: url)
        }
    }
    
    // action for website button to open URL
    @IBAction func visitWebsite(_ sender: Any) {
        self.getCurrentPlace() { (place) -> () in
            self.openURL(url: place.website!)
        }
    }
    
    // Get Distance in Miles
    func distance(location: CLLocationCoordinate2D) -> Double {
        return Double(self.currentLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude)) * 0.000621371)
    }
    
    // Converts rating value to string with stars
    func starString(rating: Float) -> String {
        var output = String()
        for _ in 0 ..< Int(round(rating)) {
            output += "★"
        }
        return output + String(format: " %.1f", rating)
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

