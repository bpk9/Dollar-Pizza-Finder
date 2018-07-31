//
//  PlacesResponse.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

import UIKit.UIImage
import GooglePlaces.GMSPlacePhotoMetadataList

struct PlacesResponse: Codable {
    let result: Place
}

struct Place: Codable {
    let name: String
    let formatted_address: String
    let formatted_phone_number: String?
    let geometry: Geometry
    let icon: String
    let place_id: String
    let rating: Double
    let website: String?
    let opening_hours: Hours?
    let reviews: [Review]
}

struct Geometry: Codable {
    let location: Coordinate
    let viewport: Bounds
}

struct Hours: Codable {
    let open_now: Bool
    let periods: [Period]
}

struct Period: Codable {
    let open: DayTime
    let close: DayTime?
}
struct DayTime: Codable {
    let day: Int
    let time: String
}

struct Review: Codable {
    let rating: Double
    let author_name: String
    let profile_photo_url: String
    let relative_time_description: String
    let text: String
}

