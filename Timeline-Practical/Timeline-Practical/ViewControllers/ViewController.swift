//
//  ViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit

class ViewController: UIViewController {

    lazy var arrLocations: [[String: Any]] = []

    var locationManager = LocationService.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserLocation()
    }
}

// MARK: Custom Methods
extension ViewController {
    
    private func locationPermission() {
        locationManager.changeAuthorizationStatus = { [weak self] (authorizationStatus) in
            guard let `self` = self else { return }
            switch authorizationStatus {
            
            case .notDetermined, .restricted:
                return
            case .denied:
                self.locationManager.stopLocationUpdate()
                // Ask again for location permission
                self.openLocationServiceSetting()
            case .authorizedAlways, .authorizedWhenInUse: return
            @unknown default: return
            }
        }
    }

    
    private func getUserLocation() {
        locationManager.currentUserLocation = { [weak self] location in
            
            guard let `self` = self else { return }
 
            print("Latitude:", location.coordinate.latitude)
            print("Longitude:", location.coordinate.longitude)
            
            let userlocation: [String: Any] = ["latitude": location.coordinate.latitude,
                                               "longitude": location.coordinate.longitude]
            
            self.arrLocations.append(userlocation)
            print(self.arrLocations.count)
        }
    }
    
    private func openLocationServiceSetting() {
        let openSettingAction = UIAlertAction(title: "Open Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        displayAlert(title: "", message: "Location service is disabled. To re-enable, please go to Settings and turn on Location Service for this app.", alertActions: [openSettingAction, cancelAction])
    }
}



