//
//  UILabel+AutoHeight.swift
//  GeoConfess
//
//  Created by MobileGod on 4/28/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

extension UILabel{
    
//    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
//        let attributes = [NSFontAttributeName : font]
//        numberOfLines = 0
//        lineBreakMode = NSLineBreakMode.ByWordWrapping
//        let rect = self.text!.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
//        heightConstraint.constant = rect.height
//        setNeedsLayout()
//    }
    
    func ResizeHeigthWithText(label: UILabel)
    {
        self.layoutIfNeeded()
        let attributes = [NSFontAttributeName : font]
        let width = label.frame.width
        var labelFrame = label.frame
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.ByWordWrapping
        let rect = self.text!.boundingRectWithSize(CGSizeMake(frame.size.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        labelFrame.size = CGSize(width: width, height: rect.size.height)
        label.frame = labelFrame
    }
    
//    func updateLabelWidths() {
//        // force views to layout in viewWillAppear so we can adjust widths of labels before the view is visible
//        self.layoutIfNeeded()
//        self.ResizeHeigthWithText(self)
//    }
}