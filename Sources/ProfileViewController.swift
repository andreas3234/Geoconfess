//
//  ProfileViewController.swift
//  GeoConfess
//
//  Created by Arman Manukyan on 3/18/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// Control the **user profile** editing screen.
final class ProfileViewController: AppViewControllerWithToolbar, UITextFieldDelegate {
	
	@IBOutlet weak private var editButton: UIButton!
	
	@IBOutlet weak private var nameField: UITextField!
	@IBOutlet weak private var surnameField: UITextField!
	@IBOutlet weak private var emailField: UITextField!
	@IBOutlet weak private var phoneNumberField: UITextField!
	
	@IBOutlet weak private var nameLabel: UILabel!
	@IBOutlet weak private var surnameLabel: UILabel!
	@IBOutlet weak private var emailLabel: UILabel!
	@IBOutlet weak private var phoneNumberLabel: UILabel!
	
	@IBOutlet weak private var nameCheckMark: UIImageView!
	@IBOutlet weak private var surnameCheckMark: UIImageView!
	@IBOutlet weak private var emailCheckMark: UIImageView!
	@IBOutlet weak private var phoneNumberCheckMark: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mode = .Viewing
	}

	/// This is a modal UI with 2 modes.
	private enum Mode {
		case Viewing, Editing
	}
	
	private var mode: Mode = .Viewing {
		didSet {
			let title: String
			let color: UIColor
			let hideTextFields: Bool
			switch mode {
			case .Viewing:
				title = "Modifier"
				color = UIColor(red: 128/255, green: 128/255, blue: 128/255)
				hideTextFields = true
				setLabelsWithUserInformation()
			case .Editing:
				title = "Valider"
				color = UIColor(red: 241/255, green: 58/255, blue: 86/255)
				hideTextFields = false
				setFieldsWithUserInformation()
			}
			
			editButton.setTitle(title, forState: UIControlState.Normal)
			editButton.layer.masksToBounds = true
			editButton.layer.shadowColor = UIColor.blackColor().CGColor
			editButton.backgroundColor = color
			editButton.layer.shadowOpacity = 1
			editButton.layer.shadowOffset = CGSize(width: 10, height: -20)
			editButton.layer.shadowRadius = 10
			
			nameField.hidden = hideTextFields
			nameLabel.hidden = !hideTextFields
			nameCheckMark.hidden = !hideTextFields
			
			surnameField.hidden = hideTextFields
			surnameLabel.hidden = !hideTextFields
			surnameCheckMark.hidden = !hideTextFields
			
			emailField.hidden = hideTextFields
			emailLabel.hidden = !hideTextFields
			emailCheckMark.hidden = !hideTextFields
			
			phoneNumberField.hidden = hideTextFields
			phoneNumberLabel.hidden = !hideTextFields
			phoneNumberCheckMark.hidden = !hideTextFields
			
			nameCheckMark.hidden = nameLabel.text!.isEmpty
			surnameCheckMark.hidden = surnameLabel.text!.isEmpty
			emailCheckMark.hidden = emailLabel.text!.isEmpty
			phoneNumberCheckMark.hidden = phoneNumberLabel.text!.isEmpty
		}
	}
	
	private func setFieldsWithUserInformation() {
		let user = User.current
		nameField.text        = user.name
		surnameField.text     = user.surName
		emailField.text       = user.email
		phoneNumberField.text = user.phoneNumber
	}
	
	private func setLabelsWithUserInformation() {
		let user = User.current
		nameLabel.text        = user.name
		surnameLabel.text     = user.surName
		emailLabel.text       = user.email
		phoneNumberLabel.text = user.phoneNumber
	}
	
	// MARK: - User Information
	
	private var name: String {
		get {
			switch mode {
			case .Viewing: return nameLabel.text!
			case .Editing: return nameField.text!
			}
		}
	}

	private var surname: String {
		get {
			switch mode {
			case .Viewing: return surnameLabel.text!
			case .Editing: return surnameField.text!
			}
		}
	}

	private var email: String {
		get {
			switch mode {
			case .Viewing: return emailLabel.text!
			case .Editing: return emailField.text!
			}
		}
	}
	
	private var phoneNumber: String {
		get {
			switch mode {
			case .Viewing: return phoneNumberLabel.text!
			case .Editing: return phoneNumberField.text!
			}
		}
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	@IBAction func editButtonTapped(sender: UIButton) {
		switch mode {
		case .Viewing:
			mode = .Editing
		case .Editing:
			guard name != "" || surname != "" || email != "" else {
				// TODO: In French please!
				showAlert(message: "All fields are required")
				return
			}
			guard User.isValidEmail(email) else {
				showAlert(message: "Votre adresse email n’est pas valide!")
				return
			}
			guard phoneNumberField == "" ||  User.isValidPhoneNumber(phoneNumber) else {
				showAlert(message: "Numéro de téléphone invalide!")
				return
			}
			
			showProgressHUD()
			updateUserInformation {
				self.dismissProgressHUD()
				self.mode = .Viewing
			}
		}
	}
	
	// TODO: Is this information reflected in the user?
	// TODO: Move to user class
	
	private func updateUserInformation(completion: () -> Void) {
		precondition(mode == .Editing)
		let user = User.current
		
		let params = [
			"user[email]"   : email,
			"user[password]": user.oauth.password,
			"user[name]"    : name,
			"user[surname]" : surname,
			"user[phone]"   : phoneNumber
		]
		
		let url =
			"\(App.serverAPI)/users/\(user.id)?access_token=\(user.oauth.accessToken)"
		Alamofire.request(.PUT, url, parameters: params).responseJSON {
			response in
			log("status code: \(response.response!.statusCode)")
			
			switch response.result {
			case .Success(let data):
				let jsonResult = JSON(data)
				let result = jsonResult["result"].string
				guard result == "success" else {
					self.showAlert(message: "Update Failed")
					self.dismissProgressHUD()
					break
				}
				self.showAlert(message: "Profil mis à jour!!!")
			case .Failure(let error):
				logError("Request Failed Reason: \(error)")
				self.showAlert(message: "Update Failed")
			}
			completion()
		}
	}
}
