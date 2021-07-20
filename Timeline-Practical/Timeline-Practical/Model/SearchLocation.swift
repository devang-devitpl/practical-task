//
//  SearchLocation.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import ObjectMapper

class SearchLocation: Mappable {
    
    var name: String?
    var geometry: Geometry?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        geometry <- map["geometry"]
        name <- map["name"]
    }
}


class Geometry: Mappable {
    
    var location: GeoLocation?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        location <- map["location"]
    }

}

class GeoLocation: Mappable {
    
    var lat: Double?
    var lng: Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
    }

}
