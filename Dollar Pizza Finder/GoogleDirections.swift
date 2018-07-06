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
    
    var url: String! = ""
    
    init(origin: CLLocationCoordinate2D, destination: String, mode: String) {
        
        self.url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=place_id:\(destination)&mode=\(mode)&key=\(apikey)"
        
    }
    
    func getDirections(completion: @escaping (Route) -> ()) {
        Alamofire.request(self.url).responseJSON { response in
            
            let decoder = JSONDecoder()
            let directions = try! decoder.decode(DirectionsResponse.self, from: response.data!)
            
            completion(directions.routes.first!)
            
        }
    }
    
    func addPolyline(map: GMSMapView) {
        
        self.getDirections() { (route) -> () in
            
            // for each step in journey
            for step in route.legs.first!.steps {
                
                // get polyline
                let path = GMSPath(fromEncodedPath: step.polyline.points)
                
                // add polyline to map
                let polyline = GMSPolyline(path: path)
                if step.travel_mode == "TRANSIT" {
                    
                    // change polyline color for transit line
                    if let color = step.transit_details?.line.color {
                        polyline.strokeColor = self.hexStringToUIColor(hex: color)
                    } else {
                        polyline.strokeColor = .black
                    }
                    
                    polyline.strokeWidth = 10.0
                } else {
                    polyline.strokeColor = .gray
                    polyline.strokeWidth = 5.0
                }
                polyline.map = map

            }
            
            self.updateCamera(map: map, route: route)
        }
        
    }
    
    // update map camera to bounds
    func updateCamera(map: GMSMapView, route: Route) {
        let bounds = route.bounds
        let update = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(bounds.northeast.lat, bounds.northeast.lng), coordinate: CLLocationCoordinate2DMake(bounds.southwest.lat, bounds.southwest.lng)))
        map.moveCamera(update)
    }
    
    // changes hex string to UI Color for polyline
    func hexStringToUIColor(hex:String) -> UIColor {
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
    
    func getSteps(completion: @escaping ([Step]) -> ()) {
        
        self.getDirections() { (route) -> () in
        
            completion(route.legs.first!.steps)
            
        }
    
    }
}
