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
    let formatted_address: String
}
