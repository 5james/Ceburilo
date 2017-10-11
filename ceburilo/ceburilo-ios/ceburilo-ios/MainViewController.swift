//
//  ViewController.swift
//  ceburilo-ios
//
//  Created by James on 04/06/2017.
//  Copyright © 2017 James. All rights reserved.
//

import UIKit
import GLMap
import GLMapSwift
import Alamofire

class MainViewController: UIViewController, stationsDelegate, GeocodeAddPinDelegate {
    
    //Buttons
    private lazy var btnSetStartPoint: UIButton = {
        let btnSetStartPoint = UIButton()
        btnSetStartPoint.translatesAutoresizingMaskIntoConstraints = false
        btnSetStartPoint.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        btnSetStartPoint.layer.cornerRadius = 5
        btnSetStartPoint.layer.borderWidth = 0.4
        btnSetStartPoint.layer.borderColor = UIColor.black.cgColor
        btnSetStartPoint.setTitle("Set start point", for: UIControlState.normal)
        btnSetStartPoint.setTitleColor(.black, for: .normal)
        btnSetStartPoint.setTitleColor(UIColor.white, for: .highlighted)
        btnSetStartPoint.addTarget(self, action: #selector(MainViewController.setStartPoint), for: .touchUpInside)
        return btnSetStartPoint
    }()
    
    private lazy var btnSetStopPoint: UIButton = {
        let btnSetStopPoint = UIButton()
        btnSetStopPoint.translatesAutoresizingMaskIntoConstraints = false
        btnSetStopPoint.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        btnSetStopPoint.layer.cornerRadius = 5
        btnSetStopPoint.layer.borderWidth = 0.4
        btnSetStopPoint.layer.borderColor = UIColor.black.cgColor
        btnSetStopPoint.setTitle("Set stop point", for: UIControlState.normal)
        btnSetStopPoint.setTitleColor(.black, for: .normal)
        btnSetStopPoint.setTitleColor(UIColor.white, for: .highlighted)
        btnSetStopPoint.addTarget(self, action: #selector(MainViewController.setEndPoint), for: .touchUpInside)
        return btnSetStopPoint
    }()
    
    private lazy var btnSearchPath: UIButton = {
        let btnSearchPath = UIButton()
        btnSearchPath.translatesAutoresizingMaskIntoConstraints = false
        btnSearchPath.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.9, blue: 0.1, alpha: 1.0)
        btnSearchPath.layer.cornerRadius = 16
        btnSearchPath.layer.borderWidth = 0.4
        btnSearchPath.layer.borderColor = UIColor.black.cgColor
        btnSearchPath.setTitle("Search", for: UIControlState.normal)
        btnSearchPath.setTitleColor(.black, for: .normal)
        btnSearchPath.setTitleColor(UIColor.white, for: .highlighted)
        btnSearchPath.addTarget(self, action: #selector(MainViewController.searchBikePath), for: .touchUpInside)
        btnSearchPath.layoutMargins.left = -10
        return btnSearchPath
    }()
    
    // Map
    let map = GLMapView()
    
    // Location Manager
    var locationManager = CLLocationManager()
    
    // Stations
    var stations: StationsRepository?
    
    // Data for Map Gestures
    var menuPos: CGPoint?
    var startPinMapImage: GLMapImage?
    var endPinMapImage: GLMapImage?
    
    // Data for path
    var pathRepo: Path?
    var displayedPath: GLMapVectorObject?
    var displayedIntermediateStations: Array<GLMapImage> = []
    
    override func loadView() {
        super.loadView()
        
        // Create topControlPanel - top of HomeViewController, where buttons to control path will be
        let topControlPanel: UIView = UIView()
        topControlPanel.backgroundColor = UIColor(colorLiteralRed: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)
        topControlPanel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(topControlPanel)
        
        // Constraints for topControlPanel
        var contraintsTopControlPanel = [NSLayoutConstraint]()
        let ctcp1 = topControlPanel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let ctcp2 = topControlPanel.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor)
        let ctcp3 = topControlPanel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        let ctcp4 = topControlPanel.heightAnchor.constraint(equalToConstant: 48)
        
        contraintsTopControlPanel.append(ctcp1)
        contraintsTopControlPanel.append(ctcp2)
        contraintsTopControlPanel.append(ctcp3)
        contraintsTopControlPanel.append(ctcp4)
        NSLayoutConstraint.activate(contraintsTopControlPanel)
        
        // Adding topCOntrolPanel to main view
        view.addSubview(topControlPanel)
        
        topControlPanel.addSubview(btnSetStartPoint)
        topControlPanel.addSubview(btnSetStopPoint)
        topControlPanel.addSubview(btnSearchPath)
        
        // Constraints for buttons inside topControlPanel ctitcp
        var contraintsInsideTopControlPanel = [NSLayoutConstraint]()
        let ctitcp1 = btnSetStartPoint.topAnchor.constraint(equalTo: topControlPanel.topAnchor)
        let ctitcp2 = btnSetStartPoint.leadingAnchor.constraint(equalTo: topControlPanel.leadingAnchor)
        let ctitcp3 = btnSetStartPoint.bottomAnchor.constraint(equalTo: btnSetStopPoint.topAnchor)
        let ctitcp4 = btnSetStartPoint.trailingAnchor.constraint(equalTo: btnSearchPath.layoutMarginsGuide.leadingAnchor)
        let ctitcp5 = btnSetStopPoint.topAnchor.constraint(equalTo: btnSetStartPoint.bottomAnchor)
        let ctitcp6 = btnSetStopPoint.leadingAnchor.constraint(equalTo: topControlPanel.leadingAnchor)
        let ctitcp7 = btnSetStopPoint.trailingAnchor.constraint(equalTo: btnSearchPath.layoutMarginsGuide.leadingAnchor)
        let ctitcp8 = btnSetStopPoint.bottomAnchor.constraint(equalTo: topControlPanel.bottomAnchor)
        let ctitcp9 = btnSearchPath.topAnchor.constraint(equalTo: topControlPanel.topAnchor)
        let ctitcp10 = btnSearchPath.trailingAnchor.constraint(equalTo: topControlPanel.trailingAnchor)
        let ctitcp11 = btnSearchPath.bottomAnchor.constraint(equalTo: topControlPanel.bottomAnchor)
        let ctitcp12 = btnSearchPath.widthAnchor.constraint(equalToConstant: 96)
        let ctitcp14 = btnSetStopPoint.heightAnchor.constraint(equalTo: btnSetStartPoint.heightAnchor)
        
        contraintsInsideTopControlPanel.append(ctitcp1)
        contraintsInsideTopControlPanel.append(ctitcp2)
        contraintsInsideTopControlPanel.append(ctitcp3)
        contraintsInsideTopControlPanel.append(ctitcp4)
        contraintsInsideTopControlPanel.append(ctitcp5)
        contraintsInsideTopControlPanel.append(ctitcp6)
        contraintsInsideTopControlPanel.append(ctitcp7)
        contraintsInsideTopControlPanel.append(ctitcp8)
        contraintsInsideTopControlPanel.append(ctitcp9)
        contraintsInsideTopControlPanel.append(ctitcp10)
        contraintsInsideTopControlPanel.append(ctitcp11)
        contraintsInsideTopControlPanel.append(ctitcp12)
        contraintsInsideTopControlPanel.append(ctitcp14)
        NSLayoutConstraint.activate(contraintsInsideTopControlPanel)
        
        // End of Top Control Panel
        
        // Adding map
        self.view.addSubview(map)
        map.translatesAutoresizingMaskIntoConstraints = false
        var contraintsMap = [NSLayoutConstraint]()
        let cm1 = map.topAnchor.constraint(equalTo: topControlPanel.bottomAnchor)
        let cm2 = map.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
        let cm3 = map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let cm4 = map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        
        contraintsMap.append(cm1)
        contraintsMap.append(cm2)
        contraintsMap.append(cm3)
        contraintsMap.append(cm4)
        NSLayoutConstraint.activate(contraintsMap)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // Set title of this ViewController
        self.title = "Map"
        
        // Enable CLLocationManager and ask for permissions
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.delegate = map
        
        map.showUserLocation = true
        
        // Allow downloading tiles for map
        GLMapManager.shared().tileDownloadingAllowed = true
        
        // Add NotificationCenter for incoming paths
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: OperationQueue.main) { [weak self]_ in
            self?.displayPath()
        }
        
        // Load Stations
        stations = StationsRepository()
        
        // Add stations (clustered) to map
        //addStations()
        stations?.registerReceiverWithGeoJsonString(receiver: self)
        
        // Prepare map to longpress gesture - pick start- and end-point of trip
        prepareMapGestures()
    }
    
    
    func prepareMapGestures() {
        map.longPressGestureBlock = { [weak self] (point: CGPoint) in
            let menu = UIMenuController.shared
            if !menu.isMenuVisible {
                self?.menuPos = point
                self?.becomeFirstResponder()
                
                if let map = self?.map {
                    menu.setTargetRect(CGRect.init(origin: point, size: CGSize.init(width: 1, height: 1)), in: map)
                    menu.menuItems = [UIMenuItem.init(title: "Add Start Point", action: #selector(MainViewController.addStartPin)), UIMenuItem.init(title: "Add End Point", action: #selector(MainViewController.addEndPin))]
                    menu.setMenuVisible(true, animated: true)
                }
            }
        }
        
        map.tapGestureBlock = { [weak self] (point: CGPoint) in
            var rect = CGRect.init(x: -20, y: -20, width: 40, height: 80)
            rect = rect.offsetBy(dx:point.x, dy: point.y)
            
            if let pin1 = self?.startPinMapImage, let pin2 = self?.endPinMapImage, let map = self?.map {
                let pinPos1 = map.makeDisplayPoint(from: pin1.position)
                let pinPos2 = map.makeDisplayPoint(from: pin2.position)
                
                if rect.contains(pinPos1) {
                    let menu = UIMenuController.shared
                    if !menu.isMenuVisible {
                        
                        self?.becomeFirstResponder()
                        menu.setTargetRect(CGRect.init(origin: CGPoint.init(x: pinPos1.x, y: pinPos1.y-20.0), size: CGSize.init(width: 1, height: 1)), in: map)
                        menu.menuItems = [UIMenuItem.init(title: "Delete Start pin", action: #selector(MainViewController.deleteStartPin))]
                        menu.setMenuVisible(true, animated: true)
                    }
                }
                else if rect.contains(pinPos2) {
                    let menu = UIMenuController.shared
                    if !menu.isMenuVisible {
                        
                        self?.becomeFirstResponder()
                        menu.setTargetRect(CGRect.init(origin: CGPoint.init(x: pinPos2.x, y: pinPos2.y-20.0), size: CGSize.init(width: 1, height: 1)), in: map)
                        menu.menuItems = [UIMenuItem.init(title: "Delete End pin", action: #selector(MainViewController.deleteEndPin))]
                        menu.setMenuVisible(true, animated: true)
                    }
                }
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    
    func addStationPin() {
        
        if let image = UIImage.init(named: "pin-start") {
            if let startPinToDestroy = startPinMapImage {
                map.remove(startPinToDestroy)
            }
            //startPinMapImage = map.display(image)
            startPinMapImage = map.display(image, drawOrder: INT32_MAX)
            startPinMapImage?.position = GLMapPoint()
            startPinMapImage?.offset = CGPoint.init(x: image.size.width/2, y: 0)
        }
    }
    
    func addStartPin() {
        
        let pinPos = map.makeMapPoint(fromDisplay: menuPos!)
        
        if let image = UIImage.init(named: "pin-start") {
            if let startPinToDestroy = startPinMapImage {
                map.remove(startPinToDestroy)
            }
            //startPinMapImage = map.display(image)
            startPinMapImage = map.display(image, drawOrder: INT32_MAX)
            startPinMapImage?.position = pinPos
            startPinMapImage?.offset = CGPoint.init(x: image.size.width/2, y: 0)
        }
    }
    
    func addEndPin() {
        
        let pinPos = map.makeMapPoint(fromDisplay: menuPos!)
        
        if let image = UIImage.init(named: "pin-end") {
            if let endPinToDestroy = endPinMapImage {
                map.remove(endPinToDestroy)
            }
            //endPinMapImage = map.display(image)
            endPinMapImage = map.display(image, drawOrder: INT32_MAX)
            endPinMapImage?.position = pinPos
            endPinMapImage?.offset = CGPoint.init(x: image.size.width/2, y: 0)
        }
    }
    
    func addStartPinFromLatLon(lat: Double, lon: Double) {
        let pinPos = GLMapPointMakeFromGeoCoordinates(lat, lon)
        
        if let image = UIImage.init(named: "pin-start") {
            if let startPinToDestroy = startPinMapImage {
                map.remove(startPinToDestroy)
            }
            //startPinMapImage = map.display(image)
            startPinMapImage = map.display(image, drawOrder: INT32_MAX)
            startPinMapImage?.position = pinPos
            startPinMapImage?.offset = CGPoint.init(x: image.size.width/2, y: 0)
        }
    }
    
    func addEndPinFromLatLon(lat: Double, lon: Double) {
        let pinPos = GLMapPointMakeFromGeoCoordinates(lat, lon)
        
        if let image = UIImage.init(named: "pin-end") {
            if let endPinToDestroy = endPinMapImage {
                map.remove(endPinToDestroy)
            }
            //endPinMapImage = map.display(image)
            endPinMapImage = map.display(image, drawOrder: INT32_MAX)
            endPinMapImage?.position = pinPos
            endPinMapImage?.offset = CGPoint.init(x: image.size.width/2, y: 0)
        }
    }
    
    func deleteStartPin() {
        if startPinMapImage != nil {
            map.remove(startPinMapImage!)
            startPinMapImage = nil
        }
    }
    
    func deleteEndPin() {
        if endPinMapImage != nil {
            map.remove(endPinMapImage!)
            endPinMapImage = nil
        }
    }
    
    
    func receiveStationsAsGeoJsonString(geojson: String) {
        if let imagePath = Bundle.main.path(forResource: "cluster", ofType: "svgpb") {
            // We use different colours for our clusters
            let tintColors = [
                GLMapColorMake(33, 0, 255, 255),
                GLMapColorMake(68, 195, 255, 255),
                GLMapColorMake(63, 237, 198, 255),
                GLMapColorMake(15, 228, 36, 255),
                GLMapColorMake(168, 238, 25, 255),
                GLMapColorMake(214, 234, 25, 255),
                GLMapColorMake(223, 180, 19, 255),
                GLMapColorMake(255, 0, 0, 255)
            ]
            
            // Create style collection - it's storage for all images possible to use for markers and clusters
            let styleCollection = GLMapMarkerStyleCollection.init()
            
            // Render possible images from svgpb
            for i in 0 ... tintColors.count-1 {
                let scale = 0.2 + 0.1 * Double(i)
                if let image = GLMapVectorImageFactory.shared().image(fromSvgpb: imagePath, withScale: scale, andTintColor: tintColors[i] ) {
                    
                    styleCollection.addMarkerImage(image)
                }
            }
            
            // Create style for text
            let textStyle = GLMapVectorStyle.createStyle("{text-color:black;font-size:12;font-stroke-width:1pt;font-stroke-color:#FFFFFFEE;}")
            
            
            // Union fill block used to set style for cluster object. First param is number objects inside the cluster and second is marker object.
            styleCollection.setMarkerUnionFill({ (markerCount, data) in
                // we have 8 marker styles for 1, 2, 4, 8, 16, 32, 64, 128+ markers inside
                var markerStyle = Int( log2( Double(markerCount) ) )
                if markerStyle >= tintColors.count {
                    markerStyle = tintColors.count-1
                }
                
                data.setStyle( UInt(markerStyle) )
                data.setText("\(markerCount)", offset: CGPoint.zero, style: textStyle!)
            })
            
            // When we have big dataset to load. We could load data and create marker layer in background thread. And then display marker layer on main thread only when data is loaded.
            DispatchQueue.global().async {
                if let objects = GLMapVectorObject.createVectorObjects(fromGeoJSON: geojson) {
                    let markerLayer = GLMapMarkerLayer.init(vectorObjects: objects, andStyles: styleCollection)
                    
                    //markerLayer.clusteringEnabled = false
                    let bbox = objects.bbox
                    
                    DispatchQueue.main.async { [weak self] in
                        if let wself = self {
                            let map = wself.map;
                            map.display(markerLayer, completion: nil)
                            map.setMapCenter(bbox.center, zoom: map.mapZoom(for: bbox))
                        }
                    }
                }
            }
        }
        
    }

    private func cleanPath() {
        if displayedPath != nil {
            map.remove([displayedPath!])
            displayedPath = nil
        }
        for st in displayedIntermediateStations {
            map.remove(st)
        }
        displayedIntermediateStations = []
    }
    func displayPath() {
        cleanPath()	
        
        let style = GLMapVectorCascadeStyle.createStyle("line{z-index: 1000000;width: 7pt; color:blue;}")

        guard let path: GLMapVectorObject = pathRepo?.mapVectorObjectToReturn else {
            return
        }
        displayedPath = path
        
        if let image = UIImage.init(named: "pin-station") {
            for st in (pathRepo?.stations)! {
                let pinPos = GLMapPointMakeFromGeoCoordinates(st.lat, st.lon)
                
                if let stationPin = map.display(image, drawOrder: INT32_MAX) {
                    stationPin.position = pinPos
                    stationPin.offset = CGPoint.init(x: image.size.width/2, y: 0)
                    displayedIntermediateStations.append(stationPin)
                }
            }
        }
        
        map.add([path], with: style)
        let bbox = path.bbox
        map.setMapCenter(bbox.center, zoom: map.mapZoom(for: bbox)-1)
        
        cancelSearchingBikePath()
    }
    
    func searchBikePath() {
        // Check if both start and end point are specified
        guard startPinMapImage != nil, endPinMapImage != nil else {
            displayAlert(nil, message: "Start or End point of trip is not specified", viewcontroller: self)
            return
        }
        
        // Adjust search button (calculating path may take a while)
        btnSearchPath.setTitle("Cancel", for: .normal)
        btnSearchPath.backgroundColor = UIColor.init(red: 0.8, green: 0.1, blue: 0.17, alpha: 1.0)
        btnSearchPath.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        btnSearchPath.addTarget(self, action: #selector(MainViewController.cancelSearchingBikePath), for: .touchUpInside)
        let position1 = GLMapGeoPointFromMapPoint((startPinMapImage?.position)!)
        let position2 = GLMapGeoPointFromMapPoint((endPinMapImage?.position)!)
        print("x1=\(String(describing: position1.lon)), y1 = \(String(describing: position1.lat)), x2 = \(String(describing: position2.lon)), y2 = \(String(describing: position2.lat))")
        pathRepo = Path(x1: position1.lon, y1: position1.lat, x2: position2.lon, y2: position2.lat)
        pathRepo?.sendDataThourghNotificationCenter()
        
        cleanPath()
    }
    
    func cancelSearchingBikePath() {
        // Restore previous state of search button
        btnSearchPath.backgroundColor = UIColor(colorLiteralRed: 0.0, green: 0.9, blue: 0.1, alpha: 1.0)
        btnSearchPath.setTitle("Search", for: UIControlState.normal)
        btnSearchPath.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        btnSearchPath.addTarget(self, action: #selector(MainViewController.searchBikePath), for: .touchUpInside)
        
        // Remove connection to pathRepo
        pathRepo?.registered = false
        pathRepo = nil
        
    }
    
    func setStartPoint() {
        let vc = GeocodingViewController()
        vc.delegate = self
        vc.pinselect = .Start
        vc.userLocation = map.lastLocation
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func setEndPoint() {
        let vc = GeocodingViewController()
        vc.delegate = self
        vc.pinselect = .End
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

