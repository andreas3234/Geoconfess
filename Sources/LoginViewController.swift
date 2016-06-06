//
//  LoginViewController.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 01.03.16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// Controls the **Login** screen.
final class LoginViewController: AppViewController, UITextFieldDelegate {
    
    @IBOutlet weak private var emailField: UITextField!
    @IBOutlet weak private var passwordField: UITextField!
    
    @IBOutlet weak private var emailView: UIView!
    @IBOutlet weak private var passwordView: UIView!
    
    @IBOutlet weak private var loginButton: UIButton!
    
    @IBOutlet weak private var emailIcon: UIImageView!
    @IBOutlet weak private var passwordIcon: UIImageView!
	
	// MARK: - View Lifecyle
	
	override func viewDidLoad() {
        super.viewDidLoad()
		resignFirstResponderWithOuterTouches(emailField, passwordField)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// TODO: We should *really* be able to skip this VC completely.
		if User.current != nil {
            switch User.current.role {
            case .Priest:
                performSegueWithIdentifier("startPriestApp", sender: self)
            case .User, .Admin:
                performSegueWithIdentifier("startUserApp", sender: self)
            }
		}
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		/*
		let defaults = NSUserDefaults.standardUserDefaults()
		if let email    = defaults.stringForKey(User.lastUserEmailKey),
		   let password = defaults.stringForKey(User.lastUserPasswordKey) {
			
			let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
			let blurView = UIVisualEffectView(effect: blurEffect)
			blurView.frame = view.bounds
			view.addSubview(blurView)

			login(email: email, password: password)
		}
		*/
	}
	
	// MARK: - Entering Login Information
    
	@IBAction func emailEditingBegin(sender: UITextField) {
		selectField(emailField, inView: emailView, selected: true)
		selectField(passwordField, inView: passwordView, selected: false)

		emailIcon.image = UIImage(named: "icone-identifiant-on")
        passwordIcon.image = UIImage(named: "icone-mot-de-passe-off")
    }
	
    @IBAction func passwordEditingBegin(sender: UITextField) {
		selectField(emailField, inView: emailView, selected: false)
		selectField(passwordField, inView: passwordView, selected: true)
		
        emailIcon.image = UIImage(named: "icone-identifiant-off")
        passwordIcon.image = UIImage(named: "icone-mot-de-passe-on")
    }
	
	private let selectedColor =
		UIColor(red: 237/255, green: 95/255, blue: 83/255, alpha: 50/100)
	
	private func selectField(field: UITextField, inView view: UIView, selected: Bool) {
		view.backgroundColor = selected ? selectedColor : UIColor.clearColor()
		field.textColor = selected ? UIColor.whiteColor() : UIColor.blackColor()
		
		let placeholderColor = selected ? UIColor.whiteColor() : UIColor.lightGrayColor()
		field.setValue(placeholderColor, forKeyPath: "_placeholderLabel.textColor")
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		switch textField {
		case emailField:
			passwordField.becomeFirstResponder()
		case passwordField:
			passwordField.resignFirstResponder()
			loginButtonTapped(loginButton)
		default:
			assertionFailure("unexpected UITextField")
			break
		}
		return true
	}

	// MARK: - Performing Login

    @IBAction func loginButtonTapped(sender: UIButton) {
		let email = emailField.text ?? ""
		let password = passwordField.text ?? ""
		
		guard email != "" && password != "" else { return }
		
		if User.isValidEmail(email) && User.isValidPassword(password) {
			login(email: email, password: password)
		}
		else{
			self.showAlert(message: "Invalid Email or Password!")
		}
		
    }

	private func login(email email: String, password: String) {
		loginButton.enabled = false
		showProgressHUD()
		
		User.loginInBackground(username: email, password: password) {
			(user, error) -> Void in
			self.dismissProgressHUD()
			if let error = error {
				logError(error.description)
				self.showAlert(message: "Identifiants incorrects.")
				self.loginButton.enabled = true
				return
			}
			assert(user != nil)
			switch User.current.role {
			case .Priest:
				self.performSegueWithIdentifier("startPriestApp", sender: self)
			case .User, .Admin:
				self.performSegueWithIdentifier("startUserApp", sender: self)
            }
		}
	}

	/*
	private var email: String!
	private var password: String!
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
		case "showMain":
			//let mainVC = segue.destinationViewController as! MainViewController
			//mainVC.userDidLogin(email: email, password: password)
			break
		default:
			break
		}
	}
	*/
}
