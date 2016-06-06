//
//  NotificationCell.swift
//  GeoConfess
//
//  Created by Christian Dimitrov on 4/19/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class NotificationCell: UITableViewCell {
	
    @IBOutlet weak private var priestIcon: UIImageView!
    @IBOutlet weak private var lblPriestName: UILabel!
    @IBOutlet weak private var lblStatus: UILabel!
    @IBOutlet weak private var lblDistance: UILabel!
    @IBOutlet weak private var lblNextImage: UIImageView!
    
    var isViewed: Bool = false
    var notificationData: Notification!
    
    /// Initialization code.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Discovered Notification Cell will be shown with bold font.
        if !isViewed {
            lblPriestName.textColor = UIColor.blackColor()
            lblStatus.textColor     = UIColor.blackColor()
            lblDistance.textColor   = UIColor.blackColor()
        } else {
            lblPriestName.textColor = UIColor.grayColor()
            lblStatus.textColor     = UIColor.grayColor()
            lblDistance.textColor   = UIColor.grayColor()
        }

		priestIcon.image   = UIImage(named: "logo-couleur-liste");
		lblNextImage.image = UIImage(named: "lblNext")
		backgroundColor    = UIColor.whiteColor()
    }
    
    /// Configure the view for the selected state.
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.lblPriestName.textColor = UIColor.whiteColor()
            self.lblStatus.textColor = UIColor.whiteColor()
            self.lblDistance.textColor = UIColor.whiteColor()
            self.lblNextImage.image = UIImage(named: "selectedLblNext")
            self.priestIcon.image = UIImage(named: "logo-blanc-liste");
            
            self.backgroundColor = UIColor.redColor()
        } else {
            self.lblPriestName.textColor = UIColor.grayColor()
            self.lblStatus.textColor = UIColor.grayColor()
            self.lblDistance.textColor = UIColor.grayColor()
            self.lblNextImage.image = UIImage(named: "lblNext")
            self.priestIcon.image = UIImage(named: "logo-couleur-liste");

            self.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func setNotificationInfo(notificationInfo: Notification) {
        notificationData = notificationInfo
        
        lblPriestName.text = (notificationData.content as! MeetRequestNotification).priest.surname
        lblDistance.text = String(format: "à %d mètres", integer_t(calculateDistance()))
		
		switch User.current.role {
		case .Priest:
			if (notificationData.content as! MeetRequestNotification).status == "pending" {
				lblStatus.text = "Demande envoyée"
			} else if (notificationData.content as! MeetRequestNotification).status == "refused" {
				lblStatus.text = "Demande refusée"
			} else {
				lblStatus.text = "Demande acceptée"
			}
		case .User, .Admin:
			if (notificationData.content as! MeetRequestNotification).status == "pending" {
				lblStatus.text = "Demande reçue"
			} else if (notificationData.content as! MeetRequestNotification).status == "refused" {
				lblStatus.text = "Demande refusée"
			} else {
				lblStatus.text = "Demande accepté"
			}
		}
    }

	/// Calculate distance from priest to penitent.
    func calculateDistance() -> CLLocationDistance {
        let priestLocation = User.current.location!
		let penitent = (notificationData.content as! MeetRequestNotification).penitent
		let penitentLocation = CLLocation(at: penitent.location)
		return penitentLocation.distanceFromLocation(priestLocation)
    }
}