//
//  AddPlaceViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit
import GoogleMaps

class AddPlaceViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var txtSearchPlace: UITextField!
    @IBOutlet weak var txtStartTime: UITextField!
    @IBOutlet weak var txtEndTime: UITextField!
    
    @IBOutlet weak var btnSend: UIButton!
    
    var startTimeDatePicker: UIDatePicker = UIDatePicker()
    var endTimeDatePicker: UIDatePicker = UIDatePicker()
    
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialDatePicker()
        locationUpdate()
        
        txtSearchPlace.delegate = self
        LocationService.shared.getSingleLocation = { location in
            print("hello",location)
        }

    }

        
    @IBAction func btnSaveTapped(_ sender: UIButton) {
    }
        
    @IBAction func startTimeDidTapped(_ sender: UITextField) {
    }

    @IBAction func endTimeDidTapped(_ sender: UITextField) {
    }
}

// Custom Methods
extension AddPlaceViewController {
    
    private func initialDatePicker() {
        startTimeDatePicker = UIDatePicker()
        startTimeDatePicker.datePickerMode = .time
        startTimeDatePicker.preferredDatePickerStyle = .wheels
        txtStartTime.inputView = startTimeDatePicker
        startTimeDatePicker.addTarget(self, action: #selector(startTimeDatePickerTapped(sender:)), for: .valueChanged)

        endTimeDatePicker = UIDatePicker()
        endTimeDatePicker.datePickerMode = .time
        endTimeDatePicker.preferredDatePickerStyle = .wheels
        txtEndTime.inputView = endTimeDatePicker
        endTimeDatePicker.addTarget(self, action: #selector(endTimeDatePickerTapped(sender:)), for: .valueChanged)
    }
    
    @objc func startTimeDatePickerTapped(sender: UIDatePicker) {
        txtStartTime.text = sender.date.toString(formateType: .HH_MM)
    }
    
    @objc func endTimeDatePickerTapped(sender: UIDatePicker) {
        txtEndTime.text = sender.date.toString(formateType: .HH_MM)
    }
    
    func locationUpdate() {
//        guard let latitude = notification.userInfo?["latitude"] as? CLLocationDegrees, let longitude = notification.userInfo?["longitude"] as? CLLocationDegrees else { return }

        guard let location = currentLocation else {
            return
        }
        print(location)
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
        mapView.camera = camera

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
        mapView.animate(to: camera)
        
    }

}


// MARK: - UITextFieldDelegate Methods
extension AddPlaceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSearchPlace {
            txtSearchPlace.resignFirstResponder()
            
            guard let searchLocatinViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchLocationViewController") as? SearchLocationViewController else {
                return false
            }
            searchLocatinViewController.delegate = self
            searchLocatinViewController.currentLocation = currentLocation
            self.navigationController?.present(searchLocatinViewController, animated: true, completion: nil)

        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtSearchPlace.resignFirstResponder()
    }
}

// MARK: - SearchLocationDelegate Methods
extension AddPlaceViewController: SearchLocationDelegate {
    func searchLocation(location: SearchLocation) {
        txtSearchPlace.text = location.name ?? ""
        
        mapView.clear()
        let loc = CLLocation(latitude: location.geometry?.location?.lat ?? 0, longitude: location.geometry?.location?.lng ?? 0)
        currentLocation = loc
        locationUpdate()
    }    
}
