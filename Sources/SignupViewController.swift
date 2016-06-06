//
//  SignupViewController.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 01.03.16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

class SignupViewController: AppViewController {
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.layer.shadowOffset = CGSizeMake(0, -10)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.5
        
    }
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        
//        let cell: UserSignUpCell = UserSignUpCell()
//        cell.userInfoTextField.placeholder
    }

}
