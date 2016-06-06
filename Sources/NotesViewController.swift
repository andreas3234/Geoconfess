//
//  NoteViewController.swift
//  GeoConfess
//
//  Created by Arman Manukyan on 3/18/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

/// Controls the note taking UI.
final class NotesViewController: AppViewControllerWithToolbar, UITextViewDelegate {

    @IBOutlet private weak var notesTextView: UITextView!
	@IBOutlet private weak var notesBottomConstraint: NSLayoutConstraint!
	
	// MARK: - View Controller Lifecyle
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setOkButton()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		okButton.hidden = true
		notesTextView.text = loadNotes()
	}

    override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		saveNotes(notesTextView.text)
    }
	
	/// Handles keyboard over notes view.
 	/// TL;DR: You are not expected to understand this :-)
	override func keyboardDidShow(keyboardFrame: CGRect) {
		let supeview = notesTextView.superview!

		// Calculates the cursor baseline position in superview coordinates.
		let selectionStart = notesTextView.selectedTextRange!.start
		let cursorRect = notesTextView.caretRectForPosition(selectionStart)
		let cursorY = supeview.convertRect(cursorRect, fromView: notesTextView).maxY
		assert(cursorY > 0)
		
		let keyboardHeight = supeview.convertRect(keyboardFrame, fromView: nil).height
		let toolbarHeight  = navigationController.toolbar.frame.height
		let bottomMargin   = abs(notesBottomConstraint.constant)
		let bottomY        = supeview.frame.maxY - keyboardHeight - bottomMargin
		
		// 1. Move the view's origin up so that the text won't be hidden by the keyboard.
		// 2. Decrease the view's height so that we block the ared behind the keyboard.
		notesDefaultHeight   = notesTextView.frame.size.height
		notesDefaultOriginY  = notesTextView.frame.origin.y
		let yOffset = cursorY > bottomY ? cursorY - bottomY : 0
		let hiddenByKeyboard = keyboardHeight - toolbarHeight
		notesTextView.frame.size.height -= hiddenByKeyboard - yOffset
		if yOffset > 0 {
			UIView.animateWithDuration(0.30) {
				self.notesTextView.frame.origin.y -= yOffset
			}
		}
	}
	
	private var notesDefaultHeight: CGFloat!
	private var notesDefaultOriginY: CGFloat!
	
	override func keyboardWillHide(keyboardFrame: CGRect) {
		guard notesDefaultHeight != nil && notesDefaultOriginY != nil else { return }
		notesTextView.frame.size.height = notesDefaultHeight
		notesTextView.frame.origin.y    = notesDefaultOriginY
	}

	func textViewDidBeginEditing(textView: UITextView) {
		okButton.hidden = false
	}
	
	func textViewDidEndEditing(textView: UITextView) {
		okButton.hidden = true
		saveNotes(notesTextView.text)
	}
	
	// MARK: - OK Button
	
	private var okButton: UIButton!
	
	private func setOkButton() {
		okButton = UIButton(type: .System)
		okButton.setTitle("OK", forState: .Normal)
		okButton.titleLabel!.font = UIFont(name: "adventpro-Bd3", size: 16.5)!
		okButton.sizeToFit()
		
		okButton.addTarget(
			self, action: #selector(NotesViewController.okButtonTapped(_:)),
			forControlEvents: .TouchUpInside)
		
		let okButtonItem = UIBarButtonItem(customView: okButton)
		navigationItem.rightBarButtonItem = okButtonItem
	}
	
	@objc private func okButtonTapped(buttton: UIButton) {
		notesTextView.resignFirstResponder()
	}
	
	// MARK: - Notes Storage
	
	private var notesKey: String {
		return "\(User.current.id).notes"
	}
	
	private func loadNotes() -> String {
		let defaults = NSUserDefaults.standardUserDefaults()
		if let notes = defaults.stringForKey(notesKey) {
			return notes
		} else {
			return ""
		}
	}
	
	private func saveNotes(notes: String) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setObject(notes, forKey: notesKey)
	}
}
