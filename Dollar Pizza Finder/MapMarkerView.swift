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
    @IBOutlet var directionsBtn: UIButton!
    
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
    }
    
    @IBAction func phoneAction(_ sender: Any) {
        if let phoneNumber = self.place?.formatted_phone_number {
            let url = URL(string: "tel://\(self.getRawNum(input: phoneNumber))")!
            self.openURL(url: url)
        } else {
            print("No phone number found")
        }
    }
    
    @IBAction func websiteAction(_ sender: Any) {
        if let website = self.place?.website {
            self.openURL(url: URL(string: website)!)
        } else {
            print("No website found")
        }
    }
    
    // Converts rating value to string with stars
    func starString(rating: Double) -> String {
        var output = String()
        for _ in 0 ..< Int(round(rating)) {
            output += "★"
        }
        return output + String(format: " %.1f", rating)
    }
    
    // only retrive digits from phone number
    func getRawNum(input: String) -> String {
        var output = ""
        for character in input {
            let char = String(character)
            if Int(char) != nil {
                output += char
            }
        }
        return output
    }
    
    // opens url
    func openURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
