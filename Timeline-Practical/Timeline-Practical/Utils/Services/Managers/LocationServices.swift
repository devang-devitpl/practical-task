//
//  LocationServices.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import Foundation
import UIKit
import CoreLocation


class LocationService: NSObject {

    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var lastUserLocation: CLLocation?
    var currentUserLocation: ((CLLocation) -> ())?
    var getSingleLocation: ((CLLocation) -> ())?
    var failedToGetLocation: (() -> ())?
    var changeAuthorizationStatus : ((CLAuthorizationStatus) -> ())?
    var isLocationFetched: Bool = false
    
    var isRemainToTakeLocationPermision: Bool {
        guard locationManager != nil else {
            return false
        }
        return (locationManager!.authorizationStatus == .notDetermined || locationManager!.authorizationStatus == .denied || locationManager!.authorizationStatus == .restricted) //Location permision popup displayed?
    }

    var isLocationPermissionGiven : Bool {
        guard locationManager != nil else {
            return false
        }

        if CLLocationManager.locationServicesEnabled() {
            if locationManager!.authorizationStatus == .authorizedAlways || locationManager!.authorizationStatus == .authorizedWhenInUse {
                return true
            }
        }
        return false
    }

    static let shared = LocationService()

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.delegate = self
        locationManager?.distanceFilter = 50.0
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.pausesLocationUpdatesAutomatically = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(distanceFilterValueChanged(notification:)), name: NSNotification.Name.init("distanceFilter"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(accuracyChanged(notification:)), name: NSNotification.Name.init("accuracy"), object: nil)

    }
    
    func startLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }

    func stopLocationUpdate() {
        locationManager?.stopUpdatingLocation()
    }
    
    @objc func distanceFilterValueChanged(notification: Notification) {
        guard let dicUserInfo = notification.userInfo,
              let filterValue = dicUserInfo["value"] as? String else {
            return
        }
        locationManager?.distanceFilter = Double(filterValue) ?? 10.0
    }
    
    @objc func accuracyChanged(notification: Notification) {
        guard let dicUserInfo = notification.userInfo,
              let accuracy = dicUserInfo["value"] as? CLLocationAccuracy else {
            return
        }
        print(accuracy)
        locationManager?.desiredAccuracy = accuracy
    }
}

//MARK:- CLLocationManagerDelegate Methods
extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        isLocationFetched = false
        switch status {
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
            case .restricted, .denied:
                //User is not allowed access of location
                locationManager?.stopUpdatingLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager?.startUpdatingLocation()
        @unknown default: break
        }
        changeAuthorizationStatus?(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        if let userUpdatedLocation = locations.last {
            currentUserLocation?(userUpdatedLocation)
        }
        
        if let userUpdatedLocation = locations.last, !isLocationFetched {
            getSingleLocation?(userUpdatedLocation)
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: Failed to get User current Location \(error.localizedDescription)")
        failedToGetLocation?()
    }
}

extension CLLocation {
    /// Returns a dictionary representation of the location.
    public var dictionaryRepresentation: [String: Any] {
        var locationDictionary: [String: Any] = [:]
        locationDictionary["latitude"] = coordinate.latitude
        locationDictionary["longitude"] = coordinate.longitude
        return locationDictionary
    }
    
    func fetchName(completion: @escaping (_ name: String?, _ error: Error?) -> ()) {
        
        CLGeocoder().reverseGeocodeLocation(self) {
            completion($0?.first?.name, $1)
        }
    }
}
