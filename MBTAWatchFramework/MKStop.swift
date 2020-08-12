//
//  MKStop.swift
//  MBTAWatch
//
//  Created by QIANG on 7/14/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import MapKit

open class MKStop : NSObject, MKAnnotation {
    
    open let title: String?
    open let locationName: String?
    open let coordinate: CLLocationCoordinate2D
    
    open var subtitle: String? {
        return locationName
    }
    
    public init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
}
