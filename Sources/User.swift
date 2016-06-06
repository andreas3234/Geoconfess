//
//  User.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 02.02.16.
//  Copyright © 2016 Матвей Кравцов. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import CoreLocation

/// Stores information about a given **user** (or **priest**).
/// An instance is available after a successful login.
final class User: NSObject, CLLocationManagerDelegate {
    
	// MARK: - User Properties

	let id: UInt
	let name: String
	let surName: String
	let email: String
	let role: Role
	
	/// The phone number is *optional*.
	let phoneNumber: String?
	
	/// Sensitive information -- extra care in the future.
	let oauth: OAuthTokens
	
	/// The specific user role within the app.
	enum Role: String {
		case User   = "user"
		case Priest = "priest"
		case Admin  = "admin"
	}

	// MARK: - Creating Users

	init(meResponse: JSON, oauth: OAuthTokens) throws {
		// Checks all *required* fields.
		guard let id = meResponse["id"].uInt else {
			throw meResponse["id"].error!
		}
		guard let name = meResponse["name"].string else {
			throw meResponse["name"].error!
		}
		guard let surName = meResponse["surname"].string else {
			throw meResponse["surname"].error!
		}
		guard let email = meResponse["email"].string else {
			throw meResponse["email"].error!
		}
		guard let role = meResponse["role"].string else {
			throw meResponse["role"].error!
		}
		assert(User.isValidEmail(email))
		
		self.id          = id
		self.name        = name
		self.surName     = surName
		self.phoneNumber = meResponse["phone"].string
		self.email       = email
		self.role        = User.Role(rawValue: role)!
		self.oauth       = oauth
		
		self.locationTracker = CLLocationManager()
		super.init()
		
		initLocationTracking()
	}
	
	// MARK: - Current User
	
	// TODO: Is it a security hole?
	static let lastUserUsernameKey = "User.lastUser.username"
	static let lastUserPasswordKey = "User.lastUser.password"
	
	/// The currently logged in user.
	/// Returns `nil` if no user available.
	static var current: User! {
		didSet {
			let defaults = NSUserDefaults.standardUserDefaults()
			if current != nil {
				defaults.setObject(current.email,
				                   forKey: User.lastUserUsernameKey)
				defaults.setObject(current.oauth.password,
				                   forKey: User.lastUserPasswordKey)
			} else {
				defaults.removeObjectForKey(User.lastUserUsernameKey)
				defaults.removeObjectForKey(User.lastUserPasswordKey)
			}
		}
	}

	// MARK: - Validating User Properties
	
	/// Email regulax expression.
	/// Solution based on this answer: http://stackoverflow.com/a/25471164/819340
	private static let emailRegex = regex(
		"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
	
	/// Is the *email* format valid?
	static func isValidEmail(email: String) -> Bool {
		return emailRegex.matchesString(email)
	}
	
	/// Is the *password* format valid?
	static func isValidPassword(password: String) -> Bool {
		return password.characters.count >= 6
	}
	
	/// Is the *phone number* format valid?
    static func isValidPhoneNumber(phone: String) -> Bool {
       	let detector = try! NSDataDetector(types: NSTextCheckingType.PhoneNumber.rawValue)
		
		let fullRange = NSMakeRange(0, phone.characters.count)
		let matches = detector.matchesInString(phone, options: [], range: fullRange)
		if let res = matches.first {
			return res.resultType == .PhoneNumber && NSEqualRanges(res.range, fullRange)
		} else {
			return false
		}
    }
	
	// MARK: - Login Workflow

	/// Logins the specified user *asynchronously* in the background.
	/// This methods calls `/oauth/token` and then `/api/v1/me`.
	static func loginInBackground(username username: String, password: String,
								  completion: (user: User?, error: NSError?) -> Void) {
		requestOAuthTokens(username: username, password: password) {
			(oauthTokens, error) -> Void in
			assert(NSThread.isMainThread())
			guard let oauthTokens = oauthTokens else {
				logError("Auth user error: \(error!)")
				completion(user: nil, error: error!)
				return
			}
			log("User auth: OK (access token: \(oauthTokens.accessToken))")
			requestUserData(oauthTokens) {
				(user, error) -> Void in
				assert(NSThread.isMainThread())
				guard let user = user else {
					logError("Get user error: \(error!)")
					completion(user: nil, error: error!)
					return
				}
				log("User data: OK (role: \(user.role))")
				User.current = user
				completion(user: user, error: nil)
			}
		}
	}
	
	/// Logouts this user *asynchronously* in the background.
	func logoutInBackground(completion: (error: NSError?) -> Void) {
		revokeOAuth(oauth) {
			error in
			if error == nil {
				User.current = nil
				log("User logout: OK (access token: \(self.oauth.accessToken))")
				#if DEBUG
					// Is this user actually logged out? 
					// Let's find out -- better be safe than sorry :-)
					checkIfOAuthAccessTokenIsValid(self.oauth) {
						validToken in
						assert(validToken == false)
					}
				#endif
				completion(error: nil)
			} else {
				logError("Logout error: \(error)")
				completion(error: error)
			}
			self.locationTracker.stopUpdatingLocation()
		}
	}
	
	// MARK: - Location Tracking
	
	/// Tracks user's GPS related information.
	let locationTracker: CLLocationManager
	
	/// User current location.
	/// The value of this property is `nil` if
	/// no location data has ever been retrieved.
	var location: CLLocation? {
		return locationTracker.location
	}
	
	private var locationObservers = [Weak<UserLocationObserver>]()
	
	private func initLocationTracking() {
		locationTracker.delegate = self
		locationTracker.startUpdatingLocation()
		precondition(CLLocationManager.locationServicesEnabled())
		log("Core Location enabled: \(CLLocationManager.authorizationStatus())")
	}
	
	func addLocationObserver(observer: UserLocationObserver) {
		locationObservers.append(Weak(observer))
	}

	func removeLocationObserver(observer: UserLocationObserver) {
		if let index = locationObservers.indexOf(Weak(observer)) {
			locationObservers.removeAtIndex(index)
		}
	}

	func locationManager(manager: CLLocationManager,
	                     didUpdateLocations locations: [CLLocation]) {
		//print("didUpdateLocations...")
		
		let mostRecentLocation = locations.last!
		for observer in locationObservers {
			observer.object?.user?(self, didUpdateLocation: mostRecentLocation)
		}
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		logError("Core Location: \(error)")
	}
}

@objc protocol UserLocationObserver {
	
