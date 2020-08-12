//
//  SimpleGetHttpRequest.swift
//  TonWatch
//
//  Created by QIANG on 9/26/16.
//  Copyright © 2016 Armstrong Software LLC. All rights reserved.
//

import Foundation

typealias completionHander_t = (_ success: Bool) -> Void

open class SimpleGetHttpRequest : NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    
    var isCancelled : Bool
    var isExecuting : Bool
    var isFinished  : Bool
    var url: URL
    var request : URLRequest
    var connection = NSURLConnection()
    var responseData = NSMutableData()
    var lastResponse = HTTPURLResponse()
    var error = NSError()
    
    /*
    override init() {
        
        self.isCancelled = false
        self.isExecuting = false
        self.isFinished =  false
        
        super.init()

    }
    */
    
    init(url : URL) {
        
        // NSString *encoded = [notEncoded stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        self.isCancelled = false
        self.isExecuting = false
        self.isFinished =  false
        self.request = URLRequest(url: url)
        self.url = url
        
        super.init()

    }
    
    func terminate() {
        assert(Thread.current.isMainThread, "Not executing on main thread")
        
        if self.isFinished {
            return
        }
        
        
        
    }
    
    func start() {
        
        // ensure the start method is executed on the main thread:
        
        // bail out if the receiver has already been started or cancelled:
        if (self.isCancelled || self.isExecuting || self.isFinished) {
            return
        }
        
        self.isExecuting = true
        self.request = URLRequest(url: self.url)
        self.connection = NSURLConnection()

        
    }
}
