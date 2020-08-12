//
//  TransitDataFetcher.swift
//  MBTAWatch
//
//  Created by QIANG on 5/13/15.
//  Copyright (c) 2015 Armstrong Software LLC. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


open class TransitDataFetcher : NSObject, URLSessionDataDelegate {
    
    // This is a Real key
    let MBTAAPIKey: String = "fiVEsxwcjEmub4YK_Rtifw"
    
    let TestUrl: String  = "http://realtime.mbta.com/developer/api/v2/stopsbylocation?api_key=fiVEsxwcjEmub4YK_Rtifw&lat=42.346961&lon=-71.076640&format=json"
    
    override public init() {
        
    }
    
    open class func requestTest() -> [MBTAStop]
    {
        // static variables for method only
        let MBTAAPIKey: String = "fiVEsxwcjEmub4YK_Rtifw"
        let stopbyLocationQuery: String = "http://realtime.mbta.com/developer/api/v2/stopsbylocation?api_key="
        let defaultLocation = "&lat=42.346961&lon=-71.076640&format=json"
        
        let url = stopbyLocationQuery + MBTAAPIKey + defaultLocation
        
        let endpoint = URL(string: url)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        var stops = [MBTAStop]()
        
        // TO: Add notification here indicate no network connection
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let items = json["stop"] as? NSArray {
                for item in items {
                    let stop = MBTAStop(jsonData: item as! NSDictionary)
                    stops.append(stop)
                }
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }
        
        stops.removeAll(keepingCapacity: false)
        return stops
    }
    
    /* Queries for MBTA Real-time API  */
    
    // 4.4.1 ROUTES
    open func Routes() -> [MBTARoute] {
        let queryParameter = "routes"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&format=json"
        
        let endpoint = URL(string: queryURL)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        var modes = [MBTAMode]()
        var routes = [MBTARoute]()
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
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
        
        return routes
    }
    
    // 4.1.2 ROUTESBYSTOP
    open func RoutesByStop(_ stop_id: String) -> [MBTARoute] {
        let queryParameter = "routesbystop"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&stop=\(stop_id)&format=json"

        let queryURLEncoded = queryURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let endpoint = URL(string: queryURLEncoded)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        var modes = [MBTAMode]()
        var routes = [MBTARoute]()
        
        // TO: Add notification here indicate no network connection
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
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
        
        return routes
    }
    
    // 4.2.1 STOPSBYROUTE
    open func StopsByRoute(_ route_id: String, route_name: String, direction_name : String, mode_name : String) -> [MBTAStop] {
        let queryParameter = "stopsbyroute"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&route=\(route_id)&format=json"
        
        let endpoint = URL(string: queryURL)
        
        let transitdata = try? Data(contentsOf: endpoint!)

        var directions = [MBTADirection]()
        var stops = [MBTAStop]()
        
        // TO: Add notification here indicate no network connection
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let items = json["direction"] as? NSArray {
                for item in items {
                    let direction = MBTADirection(jsonData: item as! NSDictionary, mode: mode_name, route_name: route_name)
                    directions.append(direction)
                }
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }

        let result = directions.filter { (d: MBTADirection) -> Bool in
            d.direction_name == direction_name
        }
        
        stops = result.first!.stops
        
        return stops
    }
    
