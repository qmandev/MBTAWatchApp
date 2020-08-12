//
//  MBTASchedule.swift
//  MBTAWatch
//
//  Created by QIANG on 7/10/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTASchedule : NSObject {
    
    open var sch_arr_dt: String
    open var sch_dep_dt: String
    
    public init(jsonData: NSDictionary) {
        
        self.sch_arr_dt = ""
        if let item = jsonData["sch_arr_dt"] as? String {
            self.sch_arr_dt = item
        }

        self.sch_dep_dt = ""
        if let item = jsonData["sch_dep_dt"] as? String {
            self.sch_dep_dt = item
        }
        
        super.init()
    }
    
    public init(sch_arr_dt : String, sch_dep_dt : String) {
        self.sch_arr_dt = sch_arr_dt
        self.sch_dep_dt = sch_dep_dt
        
        super.init()
    }
}
