//
//  Suggstion.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps.GMSMarker

protocol SuggestionDelegate {
    func suggestionCell(didTap marker: GMSMarker)
}

class SuggestionCell: UIView {
    
    // ui elements
    @IBOutlet var name: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var distance: UILabel!
    
    // marker for place
    var marker: GMSMarker!
    
    // instance delegate
    var delegate: SuggestionDelegate?
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SuggestionCell", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    // load ui elements from data
    func loadUI(currentLocation: CLLocation?) {
        
        // data from marker
        let data = self.marker.userData as! MarkerData
        
        // name
        self.name.text = data.place.name
        
        // rating
        self.rating.text = GooglePlaces.starString(rating: data.place.rating)
        
        // distance
        if let myLocation = currentLocation {
            let coordinate = data.place.geometry.location
            self.distance.text = String(format: "%.2f mi", (myLocation.distance(from: CLLocation(latitude: coordinate.lat, longitude: coordinate.lng))) * 0.000621371)
        } else {
            self.distance.isHidden = true
        }
        
    }
    
    // view was tapped
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.suggestionCell(didTap: self.marker)
    }
    
}
