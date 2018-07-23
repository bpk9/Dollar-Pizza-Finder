//
//  SuggestionView.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/22/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit
import GoogleMaps.GMSMarker

protocol SuggestionDelegate {
    func suggestionView(didTap marker: GMSMarker)
}

class SuggestionView: UIView {
    
    // ui elements
    var name: UILabel!
    var rating: UILabel!
    var distance: UILabel!
    
    // screen width
    let screenWidth: CGFloat
    
    // marker for place
    var marker: GMSMarker!
    
    // instance delegate
    var delegate: SuggestionDelegate?
    
    init() {
        self.screenWidth = UIApplication.shared.keyWindow!.frame.width
        super.init(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: 50))
        
        // constraints
        self.heightAnchor.constraint(equalToConstant: 150)
        self.widthAnchor.constraint(equalToConstant: self.screenWidth)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // load ui elements from data
    func loadUI(currentLocation: CLLocation) {
        
        // data from marker
        let data = self.marker.userData as! MarkerData
        
        // name
        self.name = UILabel(frame: CGRect(x: 10, y: 10, width: (self.screenWidth - 10), height: 15))
        self.name.text = data.place.name
        self.addSubview(self.name)
        
        // rating
        self.rating = UILabel(frame: CGRect(x: 10, y: 10, width: (self.screenWidth - 10), height: 15))
        self.rating.text = GooglePlaces.starString(rating: data.place.rating)
        self.addSubview(self.rating)
        
        // distance
        self.distance = UILabel(frame: CGRect(x: (self.screenWidth - 10), y: 25, width: 75, height: 30))
        let coordinate = data.place.geometry.location
        self.distance.textAlignment = .center
        self.distance.text = String(format: "%.2f mi", (currentLocation.distance(from: CLLocation(latitude: coordinate.lat, longitude: coordinate.lng))) * 0.000621371)
        self.addSubview(self.distance)
    }
    
    // view was tapped
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.suggestionView(didTap: self.marker)
    }
    
}
