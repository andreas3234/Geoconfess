//
//  UserPasswordViewController.swift
//  GeoConfess
//
//  Created by whitesnow0827 on 3/4/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// Controls the **User Password** screen.
final class UserPasswordViewController: AppViewController, UITextFieldDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		resignFirstResponderWithOuterTouches(passwordTextField, confirmPasswordTextField)
	}

	/// Do any additional setup before showing the view.
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		passwordTextField.text = nil
		confirmPasswordTextField.text = nil
		notificationCheckImage.hidden = true
		
		signUpButton.enabled = false
		signUpButton.backgroundColor = UIButton.disabledColor
		
		passwordTextField.becomeFirstResponder()
	}

	// MARK: - Entering Passwords

	@IBOutlet weak private var passwordTextField: UITextField!
	@IBOutlet weak private var confirmPasswordTextField: UITextField!
	@IBOutlet weak private var notificationCheckImage: UIImageView!
	@IBOutlet weak private var signUpButton: UIButton!
	
	/// The text field calls this method whenever the user types a new
	/// character in the text field or deletes an existing character.
	func textField(textField: UITextField,
	               shouldChangeCharactersInRange range: NSRange,
				   replacementString replacement: String) -> Bool {
		let textBeforeChange: NSString = textField.text!
		let textAfterChange = textBeforeChange.stringByReplacingCharactersInRange(
			range, withString: replacement)
		
		updatePasswordInfoFrom(textField, with: textAfterChange)
		if hasAllMandatoryFields {
			signUpButton.enabled = true
			signUpButton.backgroundColor = UIButton.enabledColor
		} else {
			signUpButton.enabled = false
			signUpButton.backgroundColor = UIButton.disabledColor
		}
		return true
	}

	/// Called when *return key* pressed. Return false to ignore.
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		switch textField {
		case passwordTextField:
			confirmPasswordTextField.becomeFirstResponder()
		case confirmPasswordTextField:
			confirmPasswordTextField.resignFirstResponder()
			signUpButtonTapped(signUpButton)
		default:
			preconditionFailure("unexpected UITextField")
		}
		return true
	}
	
	// MARK: - Password Information
	
	private var userPassword: String = ""
	private var confirmUserPassword: String  = ""
	
	private func updatePasswordInfoFrom(textField: UITextField, with text: String) {
		switch textField {
		case passwordTextField:
			userPassword = text
		case confirmPasswordTextField:
			confirmUserPassword = text
		default:
			preconditionFailure("unexpected UITextField")
		}
	}
	
	private var hasAllMandatoryFields: Bool {
		return !userPassword.isEmpty && !confirmUserPassword.isEmpty
	}
	
	private var isUserNotificationChecked = false

	@IBAction func notificationButtonTapped(sender: UIButton) {
		isUserNotificationChecked = !isUserNotificationChecked
		if isUserNotificationChecked {
			notificationCheckImage.hidden = false
		} else {
			notificationCheckImage.hidden = true
		}
	}

	// MARK: - Sign Up Workflow

	@IBAction func signUpButtonTapped(sender: UIButton) {
		precondition(hasAllMandatoryFields)
		guard User.isValidPassword(userPassword) else {
			showAlert(message: "Le mot de passe doit faire 6 caractères minimum.")
			return
		}
		guard userPassword == confirmUserPassword else {
			showAlert(message: "Les mots de passe doivent être identiques.")
			return
		}
		signUpUser()
	}
	
	private func signUpUser() {
		let URL = NSURL(string: "\(App.serverURL)/api/v1/registrations")
		let params = [
			"user[role]" : "user",
			"user[email]" : userEmail,
			"user[password]" : userPassword,
			"user[name]" : name,
			"user[surname]" : surname,
			"user[notification]" : isUserNotificationChecked.description,
			"user[newsletter]" : "true",
			"user[phone]" : telephone
		]
		MBProgressHUD.showHUDAddedTo(view, animated: true)

		Alamofire.request(.POST, URL!, parameters: params).responseJSON {
			response in
			switch response.result {
			case .Success(let data):
				let jsonResult = JSON(data)
				guard jsonResult["result"].string == "success" else {
					var alertMessage = ""
					let errorResult = jsonResult["errors"].dictionary
					let errorJson = JSON(errorResult!)
					
					if let emailError = errorJson["email"][0].string
						where emailError != "" {
						alertMessage += "email " + emailError
					}
					if let passwordError = errorJson["password"][0].string
						where passwordError != "" {
						alertMessage += "password " + passwordError
					}
					if let phoneError = errorJson["phone"][0].string
						where phoneError != "" {
						alertMessage += "phoneNumber " + phoneError
					}
					
					let failureAlert = UIAlertView(title: nil, message: alertMessage,
						delegate: self, cancelButtonTitle: "OK")
					MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
					failureAlert.show()
					return
				}
				
				//let successAlert = UIAlertView(title: nil,
				//	message: "User Registration Success",
				//	delegate: self, cancelButtonTitle: "OK")
				MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
				self.loginUser()
				//successAlert.show()
				
			case .Failure(let error):
				let connectionFailureAlert = UIAlertView(title: nil,
					message: "Aucune connexion à internet detectée.",
					delegate: self, cancelButtonTitle: "OK")
				connectionFailureAlert.show()
				print("Request Failed Reason: \(error)")
				MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
			}
		}
	}
	
	private func loginUser() {
		MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		User.loginInBackground(username: userEmail, password: userPassword) {
			(user, error) -> Void in
			MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
			if let error = error {
				JLToast.makeText(error.description,
				                 duration: JLToastDelay.LongDelay).show()
				return
			}
			assert(user != nil)
			self.performSegueWithIdentifier("enterApp", sender: self)
		}
	}
}
