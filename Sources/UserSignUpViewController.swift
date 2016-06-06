//
//  UserSignUpViewController.swift
//  geoconfess
//
//  Created by whitesnow0827 on 3/4/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// TODO: These global properties seems like a hack. We can do better.

var name: String = ""
var surname: String = ""
var userEmail: String = ""
var telephone: String = ""

// TODO: This controller should be reused by the PriestSignUpViewController.

/// Controls the **User Sign Up** screen.
final class UserSignUpViewController: AppViewController, UITextFieldDelegate {

	@IBOutlet weak private var signUpButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		resignFirstResponderWithOuterTouches(
			nameTextField, surnameTextField,
			emailTextField, telephoneTextField)
    }
    
	/// Do any additional setup before showing the view.
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		surnameTextField.becomeFirstResponder()
	}
	
	// MARK: - Entering User Information

	@IBOutlet weak private var surnameTextField:   UITextField!
	@IBOutlet weak private var nameTextField:      UITextField!
	@IBOutlet weak private var emailTextField:     UITextField!
	@IBOutlet weak private var telephoneTextField: UITextField!
	
	/// The text field calls this method whenever the user types a new
	/// character in the text field or deletes an existing character.
	func textField(textField: UITextField,
	               shouldChangeCharactersInRange range: NSRange,
				   replacementString replacement: String) -> Bool {
		let textBeforeChange: NSString = textField.text!
		let textAfterChange = textBeforeChange.stringByReplacingCharactersInRange(
			range, withString: replacement)

		updateUserInfoFrom(textField, with: textAfterChange)
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
		case surnameTextField:
			nameTextField.becomeFirstResponder()
		case nameTextField:
			emailTextField.becomeFirstResponder()
		case emailTextField:
			telephoneTextField.becomeFirstResponder()
		case telephoneTextField:
			telephoneTextField.resignFirstResponder()
			signUpButtonTapped(signUpButton)
		default:
			preconditionFailure("unexpected UITextField")
		}
		return true
	}
	
	@IBAction func signUpButtonTapped(button: UIButton) {
		precondition(hasAllMandatoryFields)
		guard User.isValidEmail(userEmail) else {
			showAlert(message: "Votre adresse email n’est pas valide!")
			return
		}
		guard telephone.isEmpty || User.isValidPhoneNumber(telephone) else {
			showAlert(message: "Numéro de téléphone invalide!")
			return
		}
		performSegueWithIdentifier("enterPassword", sender: self)
	}
	
	// MARK: - User Information
	
	private func updateUserInfoFrom(textField: UITextField, with text: String) {
		switch textField {
		case surnameTextField:
			surname = text
		case nameTextField:
			name = text
		case emailTextField:
			userEmail = text
		case telephoneTextField:
			telephone = text
		default:
			preconditionFailure("unexpected UITextField")
		}
	}

	private var hasAllMandatoryFields: Bool {
		return !name.isEmpty && !surname.isEmpty && !userEmail.isEmpty
	}
}
