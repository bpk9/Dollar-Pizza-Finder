//
//  GoogleDirections.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 6/26/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import CoreLocation.CLLocation
import GoogleMaps
import Alamofire

class GoogleDirections {
    
    let apikey = "AIzaSyAsQrnM69UGzWJM_hgo8hceDo3ySc6as3w"
    
    var url: String! = ""
    
    init(origin: CLLocationCoordinate2D, destination: String, mode: String) {
        
        self.url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=place_id:\(destination)&mode=\(mode)&alternatives=true&key=\(apikey)"
        
    }
    
    func getDirections(completion: @escaping ([Route]) -> ()) {
        Alamofire.request(self.url).responseJSON { response in
            
            let decoder = JSONDecoder()
            let directions = try! decoder.decode(DirectionsResponse.self, from: response.data!)
            
            completion(directions.routes)
            
        }
    }
    
    class func getRouteText(route: Route) -> String {
        
        var route = route
        
        // if summary does not exist
        if route.summary == "" {
            
            // step with longest distance
            let steps = route.legs.first!.steps
            var maxStep = steps.first!
            
            for step in route.legs.first!.steps.dropFirst() {
                if let maxDist = maxStep.distance.value {
                    if let dist = step.distance.value {
                        if dist > maxDist {
                            maxStep = step
                        }
                    }
                }
            }
            
            route.summary = maxStep.transit_details!.headsign
            
        }
        
        return route.legs.first!.duration.text + " via " + route.summary
        
    }
    
}
