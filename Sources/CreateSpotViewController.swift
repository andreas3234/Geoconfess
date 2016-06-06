//
//  CreateSpotViewController.swift
//  geoconfess
//
//  Created by MobileGod on 4/8/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class CreateSpotViewController: AppViewControllerWithToolbar, MKMapViewDelegate, CLLocationManagerDelegate, CreateSpotFromMapDelegate {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
        // Paris Coordinate
    let initialLocation = CLLocation(latitude: 48.8534100, longitude: 2.3488000)
    let searchRadius: CLLocationDistance = 20000

        // Pin Description Button
    let PinButton = UIButton(type: .DetailDisclosure)
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
        // CoreLocation 
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var regionRadius: CLLocationDistance!
    
        // Spot ID
    var spotID: Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Intialize Search Text
        let paddingView = UIView(frame: CGRectMake(0, 0, 10, self.txtSearch.frame.height))
        txtSearch.leftView = paddingView
        txtSearch.leftViewMode = UITextFieldViewMode.Always
        
        // Initialize Core Location
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Map Initialize - Show the current location on mapview
        locationManager.startUpdatingLocation()
        regionRadius = searchRadius * 2
        // Initialize Delegate
        Networking.createSpotFromMapDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearch(sender: AnyObject) {
        
        regionRadius = 0.075
        
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.txtSearch.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = "Confirmer cette adresse"
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, self.regionRadius, self.regionRadius), animated: true)
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    @IBAction func myLocationButtonTapped(sender: UIButton) {
        regionRadius = 0.075
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - MapView Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Spot"
        
        if pinAnnotationView.isKindOfClass(MKAnnotationView) {
            if let pinAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                
                pinAnnotationView.annotation = annotation
                return pinAnnotationView
            } else {
                
                let pinAnnotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                pinAnnotationView.enabled = true
                pinAnnotationView.canShowCallout = true
                pinAnnotationView.animatesDrop = true
                
                let btn = UIButton(type: .ContactAdd)
                pinAnnotationView.rightCalloutAccessoryView = btn
                return pinAnnotationView
            }
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: pointAnnotation.coordinate.latitude, longitude: pointAnnotation.coordinate.longitude)) { (placemarks, error) in
            
            if (placemarks != nil) && (placemarks!.count > 0){
                
                let placeMark = placemarks![0]
                
                // Address dictionary
                let dictionary = placeMark.addressDictionary as! [NSString:AnyObject]
            
                var spotName: String?
                let alertVC = UIAlertController(title: "Type the Spot name.",
                                              message: "",
                                              preferredStyle: .Alert)
                alertVC.addTextFieldWithConfigurationHandler { textField -> Void in
                    //TextField configuration
                    textField.placeholder = "Spot Name"
                    spotName = textField.text
                }
                let okAction = UIAlertAction(title: "YES",
                                             style: UIAlertActionStyle.Default,
                                             handler: { (action:UIAlertAction) -> Void in
                                                
                                                spotName = alertVC.textFields![0].text
                                                let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
                                                if spotName?.stringByTrimmingCharactersInSet(whitespaceSet) != ""{
                                                    
                                                    Networking.createSpotFromMap(spotName!, activity_type: "static", latitude: self.pointAnnotation.coordinate.latitude, longitude: self.pointAnnotation.coordinate.longitude, street: dictionary["Street"] as! String, postcode: dictionary["ZIP"] as! String, city: dictionary["City"] as! String, state: dictionary["State"] as! String, country: dictionary["CountryCode"] as! String)
                                                }else{
                                                    let warningAlert = UIAlertController(
                                                        title: "Warning",
                                                        message: "Type the Spot name",
                                                        preferredStyle: UIAlertControllerStyle.Alert
                                                    )
                                                    let acceptAction = UIAlertAction(
                                                    title: "OK", style: UIAlertActionStyle.Default) { (action) in
                                                        
                                                        self.presentViewController(alertVC, animated: true, completion: nil)
                                                    }
                                                    warningAlert.addAction(acceptAction)
                                                    self.presentViewController(warningAlert, animated: true, completion: nil)
                                                }
                                                
                })
                
                let cancelAction = UIAlertAction(title: "NO",
                                                 style: .Default) { (action: UIAlertAction) -> Void in
                                                    
                                                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                
                alertVC.addAction(cancelAction)
                alertVC.addAction(okAction)
                
                self.presentViewController(alertVC,
                                      animated: true,
                                      completion: nil)
            } else {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                Utility.showAlert("Error", message: "Map Error", vc: self)
            }
        }
    }
   
    // MARK: - CreateSpotFromMapDelegate Methods
    
    func createSpotFromMapDidSucceed(data: JSON) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        spotID = data["id"].int64Value
        showAlert(title: "Succeed", message: "You created a spot successfully\nPlease create a recurrence.") { 
            self.performSegueWithIdentifier("gotoAddRecurrenceWithDate", sender: self)
        }
    }
    
    func createSpotFromMapDidFail(error: NSError) {
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        if error.code == -1003
        {
            Utility.showAlert("Error", message: "Your internet does not seem to be working.", vc: self)
        }else{
            Utility.showAlert("Error", message: error.localizedDescription, vc: self)
        }
    }
    
    // MARK: - CLLocation Methods Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error while updating location \(error.localizedDescription)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.delegate = self
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Navigation Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoAddRecurrenceWithDate" {
            let vc = segue.destinationViewController as! CreateRecurrenceWithDateViewController
            vc.spotID = spotID
        }
    }
}
