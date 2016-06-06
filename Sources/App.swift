//
//  App.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 02.02.16.
//  Copyright © 2016 Матвей Кравцов. All rights reserved.
//

import Foundation

/// Global information for the **GeoConfess** app.
final class App {

	// MARK: - Server Information

	/// Our **RESTful** server/backend URL.
	static let serverURL = "https://geoconfess.herokuapp.com"
	
	/// URL for server/backend API.
	static let serverAPI = "\(App.serverURL)/api/v1"

	// AWS S3.
	static let cognitoPoolID = "eu-west-1:931c05b1-94ee-40a4-a691-6bce6b3edbb8"
	
	/// Google Maps key.
	static let googleMapsApiKey = "AIzaSyCf-uTjIKB5syfsgdvsCLlnxq1tyEnH5Hk"

	// MARK: - UI Colors
	
	/// This is the *main* color used across the UI.
	/// It resembles the [Carmine Pink](http://name-of-color.com/#EB4C42) color.
	static let tintColor = UIColor(red: 233/255, green: 72/255, blue: 84/255, alpha: 1)
}

// MARK: - UIKit Extensions

extension UITextField {
	
	var isEmpty: Bool {
		return text == nil || text!.trimWhitespaces() == ""
	}
}

extension UIButton {
	
	static var enabledColor: UIColor {
		return UIColor(red: 237/255, green: 95/255, blue: 102/255, alpha: 1.0)
	}
	
	static var disabledColor: UIColor {
		return UIColor.lightGrayColor()
	}
}
