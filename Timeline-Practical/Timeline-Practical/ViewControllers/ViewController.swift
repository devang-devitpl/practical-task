//
//  ViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit
import CoreLocation
import GoogleMaps

class ViewController: UIViewController {
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var mapView: GMSMapView!
    
    lazy var arrPlaces: [Places] = []
    
    var locationManager = LocationService.shared

    var currentLocation: CLLocation?
    lazy var selectedDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        locationPermission()
        
        if let tabBarController = self.navigationController?.tabBarController, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            tabBarController.delegate = appDelegate
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arrPlaces = DBManager.fetchPlaces(selectedDate: selectedDate)
        
        DispatchQueue.main.async {
            self.drawPolylinesOnGoogleMap()
        }
        getUserLocation()
    }
}

// MARK: Custom Methods
extension ViewController {
    
    @IBAction func calendarTapped(_ sender: UIBarButtonItem) {
        datePickerView.isHidden = false
        toolbar.isHidden = false
        datePicker.isHidden = false
    }
    
    @IBAction func toolbarDoneTapped(_ sender: UIBarButtonItem) {
        datePickerView.isHidden = true
        toolbar.isHidden = true
        datePicker.isHidden = true
     
        self.navigationController?.navigationBar.topItem?.title = selectedDate

        arrPlaces = DBManager.fetchPlaces(selectedDate: selectedDate)
        drawPolylinesOnGoogleMap()
    }
    
    @IBAction func addPlaceTapped(_ sender: UIBarButtonItem) {
        guard let addPlaceVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaceViewController") as? AddPlaceViewController else {
            return
        }
        addPlaceVC.selectedDate = selectedDate
//        addPlaceVC.currentLocation = currentLocation
        self.navigationController?.pushViewController(addPlaceVC, animated: true)
     }
    
    @IBAction func settingTapped(_ sender: UIBarButtonItem) {
        guard let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else {
            return
        }
        self.navigationController?.pushViewController(settingViewController, animated: true)
    }

    
    @IBAction func handleDateSelection(_ sender: UIDatePicker) {
        selectedDate = sender.date.toString(formateType: DateFormate.titleDate)
    }
    
    private func configureUI() {
        toolbar.isHidden = true
        datePicker.isHidden = true
        datePickerView.isHidden = true
        
        datePicker.maximumDate = Date()
        self.navigationController?.navigationBar.topItem?.title = Date().toString(formateType: DateFormate.titleDate)
        selectedDate = Date().toString(formateType: DateFormate.titleDate)
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
 
            if let currentLocation = self.locationManager.currentLocation {
                self.currentLocation = currentLocation
            }
           
            let dicRequestAddPlace: [String: Any] = ["startTime": location.timestamp.toString(formateType: .HH_MM),
                                                     "endTime": location.timestamp.toString(formateType: .HH_MM),
                                                     "lat": location.coordinate.latitude,
                                                     "lng": location.coordinate.longitude,
                                                     "date": self.selectedDate]
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            if let lastPlace = self.arrPlaces.last, lat == lastPlace.latitude, lng == lastPlace.longitude,
               lastPlace.date == Date().toString(formateType: DateFormate.titleDate) {
                
                print("same place found, update in local DB")
                DBManager.updatePlace(dicRequest: dicRequestAddPlace)
                return
            }

            location.fetchName { name, error in
                if error == nil {
                    
                    let dicRequestAddPlace: [String: Any] = ["name": name ?? "",
                                                             "startTime": location.timestamp.toString(formateType: .HH_MM),
                                                             "endTime": location.timestamp.toString(formateType: .HH_MM),
                                                             "notes": "",
                                                             "lat": location.coordinate.latitude,
                                                             "lng": location.coordinate.longitude,
                                                             "date": self.selectedDate]

                    

                    print("Place added",dicRequestAddPlace)
                    DBManager.addPlace(dicRequest: dicRequestAddPlace)
                    NotificationConst.updateLocationList.postNotification()
                    
                    
                    self.arrPlaces = DBManager.fetchPlaces(selectedDate: self.selectedDate)

                    
                    self.drawPolylineForUpdatedLocation(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                }
            }
        }
    }
    
    private func drawPolylinesOnGoogleMap() {
        mapView.clear()
        let path = GMSMutablePath()
        for place in arrPlaces {
            path.add(CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
            marker.map = mapView

        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5
        polyline.map = mapView
        
        if let place = arrPlaces.last {
            let camera = GMSCameraPosition.camera(withLatitude: place.latitude, longitude: place.longitude, zoom: 20.0)
            mapView.camera = camera
            mapView.animate(to: camera)
        }
    }

    private func drawPolylineForUpdatedLocation(lat: Double, lng: Double) {

        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        marker.map = mapView

        
        let path = GMSMutablePath()
        
        for place in arrPlaces {
            path.add(CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
        }
        
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5
        polyline.map = mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15.0)
        self.mapView.camera = camera
//        self.mapView.animate(to: camera)

    }
    
    private func openLocationServiceSetting() {
        let openSettingAction = UIAlertAction(title: "Open Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        displayAlert(title: "", message: "Location service is disabled. To re-enable, please go to Settings and turn on Location Service for this app.", alertActions: [openSettingAction, cancelAction])
    }
}



