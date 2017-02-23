//
//  RiderViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Yuri Shkoda on 1/28/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    func displayAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    var locationManager = CLLocationManager()
    
    var riderRequestActive = false
    
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    @IBAction func callUber(_ sender: Any) {
        
        if riderRequestActive {
        
            callUberButton.setTitle("Call an Uber", for: [])
            
            riderRequestActive = false
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                
                    for riderRequest in riderRequests {
                    
                        riderRequest.deleteInBackground()
                    
                    }
                
                }
                
            })
        
        } else {
        
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
            
                riderRequestActive = true
                
                self.callUberButton.setTitle("Cancel Uber", for: [])
                
                let riderRequest = PFObject(className: "RiderRequest")
                
                riderRequest["username"] = PFUser.current()?.username
                
                riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                
                riderRequest.saveInBackground(block: { (success, error) in
                    
                    if success {
                        
                        print("Called an Uber")
                    
                    } else {
                    
                        self.callUberButton.setTitle("Call an Uber", for: [])
                        
                        self.riderRequestActive = false
                        
                        self.displayAlert(title: "Could not call Uber", message: "Please try again latter")
                        
                    }
                    
                })
            
            } else {
            
                displayAlert(title: "Could not call Uber", message: "Can not detect your location")
            
            }
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "logoutSegue" {
            
            locationManager.stopUpdatingLocation()
        
            PFUser.logOut()
        
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        callUberButton.isHidden = true
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground { (objects, error) in
            
            if objects != nil {
            
                if objects?.count != 0 {
                    
                    self.riderRequestActive = true
                    
                    self.callUberButton.setTitle("Cancel Uber", for: [])
                    
                }
            
            }
            
            self.callUberButton.isHidden = false
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
        
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.map.setRegion(region, animated: true)
            
            self.map.removeAnnotations(self.map.annotations)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = userLocation
            
            annotation.title = "Your location"
            
            self.map.addAnnotation(annotation)
            
            let query = PFQuery(className: "RiderRequest")
                
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
                
            query.findObjectsInBackground(block: { (objects, error) in
                    
                if let riderRequests = objects {
                        
                    for riderRequest in riderRequests {
                            
                        riderRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                            
                        riderRequest.saveInBackground()
                            
                    }
                        
                }
                    
            })
        
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
