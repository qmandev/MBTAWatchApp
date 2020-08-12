//
//  MBTAAlert.swift
//  MBTAWatch
//
//  Created by QIANG on 6/30/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTAAlert : NSObject {
    
    open var alert_id: String
    open var header_text: String
    open var effect_name: String
    
    public init(jsonData: NSDictionary) {
        self.alert_id = jsonData["alert_id"] as! String
        self.header_text = jsonData["header_text"] as! String
        self.effect_name = jsonData["effect_name"] as! String
        
        super.init()
    }
}
