//
//  TimeLineTableViewCell.swift
//  Timeline-Practical
//
//  Created by devangs.bhatt on 21/07/21.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLatLng: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.mainView.setDropShadow(radius: 3.0)
        }
    }
    
    func set(place: Places) {
        lblName.text = place.name ?? ""
        lblLatLng.text = "\(place.latitude), \(place.longitude)"
        lblTime.text = "\(place.startTime ?? "") - \(place.endTime ?? "")"
    }
}
