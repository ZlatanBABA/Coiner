//
//  MapViewController.swift
//  FirebaseAuth
//
//  Created by LiuKangping on 14/09/16.
//  Copyright © 2016 leomac. All rights reserved.
//

import UIKit
import MapKit
//import Mapbox
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var username : String!
    var useremail : String!
    var MoneyAmount : String!
    var country : String!
    
    var initPhase : Bool = true
    var locationManager : CLLocationManager!
    
    var neibors = [String: MKPointAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            self.mapView.delegate = self
            self.mapView.showsUserLocation = true
            self.mapView.userLocation.title = self.username
            self.mapView.userLocation.subtitle = self.MoneyAmount
            
            //            self.annotation.title = self.username
            //            self.annotation.subtitle = self.MoneyAmount
            //            self.mapView.addAnnotation(self.annotation)
            
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            //updateAnnotations()
        }
    }
    
    // called when location get updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        //        // only for testing purpose
        //        self.annotation.coordinate = location.coordinate
        
        if initPhase == true {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            
            initPhase = false
        }
        
        // post my location to database
        let dataBaseRef = FIRDatabase.database().reference()
        
        let postItems: [String : Double] = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude]
        
        dataBaseRef.child("Country").child(self.country!).child(self.useremail).updateChildValues(postItems)
    }
    
    // custom annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        let detailButton: UIButton = UIButton(type: UIButtonType.detailDisclosure)
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named: "custom_pin.png")
            annotationView!.rightCalloutAccessoryView = detailButton
        }
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    // called when an annotation is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation view is selected")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Annotation view's information button is clicked")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // retrieve annotations from firebase and add them to the map
    func updateAnnotations() {
        
        // create a database reference
        let dataBaseRef = FIRDatabase.database().reference()
        
        dataBaseRef.child("users").observe(FIRDataEventType.childChanged, with:{  (snapshot) in
            
            let temp = self.useremail!.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            if temp != snapshot.key {
                
                if snapshot.childSnapshot(forPath: "latitude").value != nil && snapshot.childSnapshot(forPath: "longitude").value != nil {
                    
                    let lat = snapshot.childSnapshot(forPath: "latitude").value as! CLLocationDegrees
                    let long = snapshot.childSnapshot(forPath: "longitude").value as! CLLocationDegrees
                    let newCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    if lat == -1 && long == -1 {
                        
                        if self.neibors.keys.contains(snapshot.key) == true {
                            // this user has logged out, remove it from neibors and annotation
                            let itsAnnotation = self.neibors[snapshot.key]! as MKPointAnnotation
                            
                            self.mapView.removeAnnotation(itsAnnotation)
                            self.neibors[snapshot.key] = nil
                            
                            print("Remove user : ", snapshot.key)
                        }
                        
                    } else {
                        // a new neighbour
                        if self.neibors.keys.contains(snapshot.key) == false {
                            print("A new neighbour : ", snapshot.key, " latitude : ", lat, " longitutde : ", long)
                            
                            // add new user to neibo list and create an annotation for it
                            let newAnnotation : MKPointAnnotation = MKPointAnnotation()
                            
                            self.neibors[snapshot.key] = newAnnotation
                            
                            newAnnotation.title = "test"
                            newAnnotation.subtitle = "0"
                            newAnnotation.coordinate = newCoordinate
                            
                            self.mapView.addAnnotation(newAnnotation)
                            
                        } else {
                            
                            print("Update user : ", snapshot.key, " location")
                            
                            // update user location
                            let itsAnnotation : MKPointAnnotation = self.neibors[snapshot.key]!
                            
                            itsAnnotation.coordinate = newCoordinate
                        }
                    }
                }
            }
            
        }) { (error) in
            print("An error occurred while retrieving data")
        }
        
    }
    
    // stop all the observers
    override func viewWillDisappear(_ animated: Bool) {
        print("map view exit, clear all handlers")
        
        let dataBaseRef = FIRDatabase.database().reference()
        dataBaseRef.child("Country").removeAllObservers()
    }
    
    // called when user changed the map region
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // current selected region
        //self.mapView.region
        print("User dragged the map")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
