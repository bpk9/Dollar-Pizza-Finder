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
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    func loadUI(data: MarkerData) {
        self.name.text = data.place.name
        self.address.text = String(data.place.formatted_address.split(separator: ",")[0])
        self.rating.text = GooglePlaces.starString(rating: data.place.rating)
        self.setTimeLabel(hours: data.place.opening_hours!)
        self.image.image = data.photo.image
    }
    
    func setTimeLabel(hours: Hours) {
        
        // init date and time
        let date = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        // if place is open
        if hours.periods.count == 1 {
            self.open.text = "OPEN 24 Hours"
        } else if hours.open_now {
            self.open.text = "OPEN until " + self.getTime(time: hours.periods[dayOfWeek].close!.time)
        } else {
            self.open.textColor = .red
            self.open.text = "CLOSED until " + self.getTime(time: hours.periods[dayOfWeek].open.time)
        }
    }
    
    func getTime(time: String) -> String {
        let hour = time.substring(to:time.index(time.startIndex, offsetBy: 2))
        let num = Int(hour)!
        if num == 0 {
            return "12AM"
        } else if num < 12 {
            return String(num) + "AM"
        } else if num == 12 {
            return "12PM"
        } else {
            return String(num - 12) + "PM"
        }
            
    }
    
}
