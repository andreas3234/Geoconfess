//
//  AppDelegate.swift
//  GeoConfess
//
//  Created by Admin on 2/26/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore
import AWSCognito
import GoogleMaps

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	// Detect Create/Edit
	var isCreatePage: Bool = true
	var recurrenceID: Int64 = -1
	var spotID: Int64 = 0
	
	// Default Time Values
	var date: String = ""
	var arrChecks = [false, false, false, false, false, false, false]
	var startHour: String = "12"
	var startMins: String = "30"
	var stopHour: String = "13"
	var stopMins: String = "45"
	
	static func appDelegate () -> AppDelegate {
		return UIApplication.sharedApplication().delegate as! AppDelegate
	}

	// MARK: - App Lifecyle Callbacks

	func application(
		application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		initGoogleMaps()
		initAmazonWebServices()
		initPushNotifications(application)
		return true
	}

	private func initGoogleMaps() {
		GMSServices.provideAPIKey(App.googleMapsApiKey)
	}

	private func initAmazonWebServices() {
		/*
		// Override point for customization after application launch.
		AWSCognitoCredentialsProvider.initialize()
		
		// configure authentication with Cognito
		
		let Region = AWSRegionType.EUWest1
		let credentialsProvider = AWSCognitoCredentialsProvider(
		regionType:Region, identityPoolId:CognitoPoolID)
		let configuration = AWSServiceConfiguration(
		region:Region, credentialsProvider:credentialsProvider)
		AWSServiceManager.defaultServiceManager()
		.defaultServiceConfiguration = configuration
		
		// Initialize the Cognito Sync client
		let syncClient = AWSCognito.defaultCognito()
		
		// Create a record in a dataset and synchronize with the server
		let dataset = syncClient.openOrCreateDataset("myDataset")
		dataset.setString("myValue", forKey:"myKey")
		dataset.synchronize().continueWithBlock {(task: AWSTask!) -> AnyObject! in
		// Your handler code here
		return nil
		}
		*/
		let credentialsProvider = AWSStaticCredentialsProvider(
			accessKey: "AKIAI2VXOE45NVI34MFQ",
			secretKey: "5QDGv0zgd6c+Bcqdm+cApquTDwbshtqcCfRK9reX")
		let configuration = AWSServiceConfiguration(
			region: AWSRegionType.EUWest1, credentialsProvider: credentialsProvider)
		AWSServiceManager.defaultServiceManager()
			.defaultServiceConfiguration = configuration
	}

	/// Sent when the application is about to move from active to inactive state.
	/// This can occur for certain types of temporary interruptions
	/// (such as an incoming phone call or SMS message) or when the user quits
	/// the application and it begins the transition to the background state.
	/// Use this method to pause ongoing tasks, disable timers, 
	/// and throttle down OpenGL ES frame rates. Games should use this method to 
	/// pause the game.
    func applicationWillResignActive(application: UIApplication) {
		/* empty */
    }

	/// Use this method to release shared resources, save user data, invalidate timers, 
	/// and store enough application state information to restore your application 
	/// to its current state in case it is terminated later.
	/// If your application supports background execution, this method is called 
	/// instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(application: UIApplication) {
		/* empty */
    }

	/// Called as part of the transition from the background to the inactive 
	/// state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(application: UIApplication) {
		/* empty */
    }

	/// Restart any tasks that were paused (or not yet started) while the 
	/// application was inactive. If the application was previously in the background, 
	/// optionally refresh the user interface.
    func applicationDidBecomeActive(application: UIApplication) {
		/* empty */
    }

	/// Called when the application is about to terminate. 
	/// Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(application: UIApplication) {
		/* empty */
	}
	
	// MARK: - Push Notifications
	
	private func initPushNotifications(application: UIApplication) {
		let notificationTypes: UIUserNotificationType = [
			UIUserNotificationType.Alert,
			UIUserNotificationType.Badge,
			UIUserNotificationType.Sound]
		let pushNotificationSettings = UIUserNotificationSettings(
			forTypes: notificationTypes, categories: nil)
		application.registerUserNotificationSettings(pushNotificationSettings)
	}
	
    func application(
		application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		print("DEVICE_TOKEN = \(deviceToken)")
    }
    
    func application(
		application: UIApplication,
		didFailedToRegisterForRemoteNotificationsWithDeviceToken error: NSError) {
		
    }
    
    func application(
		application: UIApplication,
		didRegisterUserNotificationSettings notificationSettings:
		UIUserNotificationSettings) {
		
    }

	func application(
		application: UIApplication,
		didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
		fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		
		print(userInfo)
    }
}
