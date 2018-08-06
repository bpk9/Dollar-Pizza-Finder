//
//  Firebase.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/3/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import Firebase

class FirebaseHelper {
    
    class func getData(completion: @escaping ([String]?) -> ()) {
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let children = snapshot.children.allObjects as? [DataSnapshot] {
                
                var locations = [String]()
                
                for child in children {
                    let id = child.childSnapshot(forPath: "placeId").value as? String ?? ""
                    print(id)
                    locations.append(id)
                }
                
                completion(locations)
            } else {
                completion(nil)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
        print("ok")
    }
    
}
