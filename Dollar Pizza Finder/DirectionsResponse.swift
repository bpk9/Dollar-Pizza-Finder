//
//  Response.swift
//  Dollar Pizza Finder
//
//  Created by Brian Kasper on 6/28/18.
//  Copyright © 2018 Brian P Kasper. All rights reserved.
//

struct DirectionsResponse: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let bounds: Bounds
    let legs: [Leg]
    var summary: String
}

struct Bounds: Codable {
    let northeast: Coordinate
    let southwest: Coordinate
}

struct Coordinate: Codable {
    let lat: Double
    let lng: Double
}

struct Leg: Codable {
    let arrival_time: Text?
    let departure_time: Text?
    let distance: Text
    let duration: Text
    let steps: [Step]
}

struct Text: Codable {
    let text: String
    let value: Int?
}

struct Step: Codable {
    let distance: Text
    let duration: Text
    let end_location: Coordinate
    let html_instructions: String
    let polyline: Polyline
    let start_location: Coordinate
    let transit_details: TransitDetails?
    let travel_mode: String
}

struct Polyline: Codable {
    let points: String
}

struct TransitDetails: Codable {
    let arrival_stop: Stop
    let arrival_time: Text
    let departure_stop: Stop
    let departure_time: Text
    let headsign: String
    let line: Line
    let num_stops: Int
}

struct Stop: Codable {
    let location: Coordinate
    let name: String
}

struct Line: Codable {
    let color: String?
    let name: String?
    let short_name: String?
    let vehicle: Vehicle
    let icon: String?
}

struct Vehicle: Codable {
    let icon: String?
    let name: String
}
