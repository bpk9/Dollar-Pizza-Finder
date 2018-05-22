//
//  Venue.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import MapKit
import AddressBook

class Venue : NSObject, MKAnnotation
{
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(location: Location)
    {
        self.title = location.name
        self.coordinate = location.coordinate
        
        super.init()
    }
    
}
