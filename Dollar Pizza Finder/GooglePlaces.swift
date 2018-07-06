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
    
    var placeId: String
    
    init(place_id: String) {
        self.placeId = place_id
    }
    
    func getData(completion: @escaping (Place, UIImage) -> ()) {
        self.lookUpPlace() { (place) -> () in
            self.lookUpPhoto() { (photo) -> () in
                completion(place, photo)
            }
        }
    }
        
    func lookUpPlace(completion: @escaping (Place) -> ()) {
        
        // get response from google places
        Alamofire.request("https://maps.googleapis.com/maps/api/place/details/json?placeid=\(self.placeId)&key=AIzaSyBVsu4GKsTC7X0l7CpCur1WpVAcxgP5wro").responseJSON { response in
            
            let decoder = JSONDecoder()
            let data = try! decoder.decode(PlacesResponse.self, from: response.data!)
            
            completion(data.result)
            
        }
    }
    
    func lookUpPhoto(completion: @escaping (UIImage) -> ()) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.placeId) { (photos, error) -> Void in
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
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, completion: @escaping (UIImage) -> ()) {
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
