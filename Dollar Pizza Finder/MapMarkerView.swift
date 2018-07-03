//
//  MapMarkerView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/1/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GooglePlaces

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
    var place: GMSPlace?
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    // load UI elements from place
    func loadUI() {
        if let location = self.place {
            self.name.text = location.name
            self.address.text = String((location.formattedAddress?.split(separator: ",")[0])!)
            self.rating.text = starString(rating: location.rating)
            self.updatePhoto(id: location.placeID)
        }
        
    }
    
    @IBAction func directionsAction(_ sender: Any) {
        delegate?.didTapDirectionsButton(id: place!.placeID)
    }

    
    @IBAction func phoneAction(_ sender: Any) {
        if let phoneNumber = place?.phoneNumber {
            delegate?.didTapPhoneButton(number: phoneNumber)
        } else {
            print("No phone number found")
        }
    }
    
    @IBAction func websiteAction(_ sender: Any) {
        if let website = place?.website {
            delegate?.didTapWebsiteButton(url: website)
        } else {
            print("No website found")
        }
    }
    
    // Converts rating value to string with stars
    func starString(rating: Float) -> String {
        var output = String()
        for _ in 0 ..< Int(round(rating)) {
            output += "★"
        }
        return output + String(format: " %.1f", rating)
    }
    
    // updates photo for closest pizza place
    func updatePhoto(id: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: id) { (photos, error) -> Void in
            if let firstPhoto = photos?.results.first {
                GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                    (photo, error) -> Void in
                    self.image.image = photo
                })
            }
        }
    }
}
