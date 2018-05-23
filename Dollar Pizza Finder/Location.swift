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
    let stars, openTime, closeTime: Int
    var distance: Float = -1.0
    
    init(name: String, lat: Double, long: Double, stars: Int, imageUrl: String, openTime: Int, closeTime: Int) {
        self.name = name
        self.lat = lat
        self.long = long
        self.coordinate = CLLocationCoordinate2DMake(lat, long)
        self.location = CLLocation(latitude: lat, longitude: long)
        self.stars = stars
        self.imageUrl = imageUrl
        self.openTime = openTime
        self.closeTime = closeTime
    }
    
    func isOpen() -> Bool {
        if self.openTime == self.closeTime {
            return true
        }
        let hour = Calendar.current.component(.hour, from: Date())
        print("HOUR" + String(hour))
        var i = self.openTime
        while true {
            if i == hour {
                return true
            } else if i == self.closeTime {
                return false
            } else if i == 23 {
                i = 0
            } else {
                i += 1
            }
        }
    }
    
    func getCloseTimeText() -> String {
        if self.closeTime == self.openTime {
            return "OPEN 24HRS"
        } else if self.closeTime > 12 {
            return String(self.closeTime - 12) + "PM"
        } else if self.closeTime == 12 {
            return "12PM"
        } else if self.closeTime == 0 {
            return "12AM"
        } else {
            return String(self.closeTime) + "AM"
        }
    }
    
}
