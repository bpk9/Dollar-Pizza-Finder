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
            
            // get route path
            let routes = response["routes"] as! [NSDictionary]
            let legs = routes[0]["legs"] as! [NSDictionary]
            let steps = legs[0]["steps"] as! [NSDictionary]
            
            // for each step in journey
            for step in steps {
                
                // get travel type
                let type = step["travel_mode"] as! String
                
                // get polyline
                let poly = step["polyline"] as! NSDictionary
                let points = poly["points"] as! String
                let path = GMSPath(fromEncodedPath: points)
                
                // add polyline to map
                let polyline = GMSPolyline(path: path)
                if type == "TRANSIT" {
                    
                    // get transit color
                    let details = step["transit_details"] as! NSDictionary
                    let line = details["line"] as! NSDictionary
                    let color = line["color"] as! String
                    
                    polyline.strokeColor = self.hexStringToUIColor(hex: color)
                    polyline.strokeWidth = 10.0
                } else {
                    polyline.strokeColor = .gray
                    polyline.strokeWidth = 5.0
                }
                polyline.map = map

            }
            
            // get map bounds
            let bounds = routes[0]["bounds"] as! NSDictionary
            let northeast = bounds["northeast"] as! NSDictionary
            let nlat = northeast["lat"] as! Double
            let nlng = northeast["lng"] as! Double
            let southwest = bounds["southwest"] as! NSDictionary
            let slat = southwest["lat"] as! Double
            let slng = southwest["lng"] as! Double
            
            // update map camera to bounds
            let update = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(nlat, nlng), coordinate: CLLocationCoordinate2DMake(slat, slng)))
            map.moveCamera(update)
        
        }
        
    }
    
    // self explainitory
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
