//
//  ContactsTableViewCell.swift
//  geoconfess
//
//  Created by Arman Manukyan on 3/17/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import APAddressBook
protocol ContactTabelViewCellDelegate {
    func contactSelectUnselect(_appContact:APContact)
}
class ContactsTableViewCell: UITableViewCell {

    var appContact:APContact?
    var isSelectedContact:Bool = false
    var delegate:ContactTabelViewCellDelegate?
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func btnContactClick(sender: UIButton) {
        isSelectedContact = !isSelectedContact
        changeSelectedMood()
        
        if (delegate != nil) {
            delegate?.contactSelectUnselect(appContact!)
        }
        
        isSelectedContact = !isSelectedContact
        self.performSelector(
			#selector(ContactsTableViewCell.changeSelectedMood),
			withObject: nil, afterDelay: 0.3)
    }
    func changeSelectedMood() {
        
        if isSelectedContact {
            self.contentView.backgroundColor = UIColor(red: 241.0 / 255.0, green: 7.0 / 255.0, blue: 5.0 / 255.0, alpha: 1)
            self.mainView.backgroundColor = UIColor(red: 241.0 / 255.0, green: 7.0 / 255.0, blue: 5.0 / 255.0, alpha: 1)
            self.contactName.textColor = UIColor.whiteColor()
        }else {
            self.contentView.backgroundColor = UIColor(red: 235.0 / 255.0, green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1)
            self.mainView.backgroundColor = UIColor.whiteColor()
            self.contactName.textColor = UIColor(red: 88.0 / 255.0, green: 88.0 / 255.0, blue: 88.0 / 255.0, alpha: 1)
        }
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillWithAPContact(_appContact:APContact) {
        appContact = _appContact
        let apName:APName = (appContact?.name)!
        if apName.firstName != nil {
            contactName.text = apName.firstName!.uppercaseString
        }
        if apName.lastName != nil {
            if apName.firstName != nil {
                contactName.text! = contactName.text! + " " + apName.lastName!.uppercaseString
            }else {
                contactName.text! = apName.lastName!.uppercaseString
            }
        }
    }
}