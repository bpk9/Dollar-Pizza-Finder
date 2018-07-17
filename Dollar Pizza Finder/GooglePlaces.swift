//
//  GooglePlaces.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import Alamofire
import GooglePlaces

class GooglePlaces {
    
    class func getData(place_id: String, completion: @escaping (Place, UIImage) -> ()) {
        self.lookUpPlace(place_id: place_id) { (place) -> () in
            self.lookUpPhoto(place_id: place_id) { (photo) -> () in
                completion(place, photo)
            }
        }
    }
        
    class func lookUpPlace(place_id: String, completion: @escaping (Place) -> ()) {
        
        // get response from google places
        Alamofire.request("https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=AIzaSyBVsu4GKsTC7X0l7CpCur1WpVAcxgP5wro").responseJSON { response in
            
            let decoder = JSONDecoder()
            let data = try! decoder.decode(PlacesResponse.self, from: response.data!)
            
            completion(data.result)
            
        }
    }
    
    class func lookUpPhoto(place_id: String, completion: @escaping (UIImage) -> ()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: place_id) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto) { (photo) -> () in
                        completion(photo)
                    }
                }
            }
        }
    }
    
    class func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, completion: @escaping (UIImage) -> ()) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                completion(photo!)
            }
        })
    }
}
