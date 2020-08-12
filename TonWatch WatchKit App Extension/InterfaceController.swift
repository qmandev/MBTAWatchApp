//
//  InterfaceController.swift
//  TonWatch WatchKit App Extension
//
//  Created by QIANG on 10/21/16.
//  Copyright © 2016 Armstrong Software LLC. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import MBTAWatchFrameworkWatchOS


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var mbtaStopsTable: WKInterfaceTable!
    
    var stopData : [MBTAStop] = [MBTAStop]()
    var tripPredictionsData: [MBTATrip] = [MBTATrip]()
    
    var locationMgr = CLLocationManager()
    let defaultLat = "42.346961"
    let defaultLon = "-71.076640"
    // set initial location in Back Bay Station
    var initialLocation = CLLocation(latitude: 42.346961, longitude: -71.076640)
    
    var deActiveTime: NSDate
    var activeTime: NSDate
    
    override init() {
        
        // let dataFetcher = TransitDataFetcher()
        
        // self.stopData = dataFetcher.FilterStopsbylocation(defaultLat, longitude: defaultLon)
        // self.tripPredictionsData = dataFetcher.PredictionsByLocation(self.stopData, latitude: defaultLat, longitude: defaultLon)
        
        self.deActiveTime = NSDate()
        self.activeTime = NSDate()
        
        super.init()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        // self.reloadTransitData()
        
        //self.reloadTransitDataNotBackground()
        
        self.locationMgr.delegate = self
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationMgr.requestAlwaysAuthorization()
        
        // This causes crash
        // NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "reloadTransitData", userInfo: nil, repeats: true)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        if (self.locationMgr.location != nil) {
            
            self.reloadTransitDataSingleton(currentLocation: self.locationMgr.location!)
            self.initialLocation = self.locationMgr.location!
        }
        else // This will point to Back bay Station
        {
            self.reloadTransitDataSingleton(currentLocation: self.initialLocation)
        }
        
        
        super.willActivate()
        self.activeTime = NSDate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.deActiveTime = NSDate()
    }
    
    /* Program Mark: Private methods */
    
    private func reloadTransitData() {
        
        let dataFetchQueue = DispatchQueue(label: "DataFetch")
        
        dataFetchQueue.async { 
            
            let dataFetcher = TransitDataFetcher()
            
            self.stopData = dataFetcher.FilterStopsbylocation(self.defaultLat, longitude: self.defaultLon)
            self.tripPredictionsData = dataFetcher.PredictionsByLocation(self.stopData, latitude: self.defaultLat, longitude: self.defaultLon)
            
            if (self.stopData.count > 0 && self.tripPredictionsData.count > 0)
            {

                DispatchQueue.main.async(execute: {

                    self.mbtaStopsTable.setNumberOfRows(self.tripPredictionsData.count, withRowType: "TransitRow")
                    
                    for (index, tripPrediction) in self.tripPredictionsData.enumerated() {
                        
                        let tripText: String
                        if (tripPrediction.trip_name == "" && tripPrediction.mode_name == "" )
                        {
                            tripText = "No Data " + "At Stop: " + tripPrediction.current_stop_id
                            
                        } else {
                            
                            tripText = tripPrediction.direction_name + " "
                                + tripPrediction.mode_name + " "
                                + tripPrediction.route_name + "    "
                                + String(format: "Wait: %@ At Stop: %@", tripPrediction.prediction.awaySeconds, tripPrediction.current_stop_id)
                        }
                        
                        let row = self.mbtaStopsTable.rowController(at: index) as! TransitTableRowController
                        row.predictLabel.setText(tripText)
                    }
                })
            }
        }
        
        // This is not existing anymore
        // self.mbtaStopsTable.loadTable()
    }
    
    private func reloadTransitDataNotBackground() {
        
        let dataFetcher = TransitDataFetcher()
        
        self.stopData = dataFetcher.FilterStopsbylocation(self.defaultLat, longitude: self.defaultLon)
        
        self.tripPredictionsData = dataFetcher.PredictionsByLocation(self.stopData, latitude: self.defaultLat, longitude: self.defaultLon)
        
        if (self.stopData.count > 0 && self.tripPredictionsData.count > 0)
        {
            self.mbtaStopsTable.setNumberOfRows(self.tripPredictionsData.count, withRowType: "TransitRow")
            
            for (index, tripPrediction) in self.tripPredictionsData.enumerated() {
                
                let tripText: String
                if (tripPrediction.trip_name == "" && tripPrediction.mode_name == "" )
                {
                    tripText = "No Data " + "At Stop: " + tripPrediction.current_stop_id
                    
                } else {
                    tripText = tripPrediction.direction_name + " "
                        + tripPrediction.mode_name + " "
                        + tripPrediction.route_name + "    "
                        + String(format: "Wait: %@ At Stop: %@", tripPrediction.prediction.awaySeconds, tripPrediction.current_stop_id)
                }
                
                let row = self.mbtaStopsTable.rowController(at: index) as! TransitTableRowController
                row.predictLabel.setText(tripText)
            }
        }
    }
    
    private func reloadTransitDataSingleton(currentLocation : CLLocation) {
        
        TWService.sharedInstance.fetchTransitDataWithCompletionBlockStopsbylocation ({ (data, error) -> Void in
            
            if data != nil {
                
                var stopList = [MBTAStop]()
                let dataFetcher = TransitDataFetcher()
                // swift 2.0 do - try - cathch block
                do {
                    let json: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    if let items = json["stop"] as? NSArray {
                        for item in items {
                            let stop = MBTAStop(jsonData: item as! NSDictionary)
                            stopList.append(stop)
                        }
                    }
                    
                } catch let jsonError as NSError {
                    print("json error \(jsonError.localizedDescription)")
                }
                
                self.stopData = dataFetcher.FilterStops(stopList)
                
                self.stopData.sort(by: { (S1: MBTAStop, S2: MBTAStop) -> Bool in
                    (S1.distance as NSString).doubleValue < (S2.distance as NSString).doubleValue
                })
                
                let shortestStopData = [MBTAStop](arrayLiteral: self.stopData.first!)
                
                var TripPredictionsByStop: [MBTATrip] = [MBTATrip]()
                
                // To Retrieve predictions by given stop, mode, route, direction
                for eachStop: MBTAStop in shortestStopData {
                    
                    TWService.sharedInstance.fetchTransitDataWithCompletionBlockPredictionsByLocation({ (data, error) -> Void in
                        
                        if data != nil {
                            
                            var trips = [MBTATrip]()
                            var modes = [MBTAMode]()
                            var routes = [MBTARoute]()
                            // let dataFetcher = TransitDataFetcher()
                            // swift 2.0 do - try - cathch block
                            do {
                                let json: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                                
                                if let items = json["mode"] as? NSArray {
                                    for item in items {
                                        let mode = MBTAMode(jsonData: item as! NSDictionary)
                                        modes.append(mode)
                                    }
                                }
                                
                            } catch let jsonError as NSError {
                                print("json error \(jsonError.localizedDescription)")
                            }
                            
                            for eachMode: MBTAMode in modes {
                                routes += eachMode.routes
                            }
                            
                            for eachRoute: MBTARoute in routes {
                                for eachDirection: MBTADirection in eachRoute.direction {
                                    
                                    // Filter out trips that has no vehicle
                                    if (eachDirection.trips.count != 0 && eachDirection.trips[0].oneVehicle.vehicle_id != "") {
                                        eachDirection.trips[0].current_stop_id = eachStop.stop_id
                                        trips.append(eachDirection.trips[0])
                                    }
                                }
                            }
                            
                            var tripByStop: [MBTATrip] = trips
                            
                            if (tripByStop.count == 0)
                            {
                                let noTrip: MBTATrip = MBTATrip(currentStop: eachStop)
                                tripByStop.append(noTrip)
                            }
                            
                            TripPredictionsByStop += tripByStop
                            
                            // Sort by Asending Order by the waiting time
                            TripPredictionsByStop.sort { (Trip1, Trip2) -> Bool in
                                Int(Trip1.prediction.pre_away)! < Int(Trip2.prediction.pre_away)!
                            }
                            
                            self.tripPredictionsData = TripPredictionsByStop
                            
                            if (self.stopData.count > 0 && self.tripPredictionsData.count > 0)
                            {
                                self.mbtaStopsTable.setNumberOfRows(self.tripPredictionsData.count, withRowType: "TransitRow")
                                
                                for (index, tripPrediction) in self.tripPredictionsData.enumerated() {
                                    
                                    let tripText: String
                                    if (tripPrediction.trip_name == "" && tripPrediction.mode_name == "" )
                                    {
                                        tripText = "No Data " + "At Stop: " + tripPrediction.current_stop_id
                                        
                                    } else {
                                        tripText = tripPrediction.direction_name + " "
                                            + tripPrediction.mode_name + " "
                                            + tripPrediction.route_name + "    "
                                            + String(format: "Wait: %@ At Stop: %@", tripPrediction.prediction.awaySeconds, tripPrediction.current_stop_id)
                                    }
                                    
                                    let row = self.mbtaStopsTable.rowController(at: index) as! TransitTableRowController
                                    row.predictLabel.setText(tripText)
                                }
                            }
                            
                        } // end of if
                        }, stop_id: eachStop.stop_id)
                }
                
            } // end of 1st if
            }, location: currentLocation)
    }
    

}
