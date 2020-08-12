//
//  MBTADirection.swift
//  MBTAWatch
//
//  Created by QIANG on 7/10/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTADirection : NSObject {
    
    open var direction_id: String
    open var direction_name: String
    open var trips: [MBTATrip]
    open var stops: [MBTAStop]
    open var route_name: String
    
    public init(jsonData: NSDictionary, mode : String, route_name: String) {
        self.direction_id = jsonData["direction_id"] as! String
        self.direction_name = jsonData["direction_name"] as! String
        
        self.trips = [MBTATrip]()
        if let items = jsonData["trip"] as? NSArray {
            for item in items {
                let oneTrip = MBTATrip(jsonData: item as! NSDictionary, direction_name: self.direction_name, mode: mode, route_name: route_name)
                self.trips.append(oneTrip)
            }
        }

        self.stops = [MBTAStop]()
        if let items = jsonData["stop"] as? NSArray {
            for item in items {
                let oneStop = MBTAStop(jsonData: item as! NSDictionary)
                self.stops.append(oneStop)
            }
        }
        
        self.route_name = route_name
        
        super.init()
    }
}
