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
//        fetchPlaces(selectedDate: selectedDate)
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
}
