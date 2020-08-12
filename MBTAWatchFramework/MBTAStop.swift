//
//  TransitStop.swift
//  MBTAWatch
//
//  Created by QIANG on 5/13/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation
import MapKit

open class MBTAStop : NSObject, MKAnnotation {
    
    open let stop_id: String
    open var stop_name: String
    open var parent_station: String
    open var parent_station_name: String
    open var stop_lat: String
    open var stop_lon: String
    open var distance: String
    open var prediction: MBTAPrediction
    
    public init(jsonData: NSDictionary) {
        self.stop_id = jsonData["stop_id"] as! String
        self.stop_name = jsonData["stop_name"] as! String
        
        self.parent_station = ""
        if let item = jsonData["parent_station"] as? String {
            self.parent_station = item
        }
        
        self.parent_station_name = ""
        if let item = jsonData["parent_station_name"] as? String {
            self.parent_station_name = item
        }
        
        self.stop_lat = ""
        if let item = jsonData["stop_lat"] as? String {
            self.stop_lat = item
        }
        
        self.stop_lon = ""
        if let item = jsonData["stop_lon"] as? String {
            self.stop_lon = item
        }
        
        self.distance = "0"
        if let item = jsonData["distance"] as? String {
            self.distance = item
        }
        
        self.prediction = MBTAPrediction(pre_dt: "", pre_away: "")
        if let item = jsonData["pre_dt"] as? String {
            self.prediction.pre_dt = item
        }
        if let item = jsonData["pre_away"] as? String {
            self.prediction.pre_away = item
        }
        
        super.init()
    }
    
    open var title: String? {
        return self.stop_name
    }
    
    open var subtitle: String? {
        return "Stop: " + self.stop_id
    }
    
    open var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: (self.stop_lat as NSString).doubleValue, longitude: (self.stop_lon as NSString).doubleValue)
    }
}
