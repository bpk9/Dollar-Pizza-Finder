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
    
    class func getData(place_id: String, completion: @escaping (MarkerData?) -> ()) {
        self.lookUpPlace(place_id: place_id) { (place) -> () in
            if let place = place {
                self.lookUpPhoto(place_id: place_id) { (photo) -> () in
                    if let photo = photo {
                        let data = MarkerData(place: place, photo: photo, routes: nil, directionsType: nil)
                        completion(data)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
            
        }
    }
        
    class func lookUpPlace(place_id: String, completion: @escaping (Place?) -> ()) {
        
        // get response from google places
        Alamofire.request("https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=").responseJSON { response in
            
            let decoder = JSONDecoder()
            if let data = try? decoder.decode(PlacesResponse.self, from: response.data!) {
                completion(data.result)
            } else {
                completion(nil)
            }
            
        }
    }
    
    class func lookUpPhoto(place_id: String, completion: @escaping (Photo?) -> ()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: place_id) { (photos, error) -> Void in
            if error != nil {
                completion(nil)
            } else {
                if let firstPhotoData = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhotoData) { (firstPhoto) -> () in
                        if let firstPhoto = firstPhoto {
                            let photo = Photo(image: firstPhoto, data: photos!)
                            completion(photo)
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    class func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> ()) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if error != nil {
                completion(nil)
            } else {
                completion(photo)
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
