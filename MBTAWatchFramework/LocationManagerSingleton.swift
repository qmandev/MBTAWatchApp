//
//  LocationManager.swift
//  MBTAWatch
//
//  Created by QIANG on 6/29/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import MapKit

open class LocationManagerSingleton: NSObject, CLLocationManagerDelegate {
    
    var locationMgr = CLLocationManager()
    
    // http://stackoverflow.com/questions/11513259/ios-cllocationmanager-in-a-separate-class
    // You can access the lat and long by calling:
    // currentLocation2d.latitude, etc
    open var currentLocation2d: CLLocationCoordinate2D?
    open var location: CLLocation?
    
    
    class var manager: LocationManagerSingleton {
        return SharedUserLocation
    }
    
    public override init()
    {
        super.init()
        
        if (self.locationMgr.responds(to: #selector(self.locationMgr.requestAlwaysAuthorization))) {
            self.locationMgr.requestAlwaysAuthorization()
        }
        self.locationMgr.delegate = self
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest

        self.locationMgr.requestAlwaysAuthorization()
        
        // self.locationMgr.distanceFilter = 50 // Minimum distance a device must be moved for new location
        
        // This is been removed after ios9 upgrade
        //self.locationMgr.startUpdatingLocation()
    }
    
    open func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        self.currentLocation2d = manager.location!.coordinate
        self.location = manager.location
    }
    
    /*
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //
    }*/
    
}

let SharedUserLocation = LocationManagerSingleton()
