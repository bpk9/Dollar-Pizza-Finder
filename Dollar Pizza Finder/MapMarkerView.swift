//
//  MapMarkerView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/1/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit

protocol MapMarkerDelegate: class {
    func didTapDirectionsButton(id: String)
    func didTapPhoneButton(number: String)
    func didTapWebsiteButton(url: URL)
}

class MapMarkerView: UIView {
    
    // UI elements
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var open: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var directionsBtn: UIButton!
    
    // instance variables
    var delegate: MapMarkerDelegate?
    var place: Place?
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    // load UI elements from place
    func loadUI() {
        if let location = self.place {
            self.name.text = location.name
            self.address.text = String(location.formatted_address.split(separator: ",")[0])
            self.rating.text = starString(rating: location.rating)
        }
        
    }
    
    @IBAction func directionsAction(_ sender: Any) {
        delegate?.didTapDirectionsButton(id: place!.place_id)
    }

    
    @IBAction func phoneAction(_ sender: Any) {
        if let phoneNumber = place?.formatted_phone_number {
            delegate?.didTapPhoneButton(number: phoneNumber)
        } else {
            print("No phone number found")
        }
    }
    
    @IBAction func websiteAction(_ sender: Any) {
        if let website = URL(string: (place?.website)!) {
            delegate?.didTapWebsiteButton(url: website)
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
    
}
