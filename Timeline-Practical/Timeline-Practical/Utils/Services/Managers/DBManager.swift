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

        let dbLocation = Location(context: context)
        
        dbLocation.latitude = location.lat ?? 0
        dbLocation.longitude = location.lng ?? 0
        dbLocation.time = location.time
        dbLocation.notes = location.notes
        
        do {
            try context.save()
        } catch {
            print("error store locaton: ", error.localizedDescription)
        }

    }
    
    
    class func fetchLocations() {
    
    }
    
}

