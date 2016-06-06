//
//  PriestSignUpViewController.swift
//  GeoConfess
//
//  Created by whitesnow0827 on 3/5/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

// TODO: These global properties seems like a hack. We can do (way!) better.

var priestName: String = ""
var priestSurname: String = ""
var priestEmail: String = ""
var priestTelephon: String = ""
var parishName: String = ""
var parishEmail: String = ""

/// Controls the **Priest Sign Up** screen.
final class PriestSignUpViewController: AppViewController,
										UITextFieldDelegate,
										UIScrollViewDelegate {

	@IBOutlet weak var scrollview: UIScrollView!
	@IBOutlet weak private var signUpButton: UIButton!
	
	/// Do any additional setup after loading the view.
    override func viewDidLoad() {
        super.viewDidLoad()
		
		resignFirstResponderWithOuterTouches(
			priestNameField, priestSurnameField,
			priestEmailField, priestTelephoneField
		)

		// ScrollView settings.
		scrollview.contentSize.height = 1000
		scrollview.scrollEnabled = true
		scrollview.delegate = self
    }
    
	// MARK: - UITextFieldDelegate Protocol

	/// Called when 'return' key pressed. Return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
	
	/// The text field calls this method whenever the user types a new
	/// character in the text field or deletes an existing character.
	func textField(textField: UITextField,
	shouldChangeCharactersInRange range: NSRange, replacementString replacement: String)
	-> Bool {
		let textBeforeChange: NSString = textField.text!
		let textAfterChange = textBeforeChange.stringByReplacingCharactersInRange(
			range, withString: replacement)
		
		updatePriestInfoFrom(textField, with: textAfterChange)
		if hasAllMandatoryFields {
			signUpButton.enabled = true
			signUpButton.backgroundColor = UIButton.enabledColor
		} else {
			signUpButton.enabled = false
			signUpButton.backgroundColor = UIButton.disabledColor
		}

		return true
	}

	// MARK: - Priest Information
	
	@IBOutlet weak var priestNameField: UITextField!
	@IBOutlet weak var priestSurnameField: UITextField!
	@IBOutlet weak var priestEmailField: UITextField!
	@IBOutlet weak var priestTelephoneField: UITextField!
	@IBOutlet weak var parishNameField: UITextField!
	@IBOutlet weak var parishEmailField: UITextField!
	
	private func updatePriestInfoFrom(textField: UITextField, with text: String) {
		if textField === priestNameField {
			priestName = text
		} else if textField === priestSurnameField {
			priestSurname = text
		} else if textField === priestEmailField {
			priestEmail = text
		} else if textField === priestTelephoneField {
			priestTelephon = text
		} else if textField === parishNameField {
			parishName = text
		} else if textField === parishEmailField {
			parishEmail = text
		} else {
			preconditionFailure("unexpected field")
		}
	}
	
	private var hasAllMandatoryFields: Bool {
		return !priestName.isEmpty && !priestSurname.isEmpty && !priestEmail.isEmpty
	}
	
    @IBAction func priestSignUpButtonTapped(sender: UIButton) {
		precondition(hasAllMandatoryFields)
		guard User.isValidEmail(priestEmail) else {
			showAlert(message: "Votre adresse email n’est pas valide!")
			return
		}
		guard priestTelephon.isEmpty || User.isValidPhoneNumber(priestTelephon) else {
			showAlert(message: "Numéro de téléphone invalide!")
			return
		}
		self.performSegueWithIdentifier("enterPassword", sender: self)
    }
}
