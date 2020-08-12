//
//  MBTATrip.swift
//  MBTAWatch
//
//  Created by QIANG on 7/10/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTATrip : NSObject {
    
    open var trip_id: String
    open var trip_name: String
    open var trip_headsign: String
    open var schedule: MBTASchedule
    open var prediction: MBTAPrediction
    open var stops : [MBTAStop]
    open var vehicles: [MBTAVehicle]
    open var oneVehicle: MBTAVehicle
    open var direction_name: String
    open var mode_name: String
    open var route_name: String
    open var current_stop_id: String
    
    public init(jsonData: NSDictionary, direction_name: String, mode: String, route_name: String) {
        self.trip_id = jsonData["trip_id"] as! String
        self.trip_name = jsonData["trip_name"] as! String
        self.trip_headsign = jsonData["trip_headsign"] as! String
        self.schedule = MBTASchedule(jsonData: jsonData)
        self.prediction = MBTAPrediction(jsonData: jsonData)
        
        self.oneVehicle = MBTAVehicle(vehicle_id: "")
        if let item = jsonData["vehicle"] as? NSDictionary {
            self.oneVehicle = MBTAVehicle(jsonData: item)
        }
        
        self.stops = [MBTAStop]()
        if let items = jsonData["stop"] as? NSArray {
            for item in items {
                let oneStop = MBTAStop(jsonData: item as! NSDictionary)
                stops.append(oneStop)
            }
        }
        
        self.vehicles = [MBTAVehicle]()
        if let items = jsonData["vehicle"] as? NSArray {
            for item in items {
                let oneVehicle = MBTAVehicle(jsonData: item as! NSDictionary)
                vehicles.append(oneVehicle)
            }
        }
        
        self.direction_name = direction_name
        self.mode_name = mode
        self.route_name = route_name
        
        self.current_stop_id = ""
        
        super.init()
    }
    
    // Convinent constructor, take only vehicle_id, setup every field to be ""
    public init(currentStop : MBTAStop) {
        self.trip_id = ""
        self.trip_name = ""
        self.trip_headsign = ""
        self.schedule = MBTASchedule(sch_arr_dt: "", sch_dep_dt: "") 
        self.prediction = MBTAPrediction(pre_dt: "", pre_away: "")
        self.stops = [MBTAStop]()
        self.vehicles = [MBTAVehicle]()
        self.oneVehicle = MBTAVehicle(vehicle_id: "")
        self.direction_name = ""
        self.mode_name = ""
        self.route_name = ""
        self.current_stop_id = currentStop.stop_id
        
        super.init()
    }
    
}
