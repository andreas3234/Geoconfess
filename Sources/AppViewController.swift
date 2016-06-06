//
//  AppViewController.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 31.01.16.
//  Copyright © 2016 Матвей Кравцов. All rights reserved.
//

import UIKit

/// This is the custom **navigation view controller** used by the app.
@IBDesignable
final class AppNavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	/// The custom toolbar associated with the navigation controller.
	override var toolbar: AppToolbar! {
		guard let toolbar = super.toolbar else { return nil }
		return toolbar as! AppToolbar
	}
	
	/// The image used as the current view controller **title**.
	@IBInspectable
	var titleImage: UIImage!
}

// MARK: -

/// The custom toolbar used by all main screens.
@IBDesignable
class AppToolbar: UIToolbar {
	
	/// The toolbar custom height.
	/// The iOS toolbar default height is `44`.
	@IBInspectable
	var height: CGFloat = 44
	
	/// Asks the view to calculate and return the
	/// size that best fits the specified size.
	override func sizeThatFits(size: CGSize) -> CGSize {
		var newSize = super.sizeThatFits(size)
		newSize.height = height
		return newSize
	}
}

// MARK: -

/// Superclass for *all* view controllers used by the app.
/// This controller instance will be embedded 
/// inside our custom `AppNavigationController`.
class AppViewController: UIViewController {
	