	optional func user(user: User, didUpdateLocation location: CLLocation)
}

// MARK: -

/// Stores OAuth tokens returned from a successful authentication.
struct OAuthTokens {
	let accessToken: String
	let refreshToken: String
	let tokenType: String
	let createdAt: Double

	/// Sensitive information -- extra care in the future.
	let password: String

	init(oauthResponse: JSON, password: String) throws {
		assert(User.isValidPassword(password))
		guard let accessToken = oauthResponse["access_token"].string else {
			throw oauthResponse["access_token"].error!
		}
		guard let refreshToken = oauthResponse["refresh_token"].string else {
			throw oauthResponse["refresh_token"].error!
		}
		guard let tokenType = oauthResponse["token_type"].string else {
			throw oauthResponse["token_type"].error!
		}
		guard let createdAt = oauthResponse["created_at"].double else {
			throw oauthResponse["created_at"].error!
		}
		self.accessToken  = accessToken
		self.refreshToken = refreshToken
		self.tokenType    = tokenType
		self.createdAt    = createdAt
		self.password     = password
	}
}

// MARK: -

/// Requests OAuth authorization (aka, *login*)..
private func requestOAuthTokens(username username: String,
								password: String,
								completion: (OAuthTokens?, NSError?) -> Void) {
	assert(User.isValidEmail(username))
	assert(User.isValidPassword(password))
	
	// The corresponding API is documented here:
	// http://geoconfess.herokuapp.com/apidoc/V1/credentials/show.html
	let oauthURL = "\(App.serverURL)/oauth/token"
	let parameters = [
		"grant_type": "password",
		"username":    username,
		"password":    password,
		"os": 		  "ios",
        "push_token": "3kjh123iu42i314g123"
	]
	
	Alamofire.request(.POST, oauthURL, parameters: parameters).responseJSON {
		response in
		switch response.result {
		case .Success(let value):
			do {
				let tokens = try OAuthTokens(oauthResponse: JSON(value),
					password: password)
				completion(tokens, nil)
			} catch let error as NSError {
				completion(nil, error)
			}
		case .Failure(let error):
			completion(nil, error)
		}
	}
}

/// Revokes OAuth authorization (aka, *logout*).
private func revokeOAuth(oauthTokens: OAuthTokens,
                         completion: (error: NSError?) -> Void) {
	// Following advice given by Oleg Sulyanov.
	let oathURL = "\(App.serverURL)/oauth/revoke"
	let headers = [
		"Authorization": "\(oauthTokens.tokenType) \(oauthTokens.accessToken)"]
	let params = ["token": oauthTokens.accessToken]
	Alamofire.request(.POST, oathURL, parameters: params, headers: headers).responseJSON {
		response in
		switch response.result {
		case .Success:
			completion(error: nil)
		case .Failure(let error):
			completion(error: error)
		}
	}
}

/// Requests user information.
private func requestUserData(oauthTokens: OAuthTokens,
                             completion: (user: User?, error: NSError?) -> Void) {
	// The corresponding API is documented here:
	// http://geoconfess.herokuapp.com/apidoc/V1/credentials/show.html
	let meURL = "\(App.serverAPI)/me"
	let params = ["access_token": oauthTokens.accessToken]
	
	Alamofire.request(.GET, meURL, parameters: params).responseJSON {
		response in
		switch response.result {
		case .Success(let value):
			do {
				let user = try User(meResponse: JSON(value), oauth: oauthTokens)
				completion(user: user, error: nil)
			} catch let error as NSError {
				completion(user: nil, error: error)
			}
		case .Failure(let error):
			completion(user: nil, error: error)
		}
	}
}

/// Just for testing purposes.
private func checkIfOAuthAccessTokenIsValid(oauthTokens: OAuthTokens,
                                            validToken: Bool -> Void) {
	requestUserData(oauthTokens) {
		(user, error) -> Void in
		if error == nil {
			log("The access token \(oauthTokens.accessToken) is valid")
			validToken(true)
		} else {
			log("The access token \(oauthTokens.accessToken) has been revoked")
			validToken(false)
		}
	}
}