    // 4.2.2 STOPSBYLOCATION
    open func Stopsbylocation(_ lat: String, lon: String) -> [MBTAStop] {

        let queryParameter = "stopsbylocation"
        let query = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key="
        let currentLocation = "&lat=\(lat)&lon=\(lon)&format=json"
    
        let url = query + self.MBTAAPIKey + currentLocation
    
        let endpoint = URL(string: url)
        
        var stops = [MBTAStop]()
        
        // swift 2.0 do - try - cathch block
        /*
        do {
            let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(stopData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            if let items = json["stop"] as? NSArray {
                for item in items {
                    let stop = MBTAStop(jsonData: item as! NSDictionary)
                    stops.append(stop)
                }
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }
        */
    
        /*
        let request = NSURLRequest(URL: endpoint!)
        let secondTask =  NSURLSession.sharedSession().dataTaskWithRequest(request)
        secondTask.resume()
        */
        
        /*
        
        NSOperationQueue().addOperationWithBlock { () -> Void in
            // code
            let semaphore : dispatch_semaphore_t = dispatch_semaphore_create(0)

            let request = NSURLRequest(URL: endpoint!)
            let secondTask =  NSURLSession.sharedSession().dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                // swift 2.0 do - try - cathch block
                do {
                    let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if let items = json["stop"] as? NSArray {
                        for item in items {
                            let stop = MBTAStop(jsonData: item as! NSDictionary)
                            self.stopsDATA.append(stop)
                        }
                    }
                    
                } catch let jsonError as NSError {
                    print("json error \(jsonError.localizedDescription)")
                }
                
                dispatch_semaphore_signal(semaphore)
            }
            
            secondTask.resume()
            
            //Have the thread wait until task is done
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            //Now carry on other stuff
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                stops = self.stopsDATA
            })
        }
        */
        var transitdata: Data?
        
        // Exception from Datawithcontentofurl
        // http://stackoverflow.com/questions/18020494/nsdata-datawithcontentsofurl-not-returning-data-for-url-that-shows-in-browser
        // var transitdata = try? Data(contentsOf: endpoint!)
        

        let request = URLRequest(url: endpoint!)
        // var response: URLResponse?
        
        transitdata = self.sendSynchronousRequest(request: request)

        /*
        let config = URLSessionConfiguration.default  // Session Configuration
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, data_response, error) in
            
            if error != nil {
                print("URLSession data Error: \(error?.localizedDescription)")
            } else {
            
                transitdata = data
                //response = data_response
                if transitdata != nil {
                    // swift 2.0 do - try - cathch block
                    do {
                        let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        if let items = json["stop"] as? NSArray {
                            for item in items {
                                let stop = MBTAStop(jsonData: item as! NSDictionary)
                                stops.append(stop)
                            }
                        }
                        
                    } catch let jsonError as NSError {
                        print("json error \(jsonError.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
        */
        
        /*
        do {
            
            let testData = try NSURLConnection.sendSynchronousRequest(request, returning: &response)
            transitdata = testData
        } catch let testError as NSError {
           
            print("test data Error: \(testError.localizedDescription)")
        }
         */
        
        /*
        do {
            
            let tdata = try Data(contentsOf: endpoint!, options: NSData.ReadingOptions())
        
            transitdata = tdata
            
        } catch let dataError as NSError {
            print("data Error: \(dataError.localizedDescription)")
        }
         */

        
        // TO: Add notification here indicate no network connection
        if transitdata != nil {
        // swift 2.0 do - try - cathch block
            do {
                let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
                if let items = json["stop"] as? NSArray {
                    for item in items {
                        let stop = MBTAStop(jsonData: item as! NSDictionary)
                        stops.append(stop)
                    }
                }
            
            } catch let jsonError as NSError {
                print("json error \(jsonError.localizedDescription)")
            }
        }
        
        
        /*
        
        TWService.sharedInstance.fetchTransitDataWithCompletionBlockStopsbylocation { (data, error) -> Void in

            if data != nil {
                

            // swift 2.0 do - try - cathch block
            do {
                let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                if let items = json["stop"] as? NSArray {
                    for item in items {
                        let stop = MBTAStop(jsonData: item as! NSDictionary)
                        stops.append(stop)
                    }
                }
                
            } catch let jsonError as NSError {
                print("json error \(jsonError.localizedDescription)")
            }
          }
        }
        */
        
        return stops
    }
    
    // 4.3.1 SCHEDULEBYSTOP
    // 4.3.2 SCHEDULEBYROUTE
    // 4.3.3 SCHEDULEBYTRIP
    
    // 4.4.1 PREDICTIONSBYSTOP
    open func PredictionsByStop(_ stop_id: String) -> [MBTATrip] {
        
        let queryParameter = "predictionsbystop"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&stop=\(stop_id)&format=json"
        let queryURLEncoded = queryURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let endpoint = URL(string: queryURLEncoded)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        // var predictions = [MBTAPrediction]()
        var trips = [MBTATrip]()
        var modes = [MBTAMode]()
        var routes = [MBTARoute]()
        
        // TO: Add notification here indicate no network connection
        if transitdata != nil {
            // swift 2.0 do - try - cathch block
            do {
                let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                if let items = json["mode"] as? NSArray {
                    for item in items {
                        let mode = MBTAMode(jsonData: item as! NSDictionary)
                        modes.append(mode)
                    }
                }
                
            } catch let jsonError as NSError {
                print("json error \(jsonError.localizedDescription)")
            }
        }
        
        for eachMode: MBTAMode in modes {
            routes += eachMode.routes
        }
        
        for eachRoute: MBTARoute in routes {
            for eachDirection: MBTADirection in eachRoute.direction {
                
                // Filter out trips that has no vehicle
                if (eachDirection.trips.count != 0 && eachDirection.trips[0].oneVehicle.vehicle_id != "") {
                    eachDirection.trips[0].current_stop_id = stop_id
                    trips.append(eachDirection.trips[0])
                }
            }
        }
        
        //Convert trips to predictions
        // predictions = TripToPrediction(trips)
        
        return trips
    }
    
