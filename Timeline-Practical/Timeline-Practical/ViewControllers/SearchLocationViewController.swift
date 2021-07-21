//
//  SearchLocationViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 20/07/21.
//

import UIKit
import CoreLocation
import ObjectMapper

protocol SearchLocationDelegate: AnyObject {
    func searchLocation(location: SearchLocation)
}

class SearchLocationViewController: UIViewController {

    @IBOutlet weak var txtSearchPlace: UITextField!
    @IBOutlet weak var tblSearchList: UITableView!
    @IBOutlet weak var lblNoSearchResult: UILabel!

    
    weak var delegate: SearchLocationDelegate?
    
    var currentLocation: CLLocation?
    
    lazy var arrSearchLocation: [SearchLocation] = []
    var locationManager = LocationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let currentLocation = locationManager.currentLocation {
            self.currentLocation = currentLocation
        }

        txtSearchPlace.delegate = self
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: -  Custom Methods
extension SearchLocationViewController {
    private func searchPlacesAPICall(query: String) {
        guard let userLocation = currentLocation else { return }
        let location = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"

        
        DispatchQueue.global(qos: .background).async {
            apiProvider.request(APIService.searchPlaces(location: location, keyword: query, key: apiKey)) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                
                case .success(let response):
                    do {
                        guard let dicResponse = try response.filterSuccessfulStatusCodes().mapJSON() as? [String: Any],
                              let arrResults = dicResponse["results"] as? [[String: Any]]
                              else {
                            return
                        }
                        
                        self.arrSearchLocation = Mapper<SearchLocation>().mapArray(JSONArray: arrResults)
                        
                        DispatchQueue.main.async {
                            self.tblSearchList.dataSource = self
                            self.tblSearchList.delegate = self
                            self.tblSearchList.reloadData()
    
                            self.lblNoSearchResult.isHidden = self.arrSearchLocation.count > 0
                            self.tblSearchList.isHidden = self.arrSearchLocation.count == 0
                        }
                    } catch {
                        self.displayAlert(title: "", message: error.localizedDescription, completion: nil)
                    }
                case .failure(let error):
                    self.displayAlert(title: "", message: error.localizedDescription, completion: nil)
                }
            }
        }
    }
}

// MARK: -  UITextFieldDelegate Methods
extension SearchLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchPlacesAPICall(query: textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        
        return true
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate Methods
extension SearchLocationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearchLocation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        cell.textLabel?.text = arrSearchLocation[indexPath.row].name ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        
        if delegate != nil {
            delegate!.searchLocation(location: arrSearchLocation[indexPath.row])
        }
    }
}
