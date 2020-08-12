//
//  VehicleLocation.swift
//  MBTAWatch
//
//  Created by QIANG on 6/30/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTAVehicle : NSObject {
    
    open var vehicle_id: String
    open var vehicle_lat: String
    open var vehicle_lon: String
    open var vehicle_speed: String
    open var vehicle_timestamp: String
    
    public init(jsonData: NSDictionary) {
        self.vehicle_id = jsonData["vehicle_id"] as! String
        self.vehicle_lat = jsonData["vehicle_lat"] as! String
        self.vehicle_lon = jsonData["vehicle_lon"] as! String
        
        self.vehicle_speed = "0"
        if let item = jsonData["vehicle_speed"] as? String {
            self.vehicle_speed = item
        }
        
        self.vehicle_timestamp = jsonData["vehicle_timestamp"] as! String
        
        super.init()
    }
    
    // Convinent constructor, take only vehicle_id, setup every field to be ""
    public init(vehicle_id: String) {
        self.vehicle_id = ""
        self.vehicle_lat = ""
        self.vehicle_lon = ""
        self.vehicle_speed = ""
        self.vehicle_timestamp = ""
        
        super.init()
    }
}
