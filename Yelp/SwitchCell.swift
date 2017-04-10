//
//  SwitchCell.swift
//  Yelp
//
//  Created by Sabareesh Kappagantu on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var innerView: UIView!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        innerView.layer.cornerRadius = 8
        innerView.layer.masksToBounds = true
        innerView.layer.borderWidth = 2
        innerView.layer.borderColor = UIColor.red.cgColor
        onSwitch.addTarget(self, action: #selector(switchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        print("Switch Value Changed")
        if delegate != nil {
            delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
        }
    }

}
