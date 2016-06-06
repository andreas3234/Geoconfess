//
//  MenuViewController.swift
//  geoconfess
//
//  Created by whitesnow0827 on 3/16/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(index : Int32)
}

enum MenuMood {
    case Standard
	case Reglages
}

// TODO: This REALLY needs some refactoring.

final class OldMenuViewController: UIViewController,
								   UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var surNameTextField: UILabel!
    
    @IBOutlet weak var tblMenuOptions: UITableView!
    @IBOutlet weak var btnCloseMenuOverlay: UIButton!

    @IBOutlet weak var backButton: UIButton!
	
	private var mainVC: MainViewController!
    private var commonUserGPSVC: CommonUserGPSTrackingVC!

    private var delegate : SlideMenuDelegate?
    private var menuMood = MenuMood.Standard
	
	static func instantiateViewController(mainVC: MainViewController) -> OldMenuViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewControllerWithIdentifier("MenuViewController")
		let menuVC = vc as! OldMenuViewController
		menuVC.mainVC = mainVC
		return menuVC
	}
    
    static func instantiateViewControllerForCommonUserGPSTrackingVC(mainVC: CommonUserGPSTrackingVC) -> OldMenuViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MenuViewController")
        let menuVC = vc as! OldMenuViewController
        menuVC.commonUserGPSVC = mainVC
        return menuVC
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()

        tblMenuOptions.delegate = self
        tblMenuOptions.dataSource = self
        
        self.nameTextField.text = User.current.name
        self.surNameTextField.text = User.current.surName
        
        let image:UIImage = UIImage(named: "Back Button")!
        image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        backButton.setImage(image, forState: .Normal)
        backButton.tintColor = UIColor.whiteColor();
    }

    @IBAction func backButtonClick(sender: UIButton) {
        menuMood = .Standard
        backButton.hidden = true
        tblMenuOptions.reloadData()
    }
	
    @IBAction func onCloseMenuClick(sender: AnyObject) {
        mainVC.menuButton.tag = 0
        
        if delegate != nil {
            var index = Int32(mainVC.menuButton.tag)
            if mainVC.menuButton == self.btnCloseMenuOverlay {
                index = -1
            }
            delegate!.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.frame = CGRectMake(-UIScreen.mainScreen().bounds.size.width, 0, UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clearColor()
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1;
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menuMood == .Standard {
            return 9
        } else if menuMood == .Reglages {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let btn = UIButton(type: UIButtonType.Custom)
        btn.tag = indexPath.row
        
        if indexPath.row == 0 {
            if menuMood == .Standard {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ConfessionFAQViewController") as! ConfessionFAQViewController
                self.presentViewController(vc, animated: true, completion: nil)
                self.onCloseMenuClick(btn)
            } else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                self.presentViewController(vc, animated: true, completion: nil)
                self.onCloseMenuClick(btn)
            }
        } else if indexPath.row == 1 {
            if menuMood == .Standard {
                self.onCloseMenuClick(btn)
            }else {
                
            }
        } else if indexPath.row == 2 {
            if menuMood == .Standard {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("StaticViewController") as! StaticViewController
                self.presentViewController(vc, animated: true, completion: nil)
                self.onCloseMenuClick(btn)
            } else {
                
            }
        } else if indexPath.row == 3 {
            if menuMood == .Standard {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NotesViewController") as! NotesViewController
                self.presentViewController(vc, animated: true, completion: nil)
                self.onCloseMenuClick(btn)
            } else {
                
            }
        } else if indexPath.row == 6 {
            menuMood = .Reglages
            backButton.hidden = false
            self.tblMenuOptions.reloadData()
		} else if indexPath.row == 8 {
			User.current.logoutInBackground {
				(error) -> Void in
				self.performSegueWithIdentifier("gotoLogin", sender: self)
			}
        } else {
            self.onCloseMenuClick(btn)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("firstcell", forIndexPath: indexPath) as! FirstTableViewCell
            cell.fillForMenuMood(menuMood)
            return cell
        } else if indexPath.row == 1 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("secondcell", forIndexPath: indexPath) as! SecondTableViewCell
            cell.fillForMenuMood(menuMood)
            return cell
        } else if indexPath.row == 2 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("thirdcell", forIndexPath: indexPath) as! ThirdTableViewCell
            cell.fillForMenuMood(menuMood)
            return cell
        } else if indexPath.row == 3 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("forthcell", forIndexPath: indexPath) as! ForthTableViewCell
            cell.fillForMenuMood(menuMood)
            return cell
        } else if indexPath.row == 4 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("fifthcell", forIndexPath: indexPath) as! FifthTableViewCell
            return cell
        } else if indexPath.row == 5 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("sixthcell", forIndexPath: indexPath) as! SixthTableViewCell
            return cell
        } else if indexPath.row == 6 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("seventhcell", forIndexPath: indexPath) as! SeventhTableViewCell
            return cell
        } else if indexPath.row == 7 {
            let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("eighthcell", forIndexPath: indexPath) as! EighthTableViewCell
            return cell
		} else if indexPath.row == 8 {
			let cell = tblMenuOptions.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath) as! EighthTableViewCell
			return cell
		} else {
			preconditionFailure("?")
		}
    }
}
