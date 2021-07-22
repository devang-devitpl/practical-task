//
//  TimelineViewController.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 21/07/21.
//

import UIKit

class TimelineViewController: UIViewController {

    @IBOutlet weak var tblTimeLine: UITableView!
    @IBOutlet weak var lblNoRecordsFound: UILabel!
    
    lazy var arrPlaces: [Places] = []
    var selectedDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblTimeLine.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlaceList), name: NotificationConst.updateLocationList.nsName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fetchPlaces(selectedDate: String) {
        self.navigationController?.navigationBar.topItem?.title = selectedDate

        arrPlaces = DBManager.fetchPlaces(selectedDate: selectedDate)

        reloadData()
    }
    
    func reloadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.tblTimeLine.isHidden = self.arrPlaces.count == 0
            self.lblNoRecordsFound.isHidden = self.arrPlaces.count > 0
            self.tblTimeLine.reloadData()
        })
    }
    
    @objc private func updatePlaceList() {
        fetchPlaces(selectedDate: selectedDate)
    }
    
    private func showAlertOnCellTapped(uuid: String, notes: String, indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Location History", message: "Add Notes", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Notes"
            textField.text = notes
        }

        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let txtNotes = alertController.textFields![0] as UITextField
            if txtNotes.text?.trim().isEmpty ?? false {
                UIApplication.topViewController()?.displayAlert(title: "", message: "Please enter notes", completion: nil)
            } else {
                DBManager.updateNotes(uuid: uuid, notes: txtNotes.text?.trim() ?? "")
                self.arrPlaces[indexPath.row].notes = txtNotes.text?.trim() ?? ""
                self.tblTimeLine.reloadRows(at: [indexPath], with: .automatic)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate Methods
extension TimelineViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let timelineCell = tableView.dequeueReusableCell(withIdentifier: "TimeLineTableViewCell", for: indexPath) as? TimeLineTableViewCell else {
            return UITableViewCell()
        }
        
        timelineCell.set(place: arrPlaces[indexPath.row])
        
        return timelineCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = arrPlaces[indexPath.row]
        showAlertOnCellTapped(uuid: place.uuid ?? "", notes: place.notes ?? "", indexPath: indexPath)
    }
}
