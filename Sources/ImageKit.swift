//
//  ImageKit.swift
//  GeoConfess
//
//  Created by Paulo Mattos on 14/04/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import Foundation

/// Useful extensions for UI-oriented image manipulation.
extension UIImage {
	
	/// Returns a new image *tinted* by the specified color.
	func tintedImageWithColor(tintColor: UIColor) -> UIImage {
		return filterImage {
			context in
			let imageRect = CGRectMake(0, 0, size.width, size.height)
			
			// Multiplies original image with tint color.
			// Alpha channel is lost.
			tintColor.setFill()
			CGContextFillRect(context, imageRect)
			drawInRect(imageRect, blendMode: .Overlay, alpha: 1.0)
			
			// Mode CGBlendMode.Overlay doesn’t take the source alpha into account.
			// So we need to mask by alpha values of original image (ie, R = D*Sa).
			drawInRect(imageRect, blendMode: .DestinationIn, alpha: 1.0)
		}
	}
	
	/// Applies a generic filter on the current image-based context.
	///
	/// Code highly based on the following sources:
	/// * https://robots.thoughtbot.com/designing-for-ios-blending-modes
	/// * http://stackoverflow.com/a/7377827/819340
	private func filterImage(@noescape filteringCode: (context: CGContextRef?) -> Void)
	-> UIImage {
		// For correct resolution on retina, thanks @MobileVet.
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		let context: CGContextRef? = UIGraphicsGetCurrentContext()
		
		/* 
		// Core graphics has a lower-left origin, but we will capture
		// back the rendered image so it doesn't matter :-)
		CGContextTranslateCTM(context, 0, size.height)
		CGContextScaleCTM(context, 1.0, -1.0)
		*/
		
		filteringCode(context: context)
		
		var filtedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		filtedImage = filtedImage.imageWithRenderingMode(.AlwaysOriginal)
		assert(filtedImage.scale == self.scale)
		return filtedImage
	}
}

/// Color hacking.
extension UIColor {
	
	/// Blends rhis color with the specified color.
	func blendedColorWith(anotherColor: UIColor, usingWeight weight: CGFloat)
	-> UIColor {
		let x = self.rgba
		let y = anotherColor.rgba
		
		func lerp(a: CGFloat, _ b: CGFloat) -> CGFloat {
			return a*weight + b*(1 - weight)
		}
		
		let red   = lerp(x.red,   y.red)
		let green = lerp(x.green, y.green)
		let blue  = lerp(x.blue,  y.blue)
		let alpha = lerp(x.alpha, y.alpha)
		
		return UIColor(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	/// Returns **RGBA** color components.
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		var red:   CGFloat = 0
		var green: CGFloat = 0
		var blue:  CGFloat = 0
		var alpha: CGFloat = 0
		
		let converted = getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		assert(converted)
		return (red: red, green: green, blue: blue, alpha: alpha)
	}
}
