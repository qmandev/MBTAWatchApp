//
//  MBTAPrediction.swift
//  MBTAWatch
//
//  Created by QIANG on 6/30/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation

open class MBTAPrediction : NSObject {
    
    open var pre_dt: String
    open var pre_away: String
    
    public init(jsonData: NSDictionary) {
        
        self.pre_dt = ""
        if let item = jsonData["pre_dt"] as? String {
            self.pre_dt = item
        }
        
        self.pre_away = ""
        if let item = jsonData["pre_away"] as? String {
            self.pre_away = item
        }
        
        super.init()
    }
    
    public init(pre_dt : String, pre_away : String) {
        self.pre_dt = pre_dt
        self.pre_away = pre_away
        
        super.init()
    }
    
    open var arriveTime: String {

        let dateFormator = DateFormatter()
        dateFormator.timeStyle = DateFormatter.Style.long
        // Do not show day, only show time
        // dateFormator.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormator.timeZone = TimeZone.current
        
        let dt_time = Date(timeIntervalSince1970: (self.pre_dt as NSString).doubleValue)
        
        return dateFormator.string(from: dt_time)

    }
    
    open var awaySeconds: String {

        return printSecondsToHoursMinutesSeconds(Int(self.pre_away)!)
 
    }
    
    // Utility method to convert seconds to HH:MM:SS
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    // Display format
    func printSecondsToHoursMinutesSeconds (_ seconds:Int) -> (String) {
        
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds)
        
        if ( h != 0 && m != 0 ) {
            return  "\(h)h, \(m)m, \(s)s"
        }
        else if ( m != 0) {
            return  "\(m)m, \(s)s"
        }
        else {
            return  "\(s)s"
        }
    }
}
