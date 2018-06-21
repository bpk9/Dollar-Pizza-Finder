//
//  ViewController.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//  www.github.com/bpk9
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GooglePlaces

class HomeViewController: UIViewController, MKMapViewDelegate,  CLLocationManagerDelegate {
    
    // Map on page
    @IBOutlet var map: MKMapView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location
    
    var name: String = ""
    
    // Info for closest place
    @IBOutlet var closestName: UILabel!
    @IBOutlet var closestStars: UILabel!
    @IBOutlet var closestPic: UIImageView!
    @IBOutlet var directionsBtn: UIButton!
    
    // directions ststus
    var naviagating: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set up mapkit
        map.delegate = self
        map.showsUserLocation = true
        map.showsBuildings = true
        map.showsCompass = true
        map.showsPointsOfInterest = true
        map.showsScale = true
        
        // set up location services
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // get most accurate location
        manager.requestWhenInUseAuthorization() // get permission
        
        // update UI
        self.getClosest() { (place) -> () in
            self.updateInfo(place: place)
            self.updatePhoto(id: place.placeID)
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
        // get current location
        self.manager.startUpdatingLocation()
        
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
    
    // updates info on closest pizza place
    func updateInfo(place: GMSPlace) {
        self.closestName.text = place.name
        self.starString(number: Int(round(place.rating))) + String(format: " %.1f", place.rating)
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
    
    // TODO add functionality to directions/back button
    @IBAction func directionsBtnAction(_ sender: Any) {
        
    }
    
    // action for phone button to call pizza place
    @IBAction func callPlace(_ sender: Any) {
        self.getClosest() { (place) -> () in
            let url: NSURL = URL(string: "TEL://\(place.phoneNumber!)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // action for website button to open URL
    @IBAction func visitWebsite(_ sender: Any) {
        self.getClosest() { (place) -> () in
            UIApplication.shared.open(place.website!, options: [:], completionHandler: nil)
        }
    }
    
    // Add direction line to map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    // Get Distance in Miles
    func distance(location: CLLocationCoordinate2D) -> Double {
        return Double(self.currentLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude)) * 0.000621371)
    }
    
    // Converts star value to string
    func starString(number: Int) -> String {
        var output = String()
        for _ in 0..<number {
            output += "★"
        }
        return output
    }
    
    // get text for transformation type
    func getTransportType(type: MKDirectionsTransportType) -> String {
        if type == .walking {
            return "walking"
        } else if type == .transit {
            return "via subway"
        } else if type == .automobile {
            return "driving"
        } else {
            return "ERROR"
        }
    }
    
    func getSubtitle(address: [GMSAddressComponent]) -> String {
        return address[0].name + " " + address[1].name
    }

}

