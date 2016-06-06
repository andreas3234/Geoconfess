//
//  ThirdTableViewCell.swift
//  geoconfess
//
//  Created by whitesnow0827 on 3/16/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

class ThirdTableViewCell: UITableViewCell {

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
            self.textlabel.text = "Préparer sa confession"
        }else {
            self.textlabel.text = "Connexio"
        }
    }
}
