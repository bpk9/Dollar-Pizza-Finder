//
//  Firebase.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/3/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import Firebase

class FirebaseHelper {
    
    class func getData(completion: @escaping ([Location]) -> ()) {
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            var locations = [Location]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let placeId = child.childSnapshot(forPath: "placeId").value as? String ?? ""
                let lat = child.childSnapshot(forPath: "latitude").value as? Double ?? 0.0
                let lng = child.childSnapshot(forPath: "longitude").value as? Double ?? 0.0
                locations.append(Location(placeId: placeId, lat: lat, lng: lng))
            }
            
            completion(locations)
        })
    }
    
}