    // 4.4.2 PREDICTIONSBYROUTE
    open func PredictionsByRoute(_ route_id: String, route_name: String, direction_name : String, mode_name : String) -> [MBTAPrediction] {
        
        let queryParameter = "predictionsbyroute"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&route=\(route_id)&format=json"
        
        let endpoint = URL(string: queryURL)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        var predictions = [MBTAPrediction]()
        var trips = [MBTATrip]()
        var directions = [MBTADirection]()
        
        // TO: Add notification here indicate no network connection

        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let items = json["direction"] as? NSArray {
                for item in items {
                    let direction = MBTADirection(jsonData: item as! NSDictionary, mode : mode_name, route_name: route_name)
                    directions.append(direction)
                }
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }
        
        let result = directions.filter { (d: MBTADirection) -> Bool in
            d.direction_name == direction_name
        }
        
        trips = result.first!.trips
        
        //Convert trips to predictions
        predictions = StopToPrediction(trips.first!.stops)
        
        return predictions
    }
    
    // 4.4.3 VEHICLESBYROUTE
    open func VehiclesByRoute(_ route_id: String, route_name: String, direction_name : String, mode_name : String) -> [MBTAVehicle] {
        
        let queryParameter = "vehiclesbyroute"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&route=\(route_id)&format=json"
        
        let endpoint = URL(string: queryURL)
        
        let transitdata = try? Data(contentsOf: endpoint!)

        var vehicles = [MBTAVehicle]()
        var trips = [MBTATrip]()
        var directions = [MBTADirection]()
        
        // TO: Add notification here indicate no network connection
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let items = json["direction"] as? NSArray {
                for item in items {
                    let direction = MBTADirection(jsonData: item as! NSDictionary, mode : mode_name, route_name: route_name)
                    directions.append(direction)
                }
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }
        
        let result = directions.filter { (d: MBTADirection) -> Bool in
            d.direction_name == direction_name
        }
        
        trips = result.first!.trips

        //Convert trips to vheicles
        vehicles.append(trips.first!.oneVehicle)
        
        return vehicles
    }
    
    // 4.4.4 PREDICTIONSBYTRIP
    open func PredictionsByTrip(_ trip_id: String) -> [MBTAPrediction] {
        
        let queryParameter = "predictionsbytrip"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&trip=\(trip_id)&format=json"
        
        let endpoint = URL(string: queryURL)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        var predictions = [MBTAPrediction]()
        var stops = [MBTAStop]()
        
        // TO: Add notification here indicate no network connection
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let items = json["stop"] as? NSArray {
                for item in items {
                    let oneStop = MBTAStop(jsonData: item as! NSDictionary)
                    stops.append(oneStop)
                }
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }
        
        //Convert trips to predictions
        predictions = StopToPrediction(stops)
        
        return predictions
    }
    
