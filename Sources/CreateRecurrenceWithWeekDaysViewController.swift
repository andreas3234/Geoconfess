//
//  CreateRecurrenceWithDaysViewController.swift
//  geoconfess
//
//  Created by MobileGod on 4/10/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import DownPicker
import SwiftyJSON

class CreateRecurrenceWithWeekDaysViewController: AppViewControllerWithToolbar, CreateRecurrenceWithWeekDaysDelegate, UpdateRecurrenceWithWeekDaysDelegate, ShowAlertViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        // Buttons of Days
    @IBOutlet weak var btnMonDay: UIButton!
    @IBOutlet weak var btnTueDay: UIButton!
    @IBOutlet weak var btnWedDay: UIButton!
    @IBOutlet weak var btnThuDay: UIButton!
    @IBOutlet weak var btnFriDay: UIButton!
    @IBOutlet weak var btnSatDay: UIButton!
    @IBOutlet weak var btnSunDay: UIButton!
    
        // DropDownList TextFields
    @IBOutlet weak var txtStartHour: UITextField!
    @IBOutlet weak var txtStartMins: UITextField!
    @IBOutlet weak var txtStopHour: UITextField!
    @IBOutlet weak var txtStopMins: UITextField!
    
        // DownPicker Controllers
    var startHourPicker: DownPicker!
    var startMinsPicker: DownPicker!
    var stopHourPicker: DownPicker!
    var stopMinsPicker: DownPicker!
    
        // Checked image and Unchecked image
    let imgChecked: UIImage = UIImage(named: "icn_Checked")!
    let imgUnChecked: UIImage = UIImage(named: "icn_UnChecked")!
    
        // arrays of Days and Checked states
    let arrDays = ["Lundi", "Mercredi", "Vendredi", "Dimanche", "Mardi", "Jeudi", "Samedi"]
    let arrWeekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var arrChecks: [Bool]!
    
        // Spot ID, recurrenceID, isCreatePage
    var spotID: Int64!
    var recurrenceID: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        // DownPicker Initializes
        var arrHours: [NSString] = []
        for i in 0...23 {
            
            arrHours.append("\(i)")
        }
        
        var arrMins: [NSString] = []
        for i in 0...59{
            
            arrMins.append("\(i)")
        }
        
        self.startHourPicker = DownPicker(textField: txtStartHour, withData: arrHours)
        self.startMinsPicker = DownPicker(textField: txtStartMins, withData: arrMins)
        self.stopHourPicker = DownPicker(textField: txtStopHour, withData: arrHours)
        self.stopMinsPicker = DownPicker(textField: txtStopMins, withData: arrMins)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if appDelegate.isCreatePage {
            
            arrChecks = [false, false, false, false, false, false, false]
            
            // Initialize TextFields
            txtStartHour.text = appDelegate.startHour
            txtStartMins.text = appDelegate.startMins
            txtStopHour.text = appDelegate.stopHour
            txtStopMins.text = appDelegate.stopMins
        }else{
            
            arrChecks = appDelegate.arrChecks
        }
        // Initialize DayButtons
        self.SetDayButton(btnMonDay, checked: arrChecks[0])
        self.SetDayButton(btnTueDay, checked: arrChecks[1])
        self.SetDayButton(btnWedDay, checked: arrChecks[2])
        self.SetDayButton(btnThuDay, checked: arrChecks[3])
        self.SetDayButton(btnFriDay, checked: arrChecks[4])
        self.SetDayButton(btnSatDay, checked: arrChecks[5])
        self.SetDayButton(btnSunDay, checked: arrChecks[6])
        
        // Initialize Delegate
        Networking.createRecurrenceWithWeekDaysDelegate = self
        Networking.updateRecurrenceWithWeekDaysDelegate = self
        Utility.alertViewDelegate = self

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Create Recurrence with WeekDays
    @IBAction func onCreateRecurrenceWithWeekDays(sender: AnyObject) {
        
        var weekDays : [NSString] = []
        for i in 0...6 {
            
            if arrChecks[i] == true{
                
                weekDays.append(arrWeekDays[i])
            }
        }
        
        if weekDays.count == 0 {
    
            showAlert(title: "Please select Weekdays", message: "", ok: {
                return
            })
        }
        
        if !enableTime(){
            
            showAlert(title: "Error", message: "Select Start time and Stop time correctly.", ok: {
                return
            })
        }
        
        if appDelegate.isCreatePage {
            
            Utility.showYesNoAlert("Create a recurrence?", message: "", vc: self)
        }else{
            
            Utility.showYesNoAlert("Update a recurrence?", message: "", vc: self)
        }
    }
    
    // MARK: - AlertDelegate Methods
    func alertViewDidTapped(didTappedYes:Bool){
    
        if didTappedYes {           
            
            var weekDays : [NSString] = []
            for i in 0...6 {
                
                if arrChecks[i] == true{
                    
                    weekDays.append(arrWeekDays[i])
                }
            }
                
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            let start_at: String = txtStartHour.text! + ":" + txtStartMins.text!
            let stop_at: String = txtStopHour.text! + ":" + txtStopMins.text!
            
            if appDelegate.isCreatePage || appDelegate.recurrenceID < 0{
                
                Networking.createRecurrence_WeekDays(self.spotID, days: weekDays, start_at: start_at, stop_at: stop_at)
            }else{
                
                Networking.updateRecurrence_WeekDays(appDelegate.recurrenceID, days: weekDays, start_at: start_at, stop_at: stop_at)
            }
        }
    }

    // MARK: - CreateRecurrenceWithWeekDays Delegate Methods
    func createRecurrenceWithWeekDaysDidSucceed(data: JSON) {
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        showAlert(title: "Success", message: "You created a recurrence successfully") {
			let viewControllersStack = self.navigationController!.viewControllers
			for vc in viewControllersStack {
				if let spotsVC = vc as? SpotsTableViewController {
					self.navigationController?.popToViewController(spotsVC,
					                                               animated: true)
				}
			}
        }
    }
    
    func createRecurrenceWithWeekDaysDidFail(error: NSError) {
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if error.code == -1003
        {
            Utility.showAlert("Error", message: "Your internet does not seem to be working.", vc: self)
        }else{
            Utility.showAlert("Error", message: error.localizedDescription, vc: self)
        }
        
    }
    
    // MARK: - UpdateRecurrenceWithDateDelegate Methods
    func updateRecurrenceWithWeekDaysDidSucceed(data: JSON) {
             
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        appDelegate.date = ""
        appDelegate.arrChecks = arrChecks
        showAlert(title: "Success", message: "You updated a recurrence successfully")
    }
    
    func updateRecurrenceWithWeekDaysDidFail(error: NSError) {
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if error.code == -1003
        {
            Utility.showAlert("Error", message: "Your internet does not seem to be working.", vc: self)
        }else{
            Utility.showAlert("Error", message: error.localizedDescription, vc: self)
        }
    }
    
    // Set DayButton with checked state
    func SetDayButton(btn: UIButton, checked: Bool){
    
        let btnSize = CGSize(width: self.view.bounds.size.width * 0.5 * 0.7, height: 20.0)  // You can check this formular from autolayout of Storyboard
        let imgSize = CGSize(width: imgChecked.size.width, height: imgChecked.size.height)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: btnSize.width - btnSize.height)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: btnSize.height - imgSize.width, bottom: 0, right: 0)
        
        if checked  {
            btn.setImage(UIImage(named: "icn_Checked"), forState: .Normal)
        }else{
            btn.setImage(UIImage(named: "icn_UnChecked"), forState: .Normal)
        }
        
        btn.setTitle(arrDays[btn.tag], forState: .Normal)
    }
    
    // Change DayButton State
    @IBAction func ChangeStateDayButton(btn: UIButton) {
        
        arrChecks[btn.tag] = !arrChecks[btn.tag]
        self.SetDayButton(btn, checked: arrChecks[btn.tag])
    }
    
    // MARK: - Check the time
    func enableTime() -> Bool{
        
        return (Int(txtStopHour.text!)! * 60 + Int(txtStopMins.text!)!
            - Int(txtStartHour.text!)! * 60 - Int(txtStartMins.text!)!) > 0
    }
}

