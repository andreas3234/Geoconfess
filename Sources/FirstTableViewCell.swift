//
//  FirstTableViewCell.swift
//  geoconfess
//
//  Created by whitesnow0827 on 3/16/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class FirstTableViewCell : UITableViewCell {

    @IBOutlet weak var textlabel: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code.
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state.
    }
	
    func fillForMenuMood(menuMood: MenuMood) {
		switch menuMood {
		case .Standard:
			textlabel.text = "Qu’est ce que la confession ?"
		default:
			textlabel.text = "Profil"
		}
    }
}
