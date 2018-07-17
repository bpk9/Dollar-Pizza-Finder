//
//  Firebase.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/3/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import Firebase

class FirebaseHelper {
    
    class func getData(completion: @escaping ([String]) -> ()) {
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            var locations = [String]()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                locations.append(child.childSnapshot(forPath: "placeId").value as? String ?? "")
            }
            
            completion(locations)
        })
    }
    
}
