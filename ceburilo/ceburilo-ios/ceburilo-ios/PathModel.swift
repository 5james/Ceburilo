//
//  PathModel.swift
//  ceburilo-ios
//
//  Created by James on 06/06/2017.
//  Copyright © 2017 James. All rights reserved.
//

import Foundation
import Alamofire
import GLMap
import GLMapSwift


protocol pathDelegate {
    func receiveLineAsMapVectorObject(line: GLMapVectorObject)
}

class Path {
    
    var mapVectorObjectToReturn: GLMapVectorObject?
    var stations: Array<GLMapGeoPoint> = []
    
    var status: DataLoaded = .Waiting
    private var todoEndpoint: String = "http://localhost:8080/searchpath"
    
    public var registered = true
    
    private var startGeoPoint: GLMapGeoPoint?
    private var endGeoPoint: GLMapGeoPoint?
    
    var alamoFireManager: Alamofire.SessionManager?
    
    init(x1: Double, y1: Double, x2: Double, y2: Double) {
        todoEndpoint.append("?x1=\(x1)&y1=\(y1)&x2=\(x2)&y2=\(y2)")
        mapVectorObjectToReturn = GLMapVectorObject()
        startGeoPoint = GLMapGeoPoint.init(lat: y1, lon: x1)
        endGeoPoint = GLMapGeoPoint.init(lat: y2, lon: x2)
    }
    
//    static var counter = 0
    
    func sendDataThourghNotificationCenter() {
        var line = Array<GLMapGeoPoint>()
        if self.startGeoPoint != nil {
            line.append(self.startGeoPoint!)
        }
        
        // Config for no timeouts
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 600 // seconds
        configuration.timeoutIntervalForResource = 600
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)

        
        alamoFireManager?.request(todoEndpoint)
            .responseJSON { response in
                // check for errors
                guard response.result.error == nil else {
                    self.status = .Failed
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /searchpath&...")
                    print(response.result.error!)
                    return
                }
                
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }
                var previous_seq: Double? = nil
                var previous_x = 0.0
                var previous_y = 0.0
                if let arrayOfDic = json["points"] as? [Dictionary<String,AnyObject>] {
                    for aDic in arrayOfDic{
                        if let xx = aDic["x"] as? Double{
                            if let yy = aDic["y"] as? Double{
                                line.append(GLMapGeoPoint.init(lat: yy, lon: xx))
                                
                                if let seq = aDic["seq"] as? Double {
                                    if previous_seq != nil  {
                                        if previous_seq != seq {
                                            self.stations.append(GLMapGeoPoint.init(lat: previous_y, lon: previous_x))
                                        }
                                    }
                                    previous_seq = seq
                                    previous_y = yy
                                    previous_x = xx
                                }
                            }
                        }
                    }
                    if self.endGeoPoint != nil {
                        line.append(self.endGeoPoint!)
                    }
                    self.mapVectorObjectToReturn?.addGeoLine(line)
                }
                self.status = .Success
                if self.registered == true {
                    NotificationCenter.default.post(name: notificationName, object: nil)
                }
        }
        
//        let line1 = [GLMapGeoPoint.init(lat: 53.8869, lon: 27.7151), // Minsk
//            GLMapGeoPoint.init(lat: 50.4339, lon: 30.5186), // Kiev
//            GLMapGeoPoint.init(lat: 52.2251, lon: 21.0103), // Warsaw
//            GLMapGeoPoint.init(lat: 52.5037, lon: 13.4102), // Berlin
//            GLMapGeoPoint.init(lat: 48.8505, lon: 2.3343)]  // Paris
//        
//        
//        let line2 = [GLMapGeoPoint.init(lat: 52.3690, lon: 4.9021), // Amsterdam
//            GLMapGeoPoint.init(lat: 50.8263, lon: 4.3458), // Brussel
//            GLMapGeoPoint.init(lat: 49.6072, lon: 6.1296)] // Luxembourg
//        if Path.counter == 0 {
//            mapVectorObjectToReturn?.addGeoLine(line1)
//        }
//        else {
//            mapVectorObjectToReturn?.addGeoLine(line2)
//        }
//        NotificationCenter.default.post(name: notificationName, object: nil)
//        Path.counter += 1
    }
    

}