	private static var isFirstViewController = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setLogoAsTitle()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		setBackButton()
		registerKeyboardNotifications()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		unregisterKeyboardNotifications()
	}

	/// The app's custom navigation controller.
	override var navigationController: AppNavigationController! {
		return super.navigationController as? AppNavigationController
	}

	// MARK: - Custom View Controller Title
	
	/// Sets the app's logo as this view controller **title**.
	/// As opposed to its back button, this is *not*
	/// based on the view controller current state.
	private func setLogoAsTitle() {
		let logoImage = navigationController.titleImage
		let logoAspectRatio = logoImage.size.width / logoImage.size.height
		let logoView = UIImageView(image: logoImage)
		
		let width = equalsConstraint(
			item: logoView, attribute: .Width, value: 120)
		let aspectRatio = equalsConstraint(
			item:   logoView, attribute: .Width,
			toItem: logoView, attribute: .Height, multiplier: logoAspectRatio)
		logoView.translatesAutoresizingMaskIntoConstraints = false
		logoView.addConstraints([width, aspectRatio])
		
		let superView = UIView()
		let centerX = equalsConstraint(
			item:   logoView,  attribute: .CenterX,
			toItem: superView, attribute: .CenterX)
		let bottom = equalsConstraint(
			item:   logoView,   attribute: .Bottom,
			toItem: superView,  attribute: .Bottom, constant: 8)
		superView.addSubview(logoView)
		superView.addConstraints([centerX, bottom])
		
		navigationItem.titleView = superView
		
		// Smooth animation for first view controller.
		if AppViewController.isFirstViewController {
			logoView.alpha = 0
			UIView.animateWithDuration(1.65,
				animations: {
					logoView.alpha = 1
				},
				completion: {
					finished  in
					/* empty */
				}
			)
			AppViewController.isFirstViewController = false
		}
	}
	
	// MARK: - Custom Back Button
	
	private var backButton: UIBarButtonItem?
	private var backButtonHiddenValue = false
	private var setBackButtonCalled = false
	
	/// A boolean indicating whether the view controller’s
	/// built-in, custom back button is visible.
	///
	/// The back button will *never* be shown if only
	/// one controller is in the navigation stack.
	///
	/// Currently, this controller does not support more than
	/// one left item in the navigation bar.
	var backButtonHidden: Bool {
		get {
			guard setBackButtonCalled else {
				return backButtonHiddenValue
			}
			return backButton?.hidden ?? true
		}
		set {
			backButtonHiddenValue = newValue
			guard setBackButtonCalled else {
				return
			}
			if backButtonHiddenValue {
				backButton?.hidden = true
			} else {
				if let backButton = backButton {
					backButton.hidden = false
				} else {
					setBackButton()
				}
			}
		}
	}

	/// Sets this view controller custom **back button**.
	/// As opposed to its title, this *is* based on the
	/// view controller current state (eg, nav stack size).
	private func setBackButton() {
		setBackButtonCalled = true
		guard navigationController.viewControllers.count > 1 else { return }
		guard !backButtonHiddenValue else { return }
		
		let backButtonImage = UIImage(named: "Back Button (Template)")!
		backButton = navigationController.navigationBar.highlightedBarButtonWithImage(
			backButtonImage, width: 28)
		navigationItem.leftBarButtonItems = [backButton!]
		
		backButton!.buttonView.addTarget(
			self, action: #selector(AppViewController.backButtonTapped(_:)),
			forControlEvents: .TouchUpInside)
	}
	
	@objc private func backButtonTapped(buttton: UIButton) {
		navigationController.popViewControllerAnimated(true)
	}

	// MARK: - Tracking First Responder
	
	/// Ensures touches outside the specified views will
	/// result in view resigning first responder status 
	/// (eg, *closes* keyboard if showing).
	func resignFirstResponderWithOuterTouches(views: UIView...) {
		let viewRefs = views.map { Weak($0) }
		resignFirstResponders.unionInPlace(viewRefs)
	}
	
	private var resignFirstResponders = Set<Weak<UIView>>()
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for viewRef in resignFirstResponders {
			viewRef.object?.resignFirstResponder()
		}
	}
	
	// MARK: - Keyboard Events
	
	private func registerKeyboardNotifications() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		
		notificationCenter.addObserver(
			self,
			selector: #selector(AppViewController.keyboardWillShowNotification(_:)),
			name: UIKeyboardWillShowNotification, object: nil)

		notificationCenter.addObserver(
			self,
			selector: #selector(AppViewController.keyboardDidShowNotification(_:)),
			name: UIKeyboardDidShowNotification, object: nil)

		notificationCenter.addObserver(
			self,
			selector: #selector(AppViewController.keyboardWillHideNotification(_:)),
			name: UIKeyboardWillHideNotification, object: nil)

		notificationCenter.addObserver(
			self,
			selector: #selector(AppViewController.keyboardDidHideNotification(_:)),
			name: UIKeyboardDidHideNotification, object: nil)
	}

	private func unregisterKeyboardNotifications() {
		let notificationCenter = NSNotificationCenter.defaultCenter()
		
		notificationCenter.removeObserver(
			self, name: UIKeyboardWillShowNotification, object: nil)

		notificationCenter.removeObserver(
			self, name: UIKeyboardDidShowNotification, object: nil)

		notificationCenter.removeObserver(
			self, name: UIKeyboardWillHideNotification, object: nil)
		
		notificationCenter.removeObserver(
			self, name: UIKeyboardDidShowNotification, object: nil)
	}
	
	private func keyboardFrameAt(notification: NSNotification) -> CGRect {
		let userInfo = notification.userInfo!
		let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
		return keyboardFrame.CGRectValue()
	}
	
	@objc private func keyboardWillShowNotification(notification: NSNotification) {
		keyboardWillShow(keyboardFrameAt(notification))
	}

	@objc private func keyboardDidShowNotification(notification: NSNotification) {
		keyboardDidShow(keyboardFrameAt(notification))
	}

	@objc private func keyboardWillHideNotification(notification: NSNotification) {
		keyboardWillHide(keyboardFrameAt(notification))
	}

	@objc private func keyboardDidHideNotification(notification: NSNotification) {
		keyboardDidHide(keyboardFrameAt(notification))
	}
	
	/// Called immediately *prior* to the display of the keyboard.
	///
	/// - Parameter keyboardFrame: a CGRect that identifies
	/// 		the end frame of the keyboard in **screen coordinates**.
	func keyboardWillShow(keyboardFrame: CGRect) {
		/* empty */
	}

	/// Called immediately *after* to the display of the keyboard.
	///
	/// - Parameter keyboardFrame: a CGRect that identifies
	/// 		the end frame of the keyboard in **screen coordinates**.
	func keyboardDidShow(keyboardFrame: CGRect) {
		/* empty */
	}

	/// Called immediately *prior* to the dismissal of the keyboard.
	///
	/// - Parameter keyboardFrame: a CGRect that identifies
	/// 		the end frame of the keyboard in **screen coordinates**.
	func keyboardWillHide(keyboardFrame: CGRect) {
		/* empty */
	}

	/// Called immediately *after* to the dismissal of the keyboard.
	///
	/// - Parameter keyboardFrame: a CGRect that identifies
	/// 		the end frame of the keyboard in **screen coordinates**.
	func keyboardDidHide(keyboardFrame: CGRect) {
		/* empty */
	}
}

// MARK: -

