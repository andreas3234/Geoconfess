//
//  PriestPasswordViewController.swift
//  geoconfess
//
//  Created by whitesnow0827 on 3/5/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import AWSMobileAnalytics
import AWSCognito
import AWSS3
import AWSCore
import Photos
import MobileCoreServices
import AssetsLibrary
import Alamofire
import SwiftyJSON

final class PriestPasswordViewController: AppViewController,
										  UITextFieldDelegate,
										  UINavigationControllerDelegate,
										  UIImagePickerControllerDelegate {

    @IBOutlet weak var priestPasswordField: UITextField!
    @IBOutlet weak var priestConfirmField: UITextField!
    @IBOutlet weak var img_priestCheckPoint: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containProgressView: UIView!
	
	@IBOutlet weak private var signUpButton: UIButton!
	
    var isNotificationChecked : Bool = false
    var isPhotoUploaded: Bool = false
    var imagePicker: UIImagePickerController!
    var image: UIImage = UIImage()
    var celebretURL: NSURL = NSURL()
//
//    //handles upload
//    var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
//    
//    var uploadFileURL: NSURL?
   
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var filesize:Int64 = 0
    var amountUploaded:Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()

		resignFirstResponderWithOuterTouches(priestPasswordField, priestConfirmField)
		
        img_priestCheckPoint.hidden = true
        containProgressView.hidden = true
        view.alpha = 1.0
        
        // TODO: Configure authentication with Cognito.

		// Setting progress bar to 0.
        progressView.progress = 0.0
    }
	
    @IBAction func checkButtonTapped(sender: AnyObject) {
        isNotificationChecked = !isNotificationChecked
        if isNotificationChecked {
            self.img_priestCheckPoint.hidden = false
        } else {
            self.img_priestCheckPoint.hidden = true
        }
    }
    
    //Using Camera
    
    @IBAction func cameraButtonTapped(sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func update() {
        let percentageUploaded:Float = Float(amountUploaded) / Float(filesize) * 100
        
        print(NSString(format:"Chargement: %.0f%%", percentageUploaded) as String)
        
        let progress = Float(amountUploaded) / Float(filesize)
        self.containProgressView.hidden = false
        self.view.userInteractionEnabled = false
        self.view.alpha = 0.7
        self.progressView.progress = progress
        print("Progress is: %f",progress)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if(picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary) {
            //defining bucket and upload file name
            //getting actual image
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let imageData = UIImageJPEGRepresentation(image, 0.1)

            let path:NSString = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("image.jpg")
            imageData!.writeToFile(path as String, atomically: true)
            
            let url:NSURL = NSURL(fileURLWithPath: path as String)

            uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.bucket = "geoconfessapp"
            uploadRequest?.ACL = AWSS3ObjectCannedACL.PublicRead
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd_MM_yyyy_hh_mm_ss"
            let strKey:String = String(format: "%@.jpg", arguments: [dateFormatter.stringFromDate(NSDate())])

            uploadRequest?.key = strKey
            uploadRequest?.contentType = "image/jpeg"
            uploadRequest?.body = url;
            
            uploadRequest?.uploadProgress = {[unowned self](bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
                
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.amountUploaded = totalBytesSent
                    self.filesize = totalBytesExpectedToSend;
                    self.update()
                })
            }
            
            let transferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
            transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock:{ [unowned self]
                task -> AnyObject in
                
                if(task.error != nil){
                    print(task.error);
                }else{ // This is image url
                    self.containProgressView.hidden = true
                    self.view.userInteractionEnabled = true
                    self.view.alpha = 1.0
                    self.celebretURL = NSURL(string: String(format: "https://geoconfessapp.s3.amazonaws.com/%@", arguments: [strKey]))!
                    print(String(format: "https://geoconfessapp.s3.amazonaws.com/%@", arguments: [strKey]));
                    self.isPhotoUploaded = true
                    
                    if self.hasAllMandatoryFields {
                        self.signUpButton.enabled = true
                        self.signUpButton.backgroundColor = UIButton.enabledColor
                    } else {
                        self.signUpButton.enabled = false
                        self.signUpButton.backgroundColor = UIButton.disabledColor
                    }
                }
                
                return "all done";
                })

            
//            //defining bucket and upload file name
//            let S3BucketName: String = "geoconfess"
//            //setting temp name for upload
//            let S3UploadKeyName = "TestCameraUpload.png"
//            
//            //settings temp location for image
//            let imageName = NSURL.fileURLWithPath(NSTemporaryDirectory() + S3UploadKeyName).lastPathComponent
//            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
//            
//            // getting local path
//            let localPath = (documentDirectory as NSString).stringByAppendingPathComponent(imageName!)
//            print(String(localPath))
//            //getting actual image
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            let data = UIImageJPEGRepresentation(image, 0.1)
//            data!.writeToFile(localPath, atomically: true)
//            let photoURL = NSURL(fileURLWithPath: localPath)
//            
//            let expression = AWSS3TransferUtilityUploadExpression()
//            expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
//                dispatch_async(dispatch_get_main_queue(), {
//                    let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
//                    self.containProgressView.hidden = false
//                    self.view.userInteractionEnabled = false
//                    self.view.alpha = 0.7
//                    self.progressView.progress = progress
//                    NSLog("Progress is: %f",progress)
//                })
//            }
//            
//            self.uploadCompletionHandler = { (task, error) -> Void in
//                dispatch_async(dispatch_get_main_queue(), {
//                    if ((error) != nil){
//                        NSLog("Failed with error")
//                        NSLog("Error: %@",error!);
//                        //    self.statusLabel.text = "Failed"
//                    }
//                    else if(self.progressView.progress != 1.0) {
//                        //    self.statusLabel.text = "Failed"
//                        NSLog("Error: Failed - Likely due to invalid region / filename")
//                    }
//                    else{
//                        //    self.statusLabel.text = "Success"
//                        NSLog("Sucess")
//                        self.containProgressView.hidden = false
//                        self.view.userInteractionEnabled = true
//                        self.view.alpha = 1.0
//                    }
//                })
//            }
//            
//            let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
//            transferUtility.uploadFile(photoURL, bucket: S3BucketName, key: strKey, contentType: "image/jpeg", expression: expression, completionHander: uploadCompletionHandler).continueWithBlock { (task) -> AnyObject! in
//                if let error = task.error {
//                    NSLog("Error: %@",error.localizedDescription);
//                    //  self.statusLabel.text = "Failed"
//                }
//                if let exception = task.exception {
//                    NSLog("Exception: %@",exception.description);
//                    //   self.statusLabel.text = "Failed"
//                }
//                if let _ = task.result {
//                    // self.statusLabel.text = "Generating Upload File"
//                    NSLog("Upload Starting!")
//                    // Do something with uploadTask.
//                    self.celebretURL = NSURL(string: "https://(S3BucketName).s3.amazonaws.com/\(strKey)")!
//                    NSLog(String(self.celebretURL))
//                }
//                
//                return nil;
//            }
            
            //end if photo library upload
            self.dismissViewControllerAnimated(true, completion: nil);
            
        }
    }
	
	// MARK: - UITextFieldDelegate Protocol
	
	/// Called when 'return' key pressed. return NO to ignore.
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	/// The text field calls this method whenever the user types a new
	/// character in the text field or deletes an existing character.
	func textField(textField: UITextField,
	shouldChangeCharactersInRange range: NSRange, replacementString replacement: String)
	-> Bool {
		let textBeforeChange: NSString = textField.text!
		let textAfterChange = textBeforeChange.stringByReplacingCharactersInRange(
			range, withString: replacement)
		
		updatePasswordInfoFrom(textField, with: textAfterChange)
		if hasAllMandatoryFields {
			signUpButton.enabled = true
			signUpButton.backgroundColor = UIButton.enabledColor
		} else {
			signUpButton.enabled = false
			signUpButton.backgroundColor = UIButton.disabledColor
		}
		return true
	}
	
	// MARK: - Password Information
	
	private var priestPassword: String = ""
	private var confirmPriestPassword: String  = ""
	
	private func updatePasswordInfoFrom(textField: UITextField, with text: String) {
		if textField === priestPasswordField {
			priestPassword = text
		} else if textField === priestConfirmField {
			confirmPriestPassword = text
		} else {
			preconditionFailure("unexpected field")
		}
	}
	
	private var hasAllMandatoryFields: Bool {
		return !priestPassword.isEmpty && !confirmPriestPassword.isEmpty && self.isPhotoUploaded
	}

    @IBAction func signUpButtonTapped(sender: AnyObject) {
		precondition(hasAllMandatoryFields)
		guard User.isValidPassword(priestPassword) else {
			let alertView = UIAlertView(title: nil,
				message: "Le mot de passe doit faire au moins 6 caractères.",
				delegate: self, cancelButtonTitle: "OK")
			alertView.show()
			return
		}
		guard priestPassword == confirmPriestPassword else {
			let alertView = UIAlertView(title: nil,
				message: "Les mots de passe doivent être identiques.",
				delegate: self, cancelButtonTitle: "OK")
			alertView.show()
			return
		}
		signUpPriest()
	}
	
	private func signUpPriest() {
		let URL = NSURL(string: "https://geoconfess.herokuapp.com/api/v1/registrations")
		let params = [
			"user[role]" : "priest",
			"user[email]" : priestEmail,
			"user[password]" : priestPassword,
			"user[name]" : priestName,
			"user[surname]" : priestSurname,
			"user[notification]" : isNotificationChecked.description,
			"user[newsletter]" : "true",
			"user[phone]" : priestTelephon,
//			"user[parish_attributes][name]" : parishName,
//			"user[parish_attributes][email]" : parishEmail,
			"user[celebret_url]" : celebretURL
		]
		MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		
		Alamofire.request(.POST, URL!, parameters: params).responseJSON {
			response in
			switch response.result {
			case .Success(let data):
				let jsonResult = JSON(data)
				if jsonResult["result"].string == "success" {
					//let successAlert = UIAlertView(title: nil,
					//	message: "Priest Registration Success",
					//	delegate: self, cancelButtonTitle: "OK")
					MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
					self.loginPriest()
					//successAlert.show()
				} else {
					var alertMessage = ""
					let errorResult = jsonResult["errors"].dictionary
					let errorJson = JSON(errorResult!)
					
					if let emailError = errorJson["email"][0].string
						where emailError != "" {
							alertMessage += "email " + emailError
					}
					if let passwordError = errorJson["password"][0].string
						where passwordError != "" {
							alertMessage += "password " + passwordError
					}
					if let phoneError = errorJson["phone"][0].string
						where phoneError != "" {
							alertMessage += "phoneNumber " + phoneError
					}

					let failureAlert = UIAlertView(title: nil,
						message: alertMessage, delegate: self, cancelButtonTitle: "OK")
					MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
					failureAlert.show()
				}
				
			case .Failure(let error):
				let connectionFailure_alert = UIAlertView(title: nil, message: "Pas de connexion internet detectée", delegate: self, cancelButtonTitle: "OK")
				connectionFailure_alert.show()
				print("Request Failed Reason: \(error)")
				MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
				
			}
		}
	}
	
	private func loginPriest() {
		MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		User.loginInBackground(username: priestEmail, password: priestPassword) {
			(user, error) -> Void in
			MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
			if let error = error {
				JLToast.makeText(error.description, duration: JLToastDelay.LongDelay).show()
				return
			}
			assert(user != nil)
			self.performSegueWithIdentifier("enterApp", sender: self)
		}
	}
}
