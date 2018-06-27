//
//  GoogleDirections.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 6/26/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import CoreLocation
import GoogleMaps
import Alamofire

class GoogleDirections {
    
    let apikey = "AIzaSyAsQrnM69UGzWJM_hgo8hceDo3ySc6as3w"
    
    var url: String
    
    init(origin: CLLocationCoordinate2D, destination: String, mode: String) {
        
        self.url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=place_id:\(destination)&mode=\(mode)&key=\(apikey)"
        
    }
    
    func getDirections(completion: @escaping (NSDictionary) -> ()) {
        Alamofire.request(self.url).responseJSON { response in
            
            completion(response.result.value as! NSDictionary)
            
        }
    }
    
    func getDuration(completion: @escaping (String) -> ()) {
        self.getDirections() { (response) -> () in
            let routes = response["routes"] as! [NSDictionary]
            let legs = routes[0]["legs"] as! [NSDictionary]
            let duration = legs[0]["duration"] as! NSDictionary
            let text = duration["text"] as! String
            
            completion(text)
        }
    }
    
    func addPolyline(map: GMSMapView) {
        
        self.getDirections() { (response) -> () in
            
            let routes = response["routes"] as! [NSDictionary]
            let overview = routes[0]["overview_polyline"] as? NSDictionary
            let points = overview!["points"] as? String
            let path = GMSPath(fromEncodedPath: points!)
                
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = self.generateRandomColor()
            polyline.strokeWidth = 10.0
            polyline.map = map
            
            let bounds = routes[0]["bounds"] as! NSDictionary
            let northeast = bounds["northeast"] as! NSDictionary
            let nlat = northeast["lat"] as! Double
            let nlng = northeast["lng"] as! Double
            let southwest = bounds["southwest"] as! NSDictionary
            let slat = southwest["lat"] as! Double
            let slng = southwest["lng"] as! Double
            
            let update = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(nlat, nlng), coordinate: CLLocationCoordinate2DMake(slat, slng)))
            map.moveCamera(update)
        
        }
        
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
}
