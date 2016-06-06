//
//  MenuItemCell.swift
//  GeoConfess
//
//  Created by Paulo Mattos on 05/04/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import SideMenu

/// A cell in the table controlled by `LeftMenuViewController`.
final class MenuItemCell: UITableViewVibrantCell {

	@IBOutlet weak var itemName: UILabel!
	@IBOutlet weak var arrow: UIImageView!
	
	/// Initialization code.
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	/// Configure the view for the selected state.
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

/// Menu item identifier.
enum MenuItem: UInt {
	
	case ConfessionFAQ   = 0
	case MakeDonation    = 1
	case ConfessionNotes = 2
	case Notes           = 3
	case Favorites       = 4
	case Share           = 5
	case Settings        = 6
	case Help            = 7
	case Logout          = 8
	
	static let members = [
		ConfessionFAQ, MakeDonation, ConfessionNotes,
		Notes, Favorites, Share,
		Settings, Help, Logout]
	
	init!(rowIndex rawValue: Int) {
		self.init(rawValue: UInt(rawValue))
	}
	
	var rowIndex: Int {
		return Int(rawValue)
	}
	
	var cellIdentifier: String {
		return "MenuItemCell"
	}
	
	var localizedName: String {
		switch self {
		case .ConfessionFAQ:
			return "Qu’est-ce que la confession"
		case .MakeDonation:
			return "Faire un don"
		case .ConfessionNotes:
			return "Préparer sa confession"
		case .Notes:
			return "Notes"
		case .Favorites:
			return "Favoris"
		case .Share:
			return "Partager"
		case .Settings:
			return "Reglages"
		case .Help:
			return "Aide"
		case .Logout:
			return "Se déconnecter"
		}
	}
}

