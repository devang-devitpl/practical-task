//
//  APIService.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import UIKit
import Moya


let apiProvider = MoyaProvider<APIService>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: NetworkLoggerPlugin.Configuration.LogOptions.verbose))])


enum APIService {
    case searchPlaces(location: String, keyword: String, key: String)
}


extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api")!

    }
    
    var path: String {
        return "/place/nearbysearch/json"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .searchPlaces(let location, let keyword, let key):
        return .requestParameters(parameters: ["location": location, "keyword": keyword, "key": key, "radius": 200000], encoding: URLEncoding(destination: .queryString))
        }

    }
    
    var headers: [String : String]? {
        return nil
    }
}
