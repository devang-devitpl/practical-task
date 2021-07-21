//
//  DBManager.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class DBManager: NSObject {
    class func getContext() -> NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
        //let cdm = CoreDataManager.sharedInstance
        //return cdm.mainContext
    }
    
    class func saveDatabase() {
        if self.getContext().hasChanges {
            try? self.getContext().save()
        }
    }

    class func store(location: LocationList) {
        
        let context = getContext()

        let dbLocation = Places(context: context)
        
        dbLocation.latitude = location.lat ?? 0
        dbLocation.longitude = location.lng ?? 0
        dbLocation.startTime = location.startTime
        dbLocation.endTime = location.endTime
        dbLocation.name = location.name
        dbLocation.notes = location.notes
        
        do {
            try context.save()
        } catch {
            print("error store locaton: ", error.localizedDescription)
        }

    }

    class func addPlace(dicRequest: [String: Any]) {
        
        guard let name = dicRequest["name"] as? String,
              let notes = dicRequest["notes"] as? String,
              let startTime = dicRequest["startTime"] as? String,
              let endTime = dicRequest["endTime"] as? String,
              let lat = dicRequest["lat"] as? Double,
              let lng = dicRequest["lng"] as? Double,
              let date = dicRequest["date"] as? String else {
            return
        }
        
        
        let context = getContext()

        let dbLocation = Places(context: context)
        
        dbLocation.latitude = lat
        dbLocation.longitude = lng
        dbLocation.startTime = startTime
        dbLocation.endTime = endTime
        dbLocation.name = name
        dbLocation.notes = notes
        dbLocation.date = date

        do {
            try context.save()
        } catch {
            print("error adding place to locaton: ", error.localizedDescription)
        }
    }
    
    class func fetchPlaces(selectedDate: String) -> [Places] {
        
//        var arrLocations: [LocationList] = []
        
        let context = getContext()
        
        do {
            let fetchRequest:NSFetchRequest<Places> = Places.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "date == %@", selectedDate)
            
            return try context.fetch(fetchRequest)
//                .forEach({ (place) in
//
//                let location = LocationList
//            })

            
        } catch {
            print("error fetching places", error.localizedDescription)
        }
        
        return []
    }
}

