
//
//  LocationClass.swift
//
//  Created by mac on 11/03/21.
//  Copyright © 2021 skilltop. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

class LocationManager: NSObject {
    /// Shared Instance
    static var shared = LocationManager()

    /// Location Manager
    let locationManager = CLLocationManager()

    // MARK: Request & Get Location

    func requestAndFetchLocation() {
        /// Request For Location Access
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
               // locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                
            case .restricted, .denied:
                let alertC = UIAlertController(title: AppName, message: "Location is off", preferredStyle: .alert)
                alertC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { _ in
                            self.locationManager.startUpdatingLocation()
                        })
                    }
                }))
                alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                //alertC.show()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            @unknown default:
                //locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
           
           //locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - Location Manager Delegate

extension LocationManager: CLLocationManagerDelegate {
    // MARK: Did Update Location

    func locationManager(_: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        /* --> /// Do not Stop Updating Location It's Required
         locationManager.stopUpdatingLocation()
         */
    }
}
