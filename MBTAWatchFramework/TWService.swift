//
//  TWService.swift
//  TWatch
//
//  Created by QIANG on 12/7/15.
//  Copyright © 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation
import CoreLocation

open class TWService {
    
    open static let sharedInstance : TWService =  TWService()
    let MBTAAPIKey: String = "fiVEsxwcjEmub4YK_Rtifw"
    
    // This prevents others from using the default '()' initializer for this class.
    fileprivate init() { }
    
    open func fetchTransitDataWithCompletionBlockStopsbylocation (_ completionHandler: @escaping (_ data: Data?, _ error: NSError?) -> Void, location: CLLocation) {
 
        let lat = String(location.coordinate.latitude)
        let lon =  String(location.coordinate.longitude)
        let queryParameter = "stopsbylocation"
        let query = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key="
        let currentLocation = "&lat=\(lat)&lon=\(lon)&format=json"
        
        let url = query + self.MBTAAPIKey + currentLocation
        
        let endpoint = URL(string: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: endpoint!, completionHandler: { (transitdata, response, error) -> Void in
        //
            if error != nil {
                    print(error!.localizedDescription)
            } else {
                completionHandler(transitdata, error as NSError?)
            }
        }) 
        task.resume()
    }
    
    open func fetchTransitDataWithCompletionBlockPredictionsByLocation (_ completionHandler: @escaping (_ data: Data?, _ error: NSError?) -> Void, stop_id: String) {
        
        let queryParameter = "predictionsbystop"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&stop=\(stop_id)&format=json"
        
        let queryURLEncoded = queryURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let endpoint = URL(string: queryURLEncoded)
        
        let session = URLSession.shared
        let task = session.dataTask(with: endpoint!, completionHandler: { (transitdata, response, error) -> Void in
            //
            if error != nil {
                print(error!.localizedDescription)
            } else {
                completionHandler(transitdata, error as NSError?)
            }
        }) 
        task.resume()
    }
}
