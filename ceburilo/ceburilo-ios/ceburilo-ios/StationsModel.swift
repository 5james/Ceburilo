//
//  MainModel.swift
//  ceburilo-ios
//
//  Created by James on 05/06/2017.
//  Copyright © 2017 James. All rights reserved.
//

import Foundation
import Alamofire
import GLMap
import GLMapSwift



enum DataLoaded {
    case Success
    case Failed
    case Waiting
}

protocol stationsDelegate {
    func receiveStationsAsGeoJsonString(geojson: String);
}

class StationsRepository {
    
    private var receiverDelegate: stationsDelegate?
    
    private var points: Array<Dictionary<String, Double>>
    
    var status: DataLoaded = .Waiting
    let todoEndpoint: String = "http://localhost:8080/stations"
    
    init() {
        points = Array<Dictionary<String, Double>>()
        Alamofire.request(todoEndpoint)
            .responseJSON { response in
                // check for errors
                guard response.result.error == nil else {
                    self.status = .Failed
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /stations")
                    print(response.result.error!)
                    return
                }
                
                guard let json = response.result.value as? [String: [String: Any]] else {
                    print("didn't get todo object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }
                if let arrayOfDic = json["_embedded"]?["stations"]! as? [Dictionary<String,AnyObject>] {
                    for aDic in arrayOfDic{
                        if let xx = aDic["x"] as? Double{
                            if let yy = aDic["y"] as? Double{
                                var dict =  Dictionary<String, Double>()
                                dict["x"] = Double(xx)
                                dict["y"] = Double(yy)
                                self.points.append(dict)
                            }
                        }
                    }
                }
                self.status = .Success
                self.sendStationsToReceiver()
        }
        
    }
    
    
    func getWeirdData() -> String {
        var weirdData: String = "["
        for point in points {
            weirdData.append("{ \"type\": \"Feature\", \"geometry\": { \"type\": \"Point\", \"coordinates\": [ \(String(describing: point["x"]!)), \(String(describing: point["y"]!)) ] } }, ")
        }
        weirdData = weirdData.dropLast(2)
        weirdData.append("]")
        print(weirdData)
        return weirdData
    }
    
    func registerReceiverWithGeoJsonString(receiver: stationsDelegate) {
        receiverDelegate = receiver
        if status == .Success {
            sendStationsToReceiver()
        }
    }
    
    func sendStationsToReceiver() {
        if receiverDelegate != nil {
            receiverDelegate?.receiveStationsAsGeoJsonString(geojson: getWeirdData())
            receiverDelegate = nil
        }
    }
}

