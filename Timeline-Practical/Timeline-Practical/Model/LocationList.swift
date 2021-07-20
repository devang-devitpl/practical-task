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
    var time: String?
    var notes: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
        time <- map["time"]
        notes <- map["notes"]
    }
}
