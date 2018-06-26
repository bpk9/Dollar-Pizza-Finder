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
import Alamofire

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    // google map view
    @IBOutlet var map: GMSMapView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location
    
    // Info for closest place
    @IBOutlet var closestName: UILabel!
    @IBOutlet var closestStars: UILabel!
    @IBOutlet var closestPic: UIImageView!
    @IBOutlet var directionsBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up location services
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        manager.requestWhenInUseAuthorization() // get permission
        self.manager.startUpdatingLocation()  // update current location
        
        
        // update UI
        self.getClosest() { (place) -> () in
            self.updateMap(place: place)
            self.updateInfo(place: place)
            self.updatePhoto(id: place.placeID)
            self.addDirections(destination: place.coordinate)
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO dispose of any resources that can be recreated.
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get current location
        self.currentLocation = locations.last

        self.manager.stopUpdatingLocation() // stop updating location
        
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
            
            for child in children.dropFirst() {
                let placeLat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let placeLon = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                let placeCoordinate = CLLocationCoordinate2D(latitude: placeLat, longitude: placeLon)
                let placeDistance = self.distance(location: placeCoordinate)
                if placeDistance < closestDistance {
                    let placeId = child.childSnapshot(forPath: "placeId").value as? String ?? ""
                    closestId = placeId
                    closestDistance = placeDistance
                }
            }
            
            // Loop up closest info by id
            GMSPlacesClient.shared().lookUpPlaceID(closestId, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                
                if let place = place {
                    completion(place)
                }
            })
        })
    }
    
    // update google map to be centered on coordinate
    func updateMap(place: GMSPlace) {
        
        // zoom to coordinate and show current location
        self.map.camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 10)
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
        self.closestStars.text = self.starString(rating: place.rating)
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
    
    // draw directions line on map
    func addDirections(destination: CLLocationCoordinate2D) {
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=driving&key=AIzaSyAsQrnM69UGzWJM_hgo8hceDo3ySc6as3w"
        
        Alamofire.request(url).responseJSON { response in
            
            if let res = response.result.value as? NSDictionary {
                if let routes = res["routes"] as? [NSDictionary] {
                    
                    for route in routes {
                        let overview = route["overview_polyline"] as? NSDictionary
                        let points = overview!["points"] as? String
                        let path = GMSPath(fromEncodedPath: points!)
                        
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = .red
                        polyline.strokeWidth = 10.0
                        polyline.map = self.map
                    }
                    
                }
            }
            
        }
    }
    
    // Directions button opens google maps
    @IBAction func directionsBtnAction(_ sender: Any) {
        self.getClosest(completion: { (place) -> () in
            self.openURL(url: URL(string: "https://www.google.com/maps/search/?api=1&query=\(place.coordinate.latitude),\(place.coordinate.longitude)&query_place_id=\(place.placeID)")!)
        })
    }
    
    // action for phone button to call pizza place
    
    @IBAction func callLocation(_ sender: Any) {
        self.getClosest() { (place) -> () in
            let url = URL(string: "tel://\(self.getRawNum(input: place.phoneNumber!))")!
            self.openURL(url: url)
        }
    }
    
    // action for website button to open URL
    @IBAction func visitWebsite(_ sender: Any) {
        self.getClosest() { (place) -> () in
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