/// Adds support for an optional toolbar to `AppViewController` objects.
/// The implementation is fully based on the navigation controller's *built-in* toolbar.
class AppViewControllerWithToolbar: AppViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		setToolbarButtons()
	}
	
	// MARK: - Toolbar Buttons
	
	private var notificationsButtonItem: UIBarButtonItem!
	private var priestAvailabilityButtonItem: UIBarButtonItem!
	private var notesButtonItem: UIBarButtonItem!
	
	var notificationsButton: UIButton {
		return notificationsButtonItem.buttonView
	}
	
	var priestAvailabilityButton: UIButton {
		return priestAvailabilityButtonItem.buttonView
	}

	var notesButton: UIButton {
		return notesButtonItem.buttonView
	}
	
	/// Sets all 3 toolbar buttons.
	/// This code *only* runs if an actual `AppToolbar` is available.
	private func setToolbarButtons() {
		guard let toolbar = navigationController.toolbar else { return }
		
		let notificationImage = UIImage(named: "notification_icon")!
		notificationsButtonItem = toolbar.highlightedBarButtonWithImage(
			notificationImage, width: 30, hightlightIntensity: 0.4)
		
		let availableImage = UIImage(named: "indisponible")!
		priestAvailabilityButtonItem = toolbar.barButtonWithImage(
			availableImage, width: 95)
		
		let notesImage = UIImage(named: "contacts_icon")!
		notesButtonItem = toolbar.highlightedBarButtonWithImage(
			notesImage, width: 27, hightlightIntensity: 0.4)
		
		let space = UIBarButtonItem(
			barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
		let items: [UIBarButtonItem] = [
			space,
			notificationsButtonItem, space,
			priestAvailabilityButtonItem, space,
			notesButtonItem,
			space
		]
		
		switch User.current.role {
		case .Admin, .User:
			priestAvailabilityButton.hidden = true
		case .Priest:
			priestAvailabilityButton.hidden = false
		}
		setToolbarItems(items, animated: false)
		
		notificationsButton.addTarget(
			self,
			action: #selector(self.notificatioButtonTapped(_:)),
			forControlEvents: .TouchUpInside)
		
		notesButton.addTarget(
			self,
			action: #selector(self.notesButtonTapped(_:)),
			forControlEvents: .TouchUpInside)
	}
	
	@objc private func notificatioButtonTapped(buttton: UIButton) {
		let notificationsVC = storyboard!
			.instantiateViewControllerWithIdentifier("NotificationListVC")
			as! NotificationListVC
		navigationController.pushViewController(notificationsVC, animated: true)
	}
	
	@objc private func notesButtonTapped(buttton: UIButton) {
		let notificationsVC = storyboard!
			.instantiateViewControllerWithIdentifier("FavorisVC")
			as! FavorisVC
		navigationController.pushViewController(notificationsVC, animated: true)
	}
}

// MARK: - BarView Protocol

/// Common interface for `UINavigationBar` and `UIToolbar` objects.
protocol BarView {
	
	var tintColor: UIColor! { get }
	var barTintColor: UIColor? { get }
}

extension BarView {
	
	/// Creates a *standard* button for bars.
	func barButtonWithImage(buttonImage: UIImage, width: CGFloat) -> UIBarButtonItem {
		let button = UIButton(type: .Custom)
		button.setImage(buttonImage, forState: .Normal)
		
		let imageAspectRatio = buttonImage.size.width / buttonImage.size.height
		button.frame.size = CGSize(width: width, height: width/imageAspectRatio)
		return UIBarButtonItem(customView: button)
	}
	
	/// Creates a *standard* button for bars with hightlight support.
	func highlightedBarButtonWithImage(buttonImage: UIImage, width: CGFloat,
	                                   hightlightIntensity: CGFloat = 0.7)
									   -> UIBarButtonItem {
		precondition(buttonImage.renderingMode == .AlwaysTemplate)
		
		let button = UIButton(type: .Custom)
		
		let barTintColor = self.barTintColor ?? UIColor.whiteColor()
		let highlightedColor = barTintColor.blendedColorWith(
			tintColor, usingWeight: hightlightIntensity)
		let highlightedImage = buttonImage.tintedImageWithColor(highlightedColor)
		
		button.setImage(buttonImage, forState: .Normal)
		button.setImage(highlightedImage, forState: .Highlighted)
		
		let imageAspectRatio = buttonImage.size.width / buttonImage.size.height
		button.frame.size = CGSize(width: width, height: width/imageAspectRatio)
		return UIBarButtonItem(customView: button)
	}
}

/// Conforming `UINavigationBar` objects to `BarView` protocol.
extension UINavigationBar: BarView {
	/* empty */
}

/// Conforming `UIToolbar` objects to `BarView` protocol.
extension UIToolbar: BarView {
	/* empty */
}

/// Lightweight support for `UIButton` embedded in `UIBarButtonItem` instance.
extension UIBarButtonItem {
	
	var buttonView: UIButton! {
		return customView as? UIButton
	}
	
	var hidden: Bool {
		get {
			return customView!.hidden
		}
		set {
			customView!.hidden = newValue
		}
	}
}
