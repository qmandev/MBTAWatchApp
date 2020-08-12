//
//  ViewController.swift
//  TonWatch
//
//  Created by QIANG on 8/12/16.
//  Copyright © 2016 Armstrong Software LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import WatchConnectivity

import MBTAWatchFramework

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    // http://stackoverflow.com/questions/26134641/how-to-get-current-location-lat-long-in-ios-8
    
    /// Default WatchConnectivity session for communicating with the watch.
    let session = WCSession.default()
    
    var allRouteData : [MBTARoute] = [MBTARoute]()
    var routeDataByStop : [MBTARoute] = [MBTARoute]()
    //* var predictionsByStop : [MBTAPrediction] = [MBTAPrediction]()
    var TripPredictionsByStop : [MBTATrip] = [MBTATrip]()
    var predictionsByRoute : [MBTAPrediction] = [MBTAPrediction]()
    var vehiclesByRoute : [MBTAVehicle] = [MBTAVehicle]()
    
    var stopDataByRoute : [MBTAStop] = [MBTAStop]()
    var stopDataByLocation : [MBTAStop] = [MBTAStop]()
    
    var predictionsByTrip : [MBTAPrediction] = [MBTAPrediction]()
    var vehiclesByByTrip : [MBTAVehicle] = [MBTAVehicle]()
    
    
    var locationMgr = CLLocationManager()
    let defaultLat = "42.346961"
    let defaultLon = "-71.076640"
    
    // set initial location in Back Bay Station
    var initialLocation = CLLocation(latitude: 42.346961, longitude: -71.076640)
    let regionRadius: CLLocationDistance = 1500
    
    deinit {
        // perform the deinitialization
        #if DEBUG
        let unusedobjects = NSMutableArray()
            if unusedobjects.count == 0 {
                unusedobjects.add(self.mapView)
            }
        #endif
    }

    /* Center and zoom the map */
    func centerMapLocation(_ location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, self.regionRadius*2, self.regionRadius*2)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // print("Test")
        
        self.locationMgr.delegate = self
        self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationMgr.requestAlwaysAuthorization()
        
        // self.locationMgr.requestWhenInUseAuthorization()
        self.locationMgr.startUpdatingLocation()
        
        if (self.locationMgr.location != nil) {
            centerMapLocation(self.locationMgr.location!)
            self.reloadTransitData(self.locationMgr.location!)
            self.initialLocation = self.locationMgr.location!
        }
        else // This will point to Back bay Station
        {
            centerMapLocation(self.initialLocation)
            self.reloadTransitData(self.initialLocation)
        }
        
        // self.mapView.addAnnotation(stopDataByRoute.first!)
        self.mapView.addAnnotations(stopDataByLocation)
        
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.reloadTransitDataWithTimer), userInfo: self.initialLocation, repeats: true)
    }

    func reloadTransitData(_ currentLocation : CLLocation) {
        
        let dataFetcher = TransitDataFetcher()
        
        let latitude = String(currentLocation.coordinate.latitude)
        let longitude =  String(currentLocation.coordinate.longitude)
        
        stopDataByLocation = dataFetcher.FilterStopsbylocation(latitude, longitude: longitude)
        TripPredictionsByStop = dataFetcher.PredictionsByLocation(self.stopDataByLocation, latitude: latitude, longitude: longitude)
        
        self.tableView.reloadData()
        
        if (TripPredictionsByStop.count < 1) {
            alert()
        }
    }
    
    func reloadTransitDataWithTimer(_ timer : Timer) {
        
        let dataFetcher = TransitDataFetcher()
        
        let currentLocation = timer.userInfo! as! CLLocation
        
        let latitude = String(currentLocation.coordinate.latitude)
        let longitude =  String(currentLocation.coordinate.longitude)
        
        stopDataByLocation = dataFetcher.FilterStopsbylocation(latitude, longitude: longitude)
        TripPredictionsByStop = dataFetcher.PredictionsByLocation(self.stopDataByLocation, latitude: latitude, longitude: longitude)
        
        self.tableView.reloadData()
        
        if (TripPredictionsByStop.count < 1) {
            alert()
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        // Remove from Info.plist for CGContext error
        // https://forums.developer.apple.com/thread/18521
        
        return UIStatusBarStyle.lightContent
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        
        // This will point to user's current location
        centerMapLocation(currentLocation!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //* return stopDataByLocation.count
        return TripPredictionsByStop.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "CellDetail", for: indexPath)
        
        //* cell.textLabel?.text = stopDataByLocation[indexPath.row].stop_name
        
        let currentTripPrediction: MBTATrip = TripPredictionsByStop[(indexPath as NSIndexPath).row]
        let tripText: String
        let tripDetailText: String
        
        if (currentTripPrediction.trip_name == "" && currentTripPrediction.mode_name == "" )
        {
            tripText = "No Transit Information Avaliable"
            tripDetailText = "At Stop: " + currentTripPrediction.current_stop_id
            
        } else {
            
            tripText = currentTripPrediction.direction_name + " "
                + currentTripPrediction.mode_name + " "
                + currentTripPrediction.route_name + "    "
                + currentTripPrediction.trip_name
            
            tripDetailText = String(format: "Arrive: %@ Wait: %@ At Stop: %@" ,  currentTripPrediction.prediction.arriveTime, currentTripPrediction.prediction.awaySeconds, currentTripPrediction.current_stop_id)
        }
        
        cell.textLabel?.text = tripText
        cell.detailTextLabel?.text = tripDetailText
        
        return cell
    }

    func alert() {
        let alertController = UIAlertController(title: "Important Message", message: "No MTBA Transit Information Avaliable", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertNoNetwork() {
        let alertController = UIAlertController(title: "Important Message", message: "No Network Connection", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

