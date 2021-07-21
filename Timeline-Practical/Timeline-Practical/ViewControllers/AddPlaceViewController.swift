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
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    
    var startTimeDatePicker: UIDatePicker = UIDatePicker()
    var endTimeDatePicker: UIDatePicker = UIDatePicker()
    
    var currentLocation: CLLocation?
    var selectedDate: String = ""

    var locationManager = LocationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentLocation = locationManager.currentLocation {
            self.currentLocation = currentLocation
        }
        configureUI()
        initialDatePicker()
        locationUpdate()
        
        txtSearchPlace.delegate = self
    }

    @IBAction func btnSaveTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let location = currentLocation else {
            return
        }

        
        if isValid() {
            let dicRequestAddPlace: [String: Any] = ["name": txtSearchPlace.text?.trim() ?? "",
                                                     "startTime": txtStartTime.text?.trim() ?? "",
                                                     "endTime": txtEndTime.text?.trim() ?? "",
                                                     "notes": txtNotes.text.trim(),
                                                     "lat": location.coordinate.latitude,
                                                     "lng": location.coordinate.longitude,
                                                     "date": selectedDate]
            print(dicRequestAddPlace)
            
            DBManager.addPlace(dicRequest: dicRequestAddPlace)
        }
    }

}

// Custom Methods
extension AddPlaceViewController {
    
    private func configureUI() {
        DispatchQueue.main.async {
            self.txtNotes.layer.cornerRadius = 3.0
            self.txtNotes.layer.borderWidth = 1.0
            self.txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        mapView.delegate = self
    }
    
    private func initialDatePicker() {
        startTimeDatePicker = UIDatePicker()
        startTimeDatePicker.datePickerMode = .time
        startTimeDatePicker.preferredDatePickerStyle = .wheels
        startTimeDatePicker.maximumDate = Date()
        txtStartTime.inputView = startTimeDatePicker
        startTimeDatePicker.addTarget(self, action: #selector(startTimeDatePickerTapped(sender:)), for: .valueChanged)

        endTimeDatePicker = UIDatePicker()
        endTimeDatePicker.datePickerMode = .time
        endTimeDatePicker.preferredDatePickerStyle = .wheels
        endTimeDatePicker.maximumDate = Date()
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
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 20.0)
        mapView.camera = camera

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.isDraggable = true
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
        mapView.animate(to: camera)
        
    }

    private func isValid() -> Bool {
        
        if txtSearchPlace.text?.trim().isEmpty ?? false {
            
            displayAlert(title: "", message: "Please search the place", completion: nil)
            return false
        }
        
        if txtStartTime.text?.trim().isEmpty ?? false {
            
            displayAlert(title: "", message: "Please select start time", completion: nil)
            return false
        }
        
        if txtEndTime.text?.trim().isEmpty ?? false {
            
            displayAlert(title: "", message: "Please select end time", completion: nil)
            return false
        }
        
        if txtStartTime.text!.trim().toDate(format: .HH_MM)?.compare(txtEndTime.text!.toDate(format: .HH_MM) ?? Date()) == .orderedDescending {
            
            displayAlert(title: "", message: "End time should be greater then start time", completion: nil)
            return false
        }
        
        if txtNotes.text.trim().isEmpty || txtNotes.text == "Notes" {
            
            displayAlert(title: "", message: "Please enter notes", completion: nil)
            return false
        }
        
        return true
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

// MARK: - UITextViewDelegate Methods
extension AddPlaceViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text == "Notes" ? "Notes" : textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - GMSMapViewDelegate Methodss
extension AddPlaceViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        let location = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        currentLocation = location
        location.fetchName { [weak self] name, error in
            guard let `self` = self else { return }
            if error == nil {
                self.txtSearchPlace.text = name
            }
        }
    }
}