    // 4.4.5 VEHICLESBYTRIP
    open func VehiclesByTrip(_ trip_id: String) -> [MBTAVehicle] {
        
        let queryParameter = "vehiclesbytrip"
        let queryURL = "http://realtime.mbta.com/developer/api/v2/\(queryParameter)?api_key=\(self.MBTAAPIKey)&trip=\(trip_id)&format=json"
        
        let endpoint = URL(string: queryURL)
        
        let transitdata = try? Data(contentsOf: endpoint!)
        
        var vehicles = [MBTAVehicle]()
        
        // TO: Add notification here indicate no network connection
        
        // swift 2.0 do - try - cathch block
        do {
            let json: NSDictionary = try JSONSerialization.jsonObject(with: transitdata!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            if let item = json["vehicle"] as? NSDictionary {
                let oneVehicle = MBTAVehicle(jsonData: item)
                vehicles.append(oneVehicle)
            }
            
        } catch let jsonError as NSError {
            print("json error \(jsonError.localizedDescription)")
        }
        
        return vehicles
    }
    
    // 4.5.1 ALERTS
    // 4.5.2 ALERTSBYROUTE
    // 4.5.3 ALERTSBYSTOP
    // 4.5.4 ALERTBYID
    // 4.5.5 ALERTSHEADERS
    // 4.5.6 ALERTHEADERSBYROUTE
    // 4.5.7 ALERTHEADERSBYSTOP
    // 4.6.1 SERVERTIME
    
    // Private method, by default
    fileprivate func requestAlert() -> Bool
    {
        return false
    }
    
    // Public method, class method
    internal class func requestStop() -> Bool
    {
        return false
    }
    
    /* Utlity methods  */
    func TripToPrediction(_ trips :[MBTATrip]) -> [MBTAPrediction]{
        var predictions = [MBTAPrediction]()
        
        for item in trips {
            let onePrediction = MBTAPrediction(pre_dt: item.prediction.pre_dt, pre_away: item.prediction.pre_away)
            predictions.append(onePrediction)
        }
        
        return predictions
    }
    
    func TripToSchedule(_ trips :[MBTATrip]) -> [MBTASchedule]{
        var schedules = [MBTASchedule]()
        
        for item in trips {
            let oneSchedule = MBTASchedule(sch_arr_dt: item.schedule.sch_arr_dt, sch_dep_dt: item.schedule.sch_dep_dt)
            schedules.append(oneSchedule)
        }
        
        return schedules
    }
    
    func StopToPrediction(_ stops : [MBTAStop]) -> [MBTAPrediction]{
        var predictions = [MBTAPrediction]()
        
        for item in stops {
            let onePrediction = item.prediction
            predictions.append(onePrediction)
        }
        
        return predictions
    }
    
    /* Public methods for data retrival */
    open func FilterStopsbylocation(_ latitude: String, longitude: String) -> [MBTAStop] {
        
        let stopDataByLocation: [MBTAStop] = self.Stopsbylocation(latitude, lon: longitude)
        var stopList: [MBTAStop] = [MBTAStop]()
        
        if (stopDataByLocation.count > 1) {
            let firstStopDistance: String = (stopDataByLocation.first?.distance)!
            let doubleDistance = (firstStopDistance as NSString).doubleValue
            
            stopList = stopDataByLocation.filter({ (eachStop : MBTAStop) -> Bool in

                return (eachStop.distance as NSString).doubleValue < (doubleDistance + 0.2)
            })
            
            return stopList
        }
        return stopDataByLocation
    }
    
    /* Helper method to filter a given stop list */
    open func FilterStops(_ stopList: [MBTAStop]) -> [MBTAStop] {
        
        let stopDataByLocation: [MBTAStop] = stopList
        var stopList: [MBTAStop] = [MBTAStop]()
        
        if (stopDataByLocation.count > 1) {
            let firstStopDistance: String = (stopDataByLocation.first?.distance)!
            let doubleDistance = (firstStopDistance as NSString).doubleValue
            
            stopList = stopDataByLocation.filter({ (eachStop : MBTAStop) -> Bool in
                
                return (eachStop.distance as NSString).doubleValue < (doubleDistance + 0.2)
            })
            
            return stopList
        }
        return stopDataByLocation
    }
    
    /* Public methods for data retrival */
    open func PredictionsByLocation (_ stopList: [MBTAStop], latitude: String, longitude: String) -> [MBTATrip] {
    
        var TripPredictionsByStop: [MBTATrip] = [MBTATrip]()
        
        // To Retrieve predictions by given stop, mode, route, direction
        for eachStop: MBTAStop in stopList {
            
            var tripByStop: [MBTATrip] = self.PredictionsByStop(eachStop.stop_id)
            
            if (tripByStop.count == 0)
            {
                let noTrip: MBTATrip = MBTATrip(currentStop: eachStop)
                tripByStop.append(noTrip)
            }
            
            TripPredictionsByStop += tripByStop
        }
        
        // Sort by Asending Order by the waiting time
        TripPredictionsByStop.sort { (Trip1, Trip2) -> Bool in
            Int(Trip1.prediction.pre_away) < Int(Trip2.prediction.pre_away)
        }
        
        return TripPredictionsByStop
    }
    
    // To use URLSession and simulate deprecated NSURLConnection.sendSynchronousRequest method
    //http://stackoverflow.com/questions/32643207/ios9-sendsynchronousrequest-deprecated
    private func sendSynchronousRequest(request: URLRequest) -> (Data?) {
        
        var error: Error?
        var processed = false
        var data: Data?
        URLSession.shared.dataTask(with: request) { (_data, _response, _error) in
            
            data = _data!
            processed = true
            error = _error
        }.resume()
        
        while (!processed) {
            Thread.sleep(forTimeInterval: 0)
        }
        
        if (error != nil) {
            print(error?.localizedDescription as Any)
        }
        return data
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //
        print(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //
        print(error!)
    }
}
