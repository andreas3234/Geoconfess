//
//  StaticViewController.swift
//  GeocCnfess
//
//  Created by whitesnow0827 on 3/17/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import APAddressBook

final class StaticViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak private var mainView: UIView!
    @IBOutlet weak private var bottomView: UIView!
    @IBOutlet weak private var scrollView: UIScrollView!
    
    private var contactsTableViewController: ContactsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.scrollView.contentSize = CGSizeMake(274, 300)
        self.scrollView.delegate = self
    }
	
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnEnvelopTapped(sender: UIButton) {
	}
}
