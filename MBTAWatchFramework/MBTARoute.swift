//
//  MBTARoute.swift
//  MBTAWatch
//
//  Created by QIANG on 6/30/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTARoute : NSObject {

    open var route_id: String
    open var route_name: String
    open var direction: [MBTADirection]
    open var route_type: String
    open var mode_name: String
    
    /*
    public init(jsonData: NSDictionary) {
        self.route_id = jsonData["route_id"] as! String
        self.route_name = jsonData["route_name"] as! String
        
        self.direction = [MBTADirection]()
        if let items = jsonData["direction"] as? NSArray {
            for item in items {
                let oneDirection = MBTADirection(jsonData: item as! NSDictionary)
                direction.append(oneDirection)
            }
        }
        
        self.route_type = ""
        self.mode_name = ""
        
        super.init()
    }
    */
    
    public init(jsonData: NSDictionary, route_type: String, mode_name: String) {
        self.route_id = jsonData["route_id"] as! String
        self.route_name = jsonData["route_name"] as! String
        
        self.direction = [MBTADirection]()
        if let items = jsonData["direction"] as? NSArray {
            for item in items {
                let oneDirection = MBTADirection(jsonData: item as! NSDictionary, mode: mode_name, route_name: self.route_name)
                direction.append(oneDirection)
            }
        }
        
        self.route_type = route_type
        self.mode_name = mode_name
        
        super.init()
    }
}
