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

class HomeViewController: UIViewController, GMSMapViewDelegate, InfoDelegate {
    
    // UI elements
    @IBOutlet var map: GMSMapView!
    @IBOutlet var directionsBtn: UIButton!
    @IBOutlet var callBtn: UIButton!
    @IBOutlet var websiteBtn: UIButton!
    
    // all open pizza places
    var places = [GMSMarker]()
    
    // info launcher
    var infoLauncher: InfoLauncher!
    
    // load data from firebase / google places
    override func loadView() {
        super.loadView()
        
        // lock method until data is finished loading
        DispatchQueue.global().async {
            let lock = DispatchSemaphore(value: 0)
            
            // get data
            FirebaseHelper.getData() { (place_ids) -> () in
                for id in place_ids {
                    GooglePlaces.getData(place_id: id) { (place, photo, photos) -> () in
                        
                        // if place is open
                        if place.opening_hours!.open_now {
                            // add marker to map
                            let location = place.geometry.location
                            let marker = GMSMarker(position: CLLocationCoordinate2DMake(location.lat, location.lng))
                            marker.userData = MarkerData(place: place, photo: Photo(image: photo, data: photos), route: nil)
                            marker.map = self.map
                            self.places.append(marker)
                        }
                        
                        // if place is last signal lock
                        if id == place_ids.last {
                            
                            // sort places by distance
                            self.places.sort(by: { self.distance(marker: $0) < self.distance(marker: $1) })
                            
                            // select closest pizza place
                            self.map.selectedMarker = self.places.first
                            
                            // zoom camera to closest place
                            self.map.moveCamera(GMSCameraUpdate.setTarget(self.map.selectedMarker!.position))
                            self.map.animate(toZoom: 14)
                            
                            lock.signal()
                        }
                    }
                }
            }
            
            // wait for signal
            lock.wait()
        }
        
        // extend map view to bottom of screen
        let oldFrame = self.map.superview!.frame
        self.map.superview!.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: oldFrame.width, height: UIApplication.shared.keyWindow!.frame.height - oldFrame.origin.y)
    }
    
    // set up view
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if self.map.selectedMarker != nil {
            self.infoLauncher.showInfo()
        }
    }
    
    // prepare data for new storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // send places array to search
        if let vc = segue.destination as? SearchViewController {
            vc.markers = self.places
        } else if let vc = segue.destination as? PlaceInfoViewController {
            vc.currentLocation = self.map.myLocation!.coordinate
            vc.data = self.map.selectedMarker?.userData as! MarkerData
        } else if let vc = segue.destination as? DirectionsViewController {
            vc.data = self.map.selectedMarker?.userData as! MarkerData
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
    
    // hide info when map is tapped
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if self.infoLauncher.isVisible {
            self.infoLauncher.hideInfo()
        }
        
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
    
    // gets data back from search result
    @IBAction func unwindHome(segue: UIStoryboardSegue) {
        if let vc = segue.source as? SearchViewController {
            if let marker = vc.selectedMarker {
                self.map.selectedMarker = marker
                self.map.animate(toLocation: marker.position)
            }
        }
    }
    
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
    
    /* update button text
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
        
    }*/
    
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

