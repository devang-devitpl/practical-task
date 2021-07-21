//
//  Location.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import ObjectMapper


class LocationList: Mappable {
    
    var lat: Double?
    var lng: Double?
    var notes: String?
    var name: String?
    var startTime: String?
    var endTime: String?
    var date: String?
    
    init() {}
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
        name <- map["name"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        notes <- map["notes"]
        date <- map["date"]
    }
}
