//
//  Utilities.swift
//  GeoConfess
//
//  Created by Paulo Mattos on 31/03/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import Foundation
import GoogleMaps

// MARK: - Strings

private let whitespaces = NSCharacterSet.whitespaceAndNewlineCharacterSet()

public extension String {

	/// Removes whitespaces from both ends of the string.
	public func trimWhitespaces() -> String {
		return self.stringByTrimmingCharactersInSet(whitespaces)
	}
	
	/// A new string made by deleting the extension
	/// (if any, and only the last) from the receiver.
	public var stringByDeletingPathExtension: String {
		let string: NSString = self
		return string.stringByDeletingPathExtension
	}
	
	/// The last path component.
	/// This property contains the last path component. For example:
	///
	/// 	 /tmp/scratch.tiff ➞ scratch.tiff
	/// 	 /tmp/scratch ➞ scratch
	/// 	 /tmp/ ➞ tmp
	///
	public var lastPathComponent: String {
		let string: NSString = self
		return string.lastPathComponent
	}
}

// MARK: - Regular Expressions

/// *Regex* creation syntax sugar (with no error handling).
///
/// For a quick guide, see:
/// * [NSRegularExpression Cheat Sheet and Quick Reference](http://goo.gl/5QzdhX)
public func regex(pattern: String, options: NSRegularExpressionOptions = [ ])
-> NSRegularExpression {
	let regex = try! NSRegularExpression(pattern: pattern, options: options)
	return regex
}

/// Useful extensions for NSRegularExpression objects.
public extension NSRegularExpression {
	
	/// Returns `true` if the specified string is fully matched by this regex.
	public func matchesString(string: String) -> Bool {
		// Ranges are based on the UTF-16 *encoding*.
		let length = string.utf16.count
		precondition(length == (string as NSString).length)
		
		let wholeString = NSRange(location: 0, length: length)
		let matches = numberOfMatchesInString(string, options: [ ], range: wholeString)
		return matches == 1
	}
}

// MARK: - The Bare Bones Logging API ™

public func log(message: String, file: String = #file, line: UInt = #line) {
	let fileName = file.lastPathComponent.stringByDeletingPathExtension
	print("ℹ️ [\(fileName):\(line)] \(message)")
}

public func logError(message: String, file: String = #file, line: UInt = #line) {
	let fileName = file.lastPathComponent.stringByDeletingPathExtension
	print("💀 [\(fileName):\(line)] \(message)")
}

// MARK: - Core Graphics

public func rect(x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
	return CGRectMake(x, y, width, height)
}

// MARK: - UIKit

/// Suporte para alertas, HUDs, etc.
extension UIViewController {

	/// Shows alert popup with only 1 button.
	func showAlert(title title: String? = nil, message: String, ok: (() -> Void)? = nil) {
		let alert = UIAlertController(
			title: title, message: message, preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Default) {
			(action: UIAlertAction) -> Void in
			ok?()
		}
		alert.addAction(okAction)
		presentViewController(alert, animated: true, completion: nil)
	}

	// TODO: Review both methods below: `showProgressHUD` and `hideProgressHUD`.
	// There might be a better API design.

	/// Creates a new HUD, adds it to this view controller view and shows it. 
	/// The counterpart to this method is `hideProgressHUD`.
	func showProgressHUD(animated: Bool = true) {
		MBProgressHUD.showHUDAddedTo(self.view, animated: animated)
	}
	
	/// Finds all the HUD subviews and hides them.
	func dismissProgressHUD(animated: Bool = true) {
		MBProgressHUD.hideAllHUDsForView(self.view, animated: animated)
	}

}

extension UIColor {
	
	/// Creates a opaque color object using the specified RGB component values.
	convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
		self.init(red: red, green: green, blue: blue, alpha: 1.0)
	}
}

// MARK: - AutoLayout

/// This constraint requires the item's attribute
/// to be exactly **equal** to the specified value
func equalsConstraint(
	item item: AnyObject, attribute attrib1: NSLayoutAttribute, value: CGFloat)
	-> NSLayoutConstraint {
		
	return layoutConstraint(
		item: item, attribute: attrib1,
		relatedBy: .Equal,
		toItem: nil, attribute: .NotAnAttribute, constant: value)
}

