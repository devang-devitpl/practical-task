//
//  SettingsViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 21/07/21.
//

import UIKit
import CoreLocation

class SettingsViewController: UIViewController {

    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let arrAccuries: [String] = ["Accuracy Best for Navigation", "Accuracy Best", "Accuracy Nearest 10 Meter", "Accuracy 100 Meter", "Accuracy 1 KiloMeter", "Accuracy 3 KiloMeter"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let formatted = String(format: "%.0f", sender.value)

        lblDistance.text = "\(formatted) m"
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "distanceFilter"), object: nil, userInfo: ["value": formatted])
    }
    
    private func configureUI() {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        distanceSlider.value = 100
        lblDistance.text = "\(String(format: "%.0f", distanceSlider.value)) m"
        self.title = "Settings"
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource Methods
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrAccuries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrAccuries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var aacuracy: CLLocationAccuracy = LocationAccuracy.bestForNavigation.accuracy
        let value = arrAccuries[row]
        
        if value == "Accuracy Best for Navigation" {
            aacuracy = LocationAccuracy.bestForNavigation.accuracy
        } else if value == "Accuracy Best" {
            aacuracy = LocationAccuracy.accuracyBest.accuracy
        } else if value == "Accuracy Nearest 10 Meter" {
            aacuracy = LocationAccuracy.tenMeter.accuracy
        } else if value == "Accuracy 100 Meter" {
            aacuracy = LocationAccuracy.hundredMeter.accuracy
        } else if value == "Accuracy 1 KiloMeter" {
            aacuracy = LocationAccuracy.oneKm.accuracy
        } else {
            aacuracy = LocationAccuracy.threeKm.accuracy
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "accuracy"), object: nil, userInfo: ["value": aacuracy])
    }

}
