//
//  MarkerData.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/6/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit.UIImage
import GooglePlaces.GMSPlacePhotoMetadataList

struct MarkerData {
    var place: Place
    var photo: Photo
    var route: Route?
}

struct Photo {
    var image: UIImage
    var data: GMSPlacePhotoMetadataList
}
