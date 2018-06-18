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
import GooglePlaces
import Firebase

class HomeViewController: UIViewController, MKMapViewDelegate,  CLLocationManagerDelegate {
    
    // Map on page
    @IBOutlet var map: MKMapView!
    
    // manages current location services
    let manager = CLLocationManager()
    var currentLocation: CLLocation! // current location

    // Info for closest place
    @IBOutlet var closestName: UILabel!
    @IBOutlet var closestStars: UILabel!
    @IBOutlet var closestPic: UIImageView!
    
    // Button
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var phoneBtn: UIButton!
    
    
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
        
        // get closest place
        self.getClosest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called after current location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get current location
        self.currentLocation = locations.last

        self.manager.stopUpdatingLocation() // stop updating location
        
    }
    
    func getClosest() {
        
        // set app status
        self.naviagating = false
        
        self.manager.startUpdatingLocation() // start updating location
        
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
                    
                    // Add Closest Location Pin to Map
                    let closestAnnotation = MKPointAnnotation()
                    closestAnnotation.title = place.name
                    closestAnnotation.subtitle = self.getSubtitle(address: place.addressComponents!)
                    closestAnnotation.coordinate = place.coordinate
                    self.map.addAnnotation(closestAnnotation)
                    
                    // get directions
                    let originItem = MKMapItem(placemark: MKPlacemark(coordinate: self.currentLocation.coordinate))
                    let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
                    
                    let directionRequest = MKDirectionsRequest()
                    directionRequest.source = originItem
                    directionRequest.destination = destinationItem
                    directionRequest.transportType = .walking
                    
                    // add directions to map
                    let directions = MKDirections(request: directionRequest)
                    directions.calculate(completionHandler: {
                        response, error in
                        
                        // get fastest route to pizza place
                        let bestRoute = response?.routes[0]
                        
                        // zoom to closest pizza place
                        let region = MKCoordinateRegion(center: place.coordinate, span: MKCoordinateSpanMake(0.005, 0.005))
                        self.map.setRegion(region, animated: true)
                        
                        // Update Location Info in App
                        self.closestName.text = place.name
                        self.closestStars.text = self.starString(number: Int(round(place.rating))) + String(format: " %.1f", place.rating)
                        self.directionsBtn.setTitle("Directions -- " + String(Int(bestRoute!.expectedTravelTime / 60)) + " mins " + self.getTransportType(type: bestRoute!.transportType), for: .normal)
                        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: closestId) { (photos, error) -> Void in
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
                        
                        
                    })
                    
                } else {
                    print("No place details")
                }
            })
            
        })
    }
    
    func navigate(destination: CLLocationCoordinate2D) {
        // update UI
        self.directionsBtn.setTitle("Stop Naviatng", for: .normal)
    }
    
    // add functionality to directions/back button
    @IBAction func directionsBtnAction(_ sender: Any) {
        
        // if the app is in navigation mode
        if self.naviagating {
            // find the nearest place
            self.naviagating = false
            self.getClosest()
        // if the app is in normal mode
        } else {
            // start naviation mode
            self.naviagating = true
            self.navigate(destination: map.annotations[2].coordinate)
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

    // open url specifically google maps app
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }

}

