//
//  AppDelegate.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import GoogleMaps

let apiKey = "AIzaSyDHvVgsiipm58D-vJFkarssrH8c_53NEcE"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(apiKey)
        keyboardSettings()
        openAppUsingLaunchOptions(launchOptions: launchOptions)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data stack

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        var container = NSPersistentContainer(name: "Timeline_Practical")
        let storeUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("Timeline_Practical.sqlite")
        print("DB Path ", storeUrl)

        let description = NSPersistentStoreDescription(url: storeUrl)

        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true

        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
        /*
        /*add necessary support for migration*/
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions =  [description]
        /*add necessary support for migration*/
        */
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


extension AppDelegate {
    func openAppUsingLaunchOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        //Update server with device significant location change.
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            print(#function)
            LocationService.shared.startLocationUpdate()
            LocationService.shared.locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func keyboardSettings() {
        // IQKeyboard settings...
        //Enabling keyboard manager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
        
        //Enabling autoToolbar behaviour. If It is set to NO. You have to manually create IQToolbar for keyboard.
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
        
        //Setting toolbar behavious to IQAutoToolbarBySubviews. Set it to IQAutoToolbarByTag to manage previous/next according to UITextField's tag property in increasing order.
        IQKeyboardManager.shared.toolbarManageBehaviour = .bySubviews
        
        //Resign textField if touched outside of UITextField/UITextView.
        //IQKeyboardManager.shared.shouldResignOnTouchOutside = true;
        
        //Show TextField placeholder texts on autoToolbar
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
    }

}

// MARK: -  UITabBarControllerDelegate Methods
extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let timeLineVC = (tabBarController.selectedViewController as? UINavigationController)?.visibleViewController as? TimelineViewController else {
            return
        }
        if let viewCntl = (tabBarController.viewControllers?[0] as? UINavigationController)?.children[0] as? ViewController {
            timeLineVC.selectedDate = viewCntl.selectedDate
            timeLineVC.fetchPlaces(selectedDate: viewCntl.selectedDate)
        }
    }
}