/// This constraint requires the first attribute
/// to be exactly *equal* to the second attribute.
func equalsConstraint(
	item item: AnyObject, attribute attrib1: NSLayoutAttribute,
	     toItem: AnyObject?, attribute attrib2: NSLayoutAttribute,
	     multiplier: CGFloat = 1.0, constant: CGFloat = 0.0)
	-> NSLayoutConstraint {
	
	return layoutConstraint(
		item: item, attribute: attrib1,
		relatedBy: .Equal,
		toItem: toItem, attribute: attrib2,
		multiplier: multiplier, constant: constant)
}

/// Syntax sugar for `NSLayoutConstraint` init.
func layoutConstraint(
	item item: AnyObject, attribute attrib1: NSLayoutAttribute,
	     relatedBy: NSLayoutRelation,
	     toItem: AnyObject?, attribute attrib2: NSLayoutAttribute,
	     multiplier: CGFloat = 1.0, constant: CGFloat = 0.0)
	-> NSLayoutConstraint {
	
	return NSLayoutConstraint(
		item: item, attribute: attrib1,
		relatedBy: relatedBy,
		toItem: toItem, attribute: attrib2,
		multiplier: multiplier, constant: constant)
}

// MARK: - Timer Class

/// A simple timer class based on the `NSTimer` class.
/// As the `NSTimer`, this also fires if the app in on the background.
final class Timer {
	
	// MARK: Private Stuff
	
	private let callback: Callback
	private var timer: NSTimer?
	
	private init(seconds: NSTimeInterval, repeats: Bool, _ callback: Callback) {
		precondition(seconds >= 0)
		self.callback = callback
		self.timer = NSTimer.scheduledTimerWithTimeInterval(
			NSTimeInterval(seconds),
			target: self, selector: #selector(Timer.timerDidFire),
			userInfo: nil, repeats: repeats)
	}
	
	@objc private func timerDidFire() {
		callback()
	}
	
	// MARK: Timer API
	
	typealias Callback = () -> Void
	
	/// Schedules timer and returns it. 
	/// If `repeats` is true a periodic timer is created.
	class func scheduledTimerWithTimeInterval(
		interval: NSTimeInterval, repeats: Bool = false, callback: Callback) -> Timer {
		
		return Timer(seconds: interval, repeats: repeats, callback)
	}
	
	/// Cancels timer.
	func dispose() {
		if let timer = self.timer {
			timer.invalidate()
			self.timer = nil
		}
	}
}

// MARK: - Core Location

extension CLLocation {
	
	convenience init(at location: CLLocationCoordinate2D) {
		self.init(latitude: location.latitude, longitude: location.longitude)
	}
}

// MARK: - Google Maps

extension GMSCameraPosition {
	
	/// Creates a `GMSCameraPosition` instance with default zoom level.
	convenience init(at location: CLLocationCoordinate2D, zoom: Float = 12.0) {
		self.init(target: location, zoom: zoom, bearing: 0, viewingAngle: 0)
	}
}

// MARK: - Weak References

/// Wrapper for *weak references*.
/// Useful for storing weak references in collections, for instance.
///
/// ♨️ **Android Hint**. This struct is very similar
/// to the **[java.lang.ref.WeakReference<T>](https://goo.gl/WQd8Je)** class.
struct Weak<T: AnyObject>: Equatable, Hashable, CustomStringConvertible {
	
	private weak var objectRef: T?
	private let stableAndFastHashValue: Int
	
	init(_ object: T) {
		self.objectRef = object
		self.stableAndFastHashValue = unsafeAddressOf(object).hashValue
	}
	
	var object : T? {
		return objectRef
	}
	
	var hashValue: Int {
		// It is not a good design to have a non-constant hashcode.
  		// For instance, this enables this struct to be safely used as dictionary keys.
		return stableAndFastHashValue
	}
	
	var description: String {
		let objectDesc: String
		if let object = objectRef {
			objectDesc = String(object)
		} else {
			objectDesc = "nil"
		}
		return "Weak(\(objectDesc))"
	}
}

/// `Equatable` protocol.
func ==<T: AnyObject>(lhs: Weak<T>, rhs: Weak<T>) -> Bool {
	return lhs.object === rhs.object
}
