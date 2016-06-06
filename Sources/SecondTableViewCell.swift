//
//  SecondTableViewCell.swift
//  geoconfess
//
//  Created by whitesnow0827 on 3/16/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

class SecondTableViewCell: UITableViewCell {

    @IBOutlet weak var textlabel: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillForMenuMood(menuMood:MenuMood) {
        if menuMood == .Standard {
            self.textlabel.text = "Faire un don"
            self.textlabel.textColor = UIColor.init(red: 241.0 / 255, green: 104.0 / 255, blue: 25.0 / 255, alpha: 1)
            self.textlabel.font = UIFont.boldSystemFontOfSize(17.0)
        }else {
            self.textlabel.text = "Notifcations"
            self.textlabel.textColor = UIColor.init(red: 88.0 / 255, green: 88.0 / 255, blue: 88.0 / 255, alpha: 1)
            self.textlabel.font = UIFont.systemFontOfSize(17)
        }
    }

}
