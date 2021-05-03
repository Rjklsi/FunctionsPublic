//
//  ViewController.swift
//  CommonFunctions
//
//  Created by mac on 03/05/21.
//

import UIKit
import CoreLocation
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    //reverse geocoding without google map
    func latLong(lat: Double,long: Double)  {

       let geoCoder = CLGeocoder()
       let location = CLLocation(latitude: lat , longitude: long)
       geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

           print("Response GeoLocation : \(placemarks)")
           var placeMark: CLPlacemark!
           placeMark = placemarks?[0]
        
        let address = placeMark.postalAddress
        let street = address?.street
        let city = address?.city
        let country = address?.country
        let state = address?.state
        let post = address?.postalCode
        let locality = address?.subLocality
       var userAddress = "\(address?.subLocality) \(address!.street) \(address?.city) \(address?.state) \(address?.country) \(address?.postalCode) "
        if locality != "" {
            self.userAddress += "\(locality!)"
        }
        if street != "" {
            self.userAddress += ", \(street!)"
        }
        if city != "" {
            self.userAddress += ", \(city!)"
        }
        if state != "" {
            self.userAddress += ", \(state!)"
        }
        if country != "" {
            self.userAddress += ", \(country!)"
        }
        if post != "" {
            self.userAddress += ", \(post!)"
        }
        
        
       })
   }

    
}

