//
//  RestotePasswordViewController.swift
//  GeoConfess
//
//  Created by Alex on 18.03.16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import Alamofire

/// Controls the recover password screen.
final class RestotePasswordViewController: AppViewController {

    @IBOutlet weak private var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		resignFirstResponderWithOuterTouches(emailField)
    }

    @IBAction func confirmer(sender: UIButton) {
        if emailField.text!.isEmpty {
            showWrongEmailAlert()
        } else {
            ressetPassword(emailField.text!)
        }
    }
    
	private func ressetPassword(email: String) {
        let correctEmail = email.lowercaseString
        let params = ["user[email]": correctEmail]
        let URL = NSURL(string: "https://geoconfess.herokuapp.com/api/v1/passwords")
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		
		// TODO: This operation really should be done by the `User` class!
        Alamofire.request(.POST, URL!, parameters: params).responseData {
			response in
			MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
			guard let newResponse = response.response else {
				self.showWrongEmailAlert()
				return
			}
			guard newResponse.statusCode == 201 else {
				self.showWrongEmailAlert()
				return
			}
			self.showAlert(message:
			"Un email de reinitialisation de mot de passe vous a été envoyé") {
				self.navigationController.popViewControllerAnimated(true)
			}
		}
	}
	
	private func showWrongEmailAlert() {
		showAlert(message: "Pas de compte lié a l'adresse mail")
	}
}
