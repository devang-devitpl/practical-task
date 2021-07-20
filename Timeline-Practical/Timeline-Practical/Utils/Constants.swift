//
//  Constants.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import UIKit

enum NotificationConst: String {
    case singleLocationUpdate = "singleLocationUpdate"
   
    
    func postNotification(notificationObject object: Any? = nil, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.rawValue), object: object, userInfo: aUserInfo)
    }

    var nsName : NSNotification.Name {
        return NSNotification.Name(rawValue: self.rawValue)
    }

}
