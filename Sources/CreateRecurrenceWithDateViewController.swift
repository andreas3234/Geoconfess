//
//  CreateRecurrenceWithDateViewController.swift
//  GeoConfess
//
//  Created by MobileGod on 4/8/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import DownPicker
import CoreLocation
import SwiftyJSON

final class CreateRecurrenceWithDateViewController: AppViewControllerWithToolbar,
	CreateRecurrentWithDateDelegate, ShowAlertViewDelegate,
	UpdateRecurrenceWithDateDelegate {
    
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtStartHour: UITextField!
    @IBOutlet weak var txtStartMins: UITextField!
    @IBOutlet weak var txtStopHour: UITextField!
    @IBOutlet weak var txtStopMins: UITextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var startHourPicker: DownPicker!
    var startMinsPicker: DownPicker!
    var stopHourPicker: DownPicker!
    var stopMinsPicker: DownPicker!
    
    let datePickerView  : UIDatePicker = UIDatePicker()
    var _previousSelectedString: String!
    
    // Data received from previous view controller
    var receivedRecurrence: Recurrence!
  
    // Spot ID, recurrenceID
    var spotID: Int64!
    var recurrenceID: Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DownPicker Initializes
        var arrHours: [NSString] = []
        for i in 0...23  {
            arrHours.append(NSString(format: "%02d", i))
        }
        
        var arrMins: [NSString] = []
        for i in 0...59 {
            arrMins.append(NSString(format: "%02d", i))
        }
        
        self.startHourPicker = DownPicker(textField: txtStartHour, withData: arrHours)
        self.startMinsPicker = DownPicker(textField: txtStartMins, withData: arrMins)
        self.stopHourPicker = DownPicker(textField: txtStopHour, withData: arrHours)
        self.stopMinsPicker = DownPicker(textField: txtStopMins, withData: arrMins)
        
        // Initialize DatePicker
        InitDatePicker()
        
        // Make placeholder text color of DateText white
        txtDate.attributedPlaceholder = NSAttributedString(string:"Date", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Delegate
        Networking.createRecurrenceWithDateDelegate = self
        Networking.updateRecurrenceWithDateDelegate = self
        Utility.alertViewDelegate = self
        
        // Initialize TextFields
        if  !appDelegate.isCreatePage{
            
            txtDate.text = appDelegate.date
            txtStartHour.text = appDelegate.startHour
            txtStartMins.text = appDelegate.startMins
            txtStopHour.text = appDelegate.stopHour
            txtStopMins.text = appDelegate.stopMins
        }
    }
	
    // MARK: - Tapping on DateText
    
    @IBAction func onDateText(sender: UITextField) {
        
        //  If textfield is empty, make it current date
        if self.txtDate.text == "" {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            txtDate.text = dateFormatter.stringFromDate(NSDate())
        }
        
        //  Remember current text date
        _previousSelectedString = self.txtDate.text
    }
    
    @IBAction func onCreateRecurrencesWithWeekDays(sender: AnyObject) {
        performSegueWithIdentifier("gotoAddRecurrencesWithWeekDays", sender: self)
    }
	
    @IBAction func onCreateRecurrenceWithDate(sender: AnyObject) {
        if txtDate.text == "" {
            showAlert(title: "Please select date", message: "")
        }
        
        if !enableTime() {
            showAlert(title: "Error", message: "Select Start time and Stop time correctly.")
        }
        if appDelegate.isCreatePage {
            Utility.showYesNoAlert("Create a recurrence?", message: "", vc: self)
        } else {
            Utility.showYesNoAlert("Update a recurrence?", message: "", vc: self)
        }
    }
    
    // MARK: - Alert Delegate
    func alertViewDidTapped(didTappedYes: Bool) {
        if didTappedYes {
            let date: String = txtDate.text!
            let start_at: String = txtStartHour.text! + ":" + txtStartMins.text!
            let stop_at: String = txtStopHour.text! + ":" + txtStopMins.text!
            print(date)
            print(start_at)
            print(stop_at)
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            if appDelegate.isCreatePage || appDelegate.recurrenceID == 0 {
                Networking.createRecurrenceWithDate(self.spotID, date: date, start_at: start_at, stop_at: stop_at)
            } else {
                Networking.updateRecurrenceWithDate(appDelegate.recurrenceID, date: date, start_at: start_at, stop_at: stop_at)
            }
        }
    }
    
    // MARK: - CreateRecurrenceWithDateDelegate methods
	
    func createRecurrenceWithDateDidSucceed(data: JSON) {
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
    
    func createRecurrenceWithDateDidFail(error: NSError) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
		
        if error.code == -1003 {
            Utility.showAlert("Error", message: "Your internet does not seem to be working.", vc: self)
        } else {
            Utility.showAlert("Error", message: error.localizedDescription, vc: self)
        }
    }
    
    // MARK: - UpdateRecurrenceWithDateDelegate Methods
	
    func updateRecurrenceWithDateDidSucceed(data: JSON) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
		
        appDelegate.arrChecks = [false, false, false, false, false, false, false]
        appDelegate.date = txtDate.text!
        showAlert(title: "Success", message: "You updated a recurrence successfully")
    }
    
    func updateRecurrenceWithDateDidFail(error: NSError) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
		
        if error.code == -1003 {
            Utility.showAlert("Error", message: "Your internet does not seem to be working.", vc: self)
        } else {
            Utility.showAlert("Error", message: error.localizedDescription, vc: self)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "gotoAddRecurrencesWithWeekDays" {
            let vc = segue.destinationViewController as! CreateRecurrenceWithWeekDaysViewController
            vc.spotID = self.spotID
            if !appDelegate.isCreatePage {
                vc.recurrenceID = self.recurrenceID
            }            
        }
    }
    
    // MARK: - Initialize DatePicker
    func InitDatePicker() {
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        // Add Toolbar with Cancel and Done Buttons
        let Toolbar = UIToolbar()
        Toolbar.barStyle = .Default
        Toolbar.sizeToFit()
        
            //  space between buttons
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
            //  DoneButton
        let btnDone = UIBarButtonItem(
			barButtonSystemItem: .Done, target: self,
			action: #selector(CreateRecurrenceWithDateViewController.doneButton(_:)))
        
            //  Cancel Button
        let btnCancel = UIBarButtonItem(
			barButtonSystemItem: .Cancel, target: self,
			action: #selector(CreateRecurrenceWithDateViewController.cancelButton(_:)))
        
        Toolbar.setItems([btnCancel, flexibleSpace, btnDone], animated: true)
        
        self.txtDate.inputAccessoryView = Toolbar
        
        // Add event
        datePickerView.addTarget(
			self, action: #selector(self.handleDatePicker(_:)),
			forControlEvents: UIControlEvents.ValueChanged)
        
        //  Allocate DatePickerView to DateText
        self.txtDate.inputView = datePickerView
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender: UIButton) {
        // To resign the inputView on clicking done.
        self.txtDate.resignFirstResponder()
        handleDatePicker(datePickerView)
        datePickerView.date = NSDate()
    }
    
    func cancelButton(sender: UIButton) {
        self.txtDate.resignFirstResponder()
        self.txtDate.text = _previousSelectedString
    }
    
    // MARK: - Check the time
	
    func enableTime() -> Bool {
        return (Int(txtStopHour.text!)! * 60 + Int(txtStopMins.text!)!
              - Int(txtStartHour.text!)! * 60 - Int(txtStartMins.text!)!) > 0
    }
}
