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
        locationManager?.distanceFilter = 10.0
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.pausesLocationUpdatesAutomatically = false
    }
    
    func startLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }

    func stopLocationUpdate() {
        locationManager?.stopUpdatingLocation()
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
        if let userUpdatedLocation = locations.last{ //, !isLocationFetched {
            currentUserLocation?(userUpdatedLocation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: Failed to get User current Location \(error.localizedDescription)")
        failedToGetLocation?()
    }
}

