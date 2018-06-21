//
//  Location.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 5/18/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import GooglePlaces

class Location {
    
    // location attributes
    private let name: String!
    private let address: [GMSAddressComponent]!
    private let coordinate: CLLocationCoordinate2D!
    private let rating: Float!
    private let phone: String!
    private let website: URL!
    private let image: UIImage!
    
    // initialize attributes
    override init(placeId: String) {
        
        // get data from google places
        GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            
            // if an error occurs
            if let error = error {
                
                print("lookup place id query error: \(error.localizedDescription)")
            
            }
            
            // if a place is found
            if let place = place {
                
                self.name = place.name
                self.address = place.addressComponents
                self.coordinate = place.coordinate
                self.rating = place.rating
                self.phone = place.phoneNumber
                self.website = place.website
            
            }
        })
        
        // get image for location
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) -> Void in
            
            // if an error occurs
            if let error = error {
                
                print("Error: \(error.localizedDescription)")
            
            } else {
                
                if let firstPhoto = photos?.results.first {
                    
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: { (photo, error) -> Void in
                        
                        if let error = error {
                            
                            print("Error: \(error.localizedDescription)")
                        
                        } else {
                            
                            self.image = photo
                        
                        }
                    })
                }
            }
        }
        
    }
    
}
