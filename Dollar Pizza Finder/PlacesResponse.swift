//
//  PlacesResponse.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 7/2/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

struct PlacesResponse: Codable {
    let result: Place
}

struct Place: Codable {
    let address_components: [AddressComponents]
    let formatted_address: String
    let formatted_phone_number: String?
    let geometry: Geometry
    let icon: String
    let place_id: String
    let rating: Double
    let website: String?
    let opening_hours: Hours?
}

struct AddressComponents: Codable {
    let long_name: String
    let short_name: String
    let types: [String]
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
