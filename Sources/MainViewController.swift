//
//  MainViewController.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 01.03.16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SideMenu

/// Controls the app's main screen (aka, homepage).
final class MainViewController: AppViewControllerWithToolbar {
	
	@IBOutlet weak private var map: UIImageView!
	@IBOutlet weak private var whiteText: UILabel!
	
	// MARK: - View Controller Lifecyle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setToolbardItems()
		createMenu()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		precondition(User.current != nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		blurUI()
	}
	
	func setToolbardItems() {
		priestAvailabilityButton.addTarget(
			self, action: #selector(self.confessionButtonTapped(_:)),
			forControlEvents: .TouchUpInside)
		
		switch User.current.role {
		case .Priest:
			priestAvailabilityButton.hidden = false
		case .User, .Admin:
			priestAvailabilityButton.hidden = true
		}
	}
	
	@objc private func confessionButtonTapped(buttton: UIButton) {
		performSegueWithIdentifier("provideConfession", sender: self)
	}

	/// Blurs the UI.
	///
	/// Code inspired by:
	/// http://www.ioscreator.com/tutorials/add-blur-effect-ios8-swift
	private func blurUI() {
		guard !(map.subviews.first is UIVisualEffectView) else { return }
		
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
		let blurView = UIVisualEffectView(effect: blurEffect)
		
		blurView.frame = map.bounds
		map.addSubview(blurView)
	}
	
	// MARK: - Left Menu
	
	internal var menuButton: UIBarButtonItem!
	private var sideMenuController: UISideMenuNavigationController!
	
	private func createMenu() {
		let menuImage = UIImage(named: "menu_icon")!
		let navigationBar = navigationController.navigationBar
		menuButton = navigationBar.highlightedBarButtonWithImage(
			menuImage, width: 33, hightlightIntensity: 0.3)
		menuButton.buttonView.addTarget(
			self,
			action: #selector(MainViewController.menuButtonTapped(_:)),
			forControlEvents: UIControlEvents.TouchUpInside
		)
		menuButton.enabled = true

		navigationItem.leftBarButtonItems = [menuButton]
		MenuViewController.createFor(mainController: self)
	}
	
	@objc func menuButtonTapped(sender: UIButton) {
		assert(sender === menuButton.buttonView)
		presentViewController(SideMenuManager.menuLeftNavigationController!,
		                      animated: true, completion: nil)
    }
}
