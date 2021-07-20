//
//  ViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    lazy var arrLocations: [[String: Any]] = []

    var locationManager = LocationService.shared
    //var datePicker = UIDatePicker()
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationPermission()
        toolbar.isHidden = true
        datePicker.isHidden = true
        self.title = Date().toString(formateType: DateFormate.titleDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserLocation()
    }
}

// MARK: Custom Methods
extension ViewController {
    
    @IBAction func calendarTapped(_ sender: UIBarButtonItem) {
        toolbar.isHidden = false
        datePicker.isHidden = false
    }
    
    @IBAction func toolbarDoneTapped(_ sender: UIBarButtonItem) {
        toolbar.isHidden = true
        datePicker.isHidden = true
    }
    
    @IBAction func addPlaceTapped(_ sender: UIBarButtonItem) {
        guard let addPlaceVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaceViewController") as? AddPlaceViewController else {
            return
        }
        addPlaceVC.currentLocation = currentLocation
        self.navigationController?.pushViewController(addPlaceVC, animated: true)
     }
    
    @IBAction func handleDateSelection(_ sender: UIDatePicker) {
        self.title = sender.date.toString(formateType: DateFormate.titleDate)
    }

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
//                self.locationManager.requestSingleLocationUpdate()
            @unknown default: return
            }
        }
    }

    
    private func getUserLocation() {
        locationManager.currentUserLocation = { [weak self] location in
            
            guard let `self` = self else { return }
 
            print("Latitude:", location.coordinate.latitude)
            print("Longitude:", location.coordinate.longitude)
            
            self.arrLocations.append(location.dictionaryRepresentation)
            print(self.arrLocations.count)
        }
        
        locationManager.getSingleLocation = { [weak self] location in
            guard let `self` = self else { return }
            self.currentLocation = location
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



