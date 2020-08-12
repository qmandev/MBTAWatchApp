//
//  MBTAMode.swift
//  MBTAWatch
//
//  Created by QIANG on 7/8/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTAMode : NSObject {
    
    open var route_type: String
    open var mode_name: String
    open var routes: [MBTARoute]
    
    public init(jsonData: NSDictionary) {
        self.route_type = jsonData["route_type"] as! String
        self.mode_name = jsonData["mode_name"] as! String
        self.routes = [MBTARoute]()
        
        if let items = jsonData["route"] as? NSArray {
            for item in items {
                let singleRoute = MBTARoute(jsonData: item as! NSDictionary, route_type: self.route_type, mode_name: self.mode_name)
                routes.append(singleRoute)
            }
        }
        
        super.init()
    }
}
