//
//  Date+String.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import UIKit

enum DateFormate: String {
    case yyyy_MM_dd_T_HH_MM_SS_XXX = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
    case yyyy_MM_dd_T_HH_MM_SS_Z = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case server = "yyyy-MM-dd'T'HH:mm:ssZ"
    case converted = "dd MMM yyyy HH:mm a"
    
    case titleDate = "dd-MMM-yyyy"
    case HH_MM = "h:mm a"
}

extension String {
    //Convert timezone string to NSTimeZone
    func toDate(format: DateFormate = .yyyy_MM_dd_T_HH_MM_SS_Z) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if format == .yyyy_MM_dd_T_HH_MM_SS_Z {
            if let formattedDate = dateFormatter.date(from: self) {
                return formattedDate
            } else {
                dateFormatter.dateFormat = DateFormate.yyyy_MM_dd_T_HH_MM_SS_Z.rawValue
                return dateFormatter.date(from: self)
            }
        }
        return dateFormatter.date(from: self)
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
extension Date {
    func toString(formateType type: DateFormate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = type.rawValue
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
}

