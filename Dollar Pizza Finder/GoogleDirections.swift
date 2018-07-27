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
    
    func getDirections(completion: @escaping (Route) -> ()) {
        Alamofire.request(self.url).responseJSON { response in
            
            let decoder = JSONDecoder()
            let directions = try! decoder.decode(DirectionsResponse.self, from: response.data!)
            
            if let firstRoute = directions.routes.first {
                completion(firstRoute)
            }
            
        }
    }
    
}
