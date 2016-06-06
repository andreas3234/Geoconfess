//
//  SpotsTableViewCell.swift
//  geoconfess
//
//  Created by MobileGod on 4/16/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import SwiftyJSON

class SpotsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSpotName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
