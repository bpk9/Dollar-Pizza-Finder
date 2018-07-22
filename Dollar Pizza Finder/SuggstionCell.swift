//
//  Suggstion.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/19/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps.GMSMarker

class SuggestionCell: UIView {
    
    // ui elements
    @IBOutlet var name: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var distance: UILabel!
    
    // marker for place
    var marker: GMSMarker!
    
    // init function
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SuggestionCell", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    // load ui elements from data
    func loadUI(currentLocation: CLLocation) {
        
        let data = self.marker.userData as! MarkerData
        
        self.name.text = data.place.name
        
        self.rating.text = GooglePlaces.starString(rating: data.place.rating)
        
        let coordinate = data.place.geometry.location
        self.distance.text = String(format: ".2f mi", (currentLocation.distance(from: CLLocation(latitude: coordinate.lat, longitude: coordinate.lng))))
    }
    
}
