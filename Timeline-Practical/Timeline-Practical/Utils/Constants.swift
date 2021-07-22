//
//  Constants.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import UIKit
import CoreData

enum NotificationConst: String {
    case updateLocationList = "updateLocationList"
    
    func postNotification(notificationObject object: Any? = nil, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.rawValue), object: object, userInfo: aUserInfo)
    }

    var nsName : NSNotification.Name {
        return NSNotification.Name(rawValue: self.rawValue)
    }

}

// Enum - to update accuracy for the location
enum LocationAccuracy: CLLocationAccuracy {
    case bestForNavigation
    case accuracyBest
    case tenMeter
    case hundredMeter
    case oneKm
    case threeKm
    
    var accuracy : CLLocationAccuracy {
        switch self {
        
        case .bestForNavigation: return kCLLocationAccuracyBestForNavigation
        case .accuracyBest: return kCLLocationAccuracyBest
        case .tenMeter: return kCLLocationAccuracyNearestTenMeters
        case .hundredMeter: return kCLLocationAccuracyHundredMeters
        case .oneKm: return kCLLocationAccuracyKilometer
        case .threeKm: return kCLLocationAccuracyThreeKilometers
        }
    }
    
}
