//
//  Location.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import CoreLocation

class Location {
    
    let name, imageUrl: String
    let lat, long: Double
    let coordinate: CLLocationCoordinate2D
    let location: CLLocation
    let stars: Int
    var distance: Float = -1.0
    
    init(name: String, lat: Double, long: Double, stars: Int, imageUrl: String) {
        self.name = name
        self.lat = lat
        self.long = long
        self.coordinate = CLLocationCoordinate2DMake(lat, long)
        self.location = CLLocation(latitude: lat, longitude: long)
        self.stars = stars
        self.imageUrl = imageUrl
        
        print(self.name + ":")
        print(self.lat)
        print(self.long)
        print("Stars: " + String(self.stars))
    }
    
}
