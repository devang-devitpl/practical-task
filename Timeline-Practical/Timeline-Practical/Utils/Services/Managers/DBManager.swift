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
        
        dbLocation.uuid = UUID().uuidString
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
        
        let context = getContext()
        
        do {
            let fetchRequest:NSFetchRequest<Places> = Places.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "date == %@", selectedDate)
            
            return try context.fetch(fetchRequest)
            
        } catch {
            print("error fetching places", error.localizedDescription)
        }
        
        return []
    }
    
    class func updatePlace(dicRequest: [String: Any]) {
        let context = getContext()
        
        guard let startTime = dicRequest["startTime"] as? String,
              let endTime = dicRequest["endTime"] as? String,
              let lat = dicRequest["lat"] as? Double,
              let lng = dicRequest["lng"] as? Double,
              let date = dicRequest["date"] as? String else {
            return
        }

        
        do {
            let fetchRequest:NSFetchRequest<Places> = Places.fetchRequest()
            let latPredicate = NSPredicate(format: "latitude == %lf",  lat)
            let lngPredicate = NSPredicate(format: "longitude == %lf",  lng)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, lngPredicate])
            
            if let fetchedPlace = try context.fetch(fetchRequest).first {
                fetchedPlace.startTime = startTime
                fetchedPlace.endTime = endTime
                fetchedPlace.latitude = lat
                fetchedPlace.longitude = lng
                fetchedPlace.date = date
            }
            
        } catch {
            print("Error in udpating place:", error.localizedDescription)
        }
        
        do {
            try context.save()
        } catch {
            print("error updating place to locaton: ", error.localizedDescription)
        }
    }
    
    class func updateNotes(uuid: String, notes: String) {
        let context = getContext()
        
        do {
            let fetchRequest:NSFetchRequest<Places> = Places.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
            
            if let fetchedPlace = try context.fetch(fetchRequest).first {
                fetchedPlace.notes = notes
            }
            try context.save()
        } catch {
            print("Error in udpating notes:", error.localizedDescription)
        }
    }
}

