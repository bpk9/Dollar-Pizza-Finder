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
    
    var url: String! = ""
    
    init(origin: CLLocationCoordinate2D, destination: String, mode: String) {
        
        self.url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=place_id:\(destination)&mode=\(mode)&alternatives=true&key="
        
    }
    
    func getDirections(completion: @escaping ([Route]) -> ()) {
        Alamofire.request(self.url).responseJSON { response in
            
            let decoder = JSONDecoder()
            let directions = try! decoder.decode(DirectionsResponse.self, from: response.data!)
            
            var routes = directions.routes
            
            for i in 0..<routes.count {
                // if summary does not exist
                if routes[i].summary == "" {
                    
                    // step with longest distance
                    let steps = routes[i].legs.first!.steps
                    var maxStep = steps.first!
                    
                    for step in steps.dropFirst() {
                        if let maxDist = maxStep.distance.value {
                            if let dist = step.distance.value {
                                if dist > maxDist {
                                    maxStep = step
                                }
                            }
                        }
                    }
                    
                    routes[i].summary = maxStep.transit_details!.headsign
                    
                }
            }
            
            completion(routes)
            
        }
    }
    
    class func getRouteText(route: Route) -> String {
        return route.legs.first!.duration.text + " Via " + route.summary
    }
    
}
