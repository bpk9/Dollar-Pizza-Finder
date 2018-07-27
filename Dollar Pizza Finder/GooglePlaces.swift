//
//  GooglePlaces.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import Alamofire
import GooglePlaces.GMSPlacesClient
import GooglePlaces.GMSPlacePhotoMetadataList

class GooglePlaces {
    
    class func getData(place_id: String, completion: @escaping (Place?, UIImage?, GMSPlacePhotoMetadataList?) -> ()) {
        self.lookUpPlace(place_id: place_id) { (place) -> () in
            if place != nil {
                self.lookUpPhoto(place_id: place_id) { (photo, photos) -> () in
                    completion(place!, photo, photos)
                }
            } else {
                completion(nil, nil, nil)
            }
            
        }
    }
        
    class func lookUpPlace(place_id: String, completion: @escaping (Place?) -> ()) {
        
        // get response from google places
        Alamofire.request("https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=AIzaSyBVsu4GKsTC7X0l7CpCur1WpVAcxgP5wro").responseJSON { response in
            
            let decoder = JSONDecoder()
            let data = try? decoder.decode(PlacesResponse.self, from: response.data!)
            
            if let result = data?.result {
                completion(result)
            } else {
                completion(nil)
            }
            
        }
    }
    
    class func lookUpPhoto(place_id: String, completion: @escaping (UIImage, GMSPlacePhotoMetadataList) -> ()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: place_id) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto) { (photo) -> () in
                        completion(photo, photos!)
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
    
    // Converts rating value to string with stars
    class func starString(rating: Double) -> String {
        var output = String()
        for _ in 0 ..< Int(round(rating)) {
            output += "★"
        }
        return output + String(format: " %.1f", rating)
    }
}
