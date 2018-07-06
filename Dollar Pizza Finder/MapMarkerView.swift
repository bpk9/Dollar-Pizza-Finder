//
//  MapMarkerView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/1/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

class MapMarkerView: UIView {
    
    // UI elements
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var open: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var image: UIImageView!
    
    // place for marker
    var place: Place!
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func loadUI() {
        self.name.text = self.place.name
        self.address.text = String(self.place.formatted_address.split(separator: ",")[0])
        self.rating.text = self.starString(rating: self.place.rating)
        self.setTimeLabel(hours: self.place.opening_hours!)
    }
    
    // Converts rating value to string with stars
    func starString(rating: Double) -> String {
        var output = String()
        for _ in 0 ..< Int(round(rating)) {
            output += "★"
        }
        return output + String(format: " %.1f", rating)
    }
    

    
    func setTimeLabel(hours: Hours) {
        
        // init date and time
        let date = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // if place is open
        if hours.open_now {
            self.open.textColor = .green
            if let close = hours.periods[dayOfWeek].close {
                self.open.text = "OPEN until " + self.getTime(time: close.time)
            } else {
                self.open.text = "OPEN 24 Hours"
            }
        } else {
            self.open.text = "CLOSED until " + self.getTime(time: hours.periods[dayOfWeek].open.time)
        }
        
    }
    
    func getTime(time: String) -> String {
        let hour = time.substring(to:time.index(time.startIndex, offsetBy: 2))
        let num = Int(hour)!
        if num  >= 12 {
            return String(num - 12) + "PM"
        } else {
            return hour + "AM"
        }
    }
    
}
