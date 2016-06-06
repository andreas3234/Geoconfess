//
//  DummyViewController.swift
//  GeoConfess
//
//  Created by Paulo Mattos on 07/04/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

final class DummyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		log("didLoad")
    }
	
	override func viewWillDisappear(animated: Bool) {
		log("willDisappear")
	}
}
