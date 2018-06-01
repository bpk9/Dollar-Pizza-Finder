//
//  Location.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import MapKit

class Location {
    
    let placeId: String
    let coordinate: CLLocationCoordinate2D
    
    init(placeId: String, coordinate: CLLocationCoordinate2D) {
        self.placeId = placeId
        self.coordinate = coordinate
    }
    
}
