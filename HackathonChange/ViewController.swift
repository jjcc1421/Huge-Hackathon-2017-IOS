//
//  ViewController.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/9/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

let PressedButtonNotification = "PressedButtonNotification"

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var bluetoothServiceImageView: UIImageView!
    let feature = Feature()
    var timerTXDelay: Timer?
    var allowTX = true
    var lastPosition: UInt8 = 255
    var locationManager = CLLocationManager()
    let textToSpeech = TextToSpeech()
    let whereIAm = WhereIAm()
    //var locationInfo = [""]
    var imgBase64 = ""
    
    let requestManager = RequestManager()
    
    var presetPosition = 0
    
    var flagLocationNeeds = ""
    
    // var JSONLocation = [String: Any]()
    
    @IBOutlet weak var feature1Button: UIButton!
    @IBOutlet weak var feature2Button: UIButton!
    @IBOutlet weak var feature3Button: UIButton!
    @IBOutlet weak var feature4Button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        // Buttons call
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.pressedButton(_:)), name: NSNotification.Name(rawValue: PressedButtonNotification), object: nil)
        
        // Start the Bluetooth discovery process
        _ = BluetoothDiscoverSharedInstance
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: PressedButtonNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feature1Action(_ sender: Any) {
        
        
    }
    
    @IBAction func feature2Action(_ sender: Any) {
        let whatTimeIsIt = WhatTimeIsIt()
        whatTimeIsIt.getTime()
    }
    
    @IBAction func feature3Action(_ sender: Any) {
        
        self.flagLocationNeeds = "location"
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func feature4Action(_ sender: Any) {
        
        self.flagLocationNeeds = "email"
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func pressedButton(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo as! [String: Any]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            
            var button = Int()
            var str = ""
            for info in userInfo {
                
                print(info.key)
                if info.key == "button" {
                    button = info.value as! Int
                }
                
                if info.key == "completeString" {
                    str = info.value as! String
                    print(str)
                }
                
            }
            
            
            switch button {
            case 1:
                
                
                let jsonResponse = JSON(str)
                let jsonDictionary = jsonResponse
                print(jsonDictionary)
                
                if let dataFromString = str.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    print(json)
                
                    
                    let currency = json["currency"].description
                    let value = json["value"].description
                    self.textToSpeech.speak(text: "1000")
                    self.readCurrency(currency: String(describing: currency))

                }
                
              
                
               // let JSONResponse = JSON(response)
                
                self.feature1Button.sendActions(for: .touchUpInside)
            case 2:
                self.feature2Button.sendActions(for: .touchUpInside)
            case 3:
                self.feature3Button.sendActions(for: .touchUpInside)
            case 4:
                self.feature4Button.sendActions(for: .touchUpInside)
                
            default:
                break
            }
            
            
        })
    }
    
    func readCurrency(currency: String) {
        let currency = currency.lowercased()
        let currencyCharacters = currency.characters.map { String($0) }
        
        for character in currencyCharacters {
            textToSpeech.speak(text: character)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //        switch status {
        //        case .authorizedWhenInUse, .authorizedAlways:
        //            locationManager.startUpdatingLocation()
        //        case .notDetermined:
        //            locationManager.requestWhenInUseAuthorization()
        //        case .restricted, .denied: break
        //            // Tell user that the app need auth
        //
        //        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
        if let location = locations.last {
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                print(location)
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    
                    let pm = (placemarks?.last)! as CLPlacemark
                    
                    if self.flagLocationNeeds == "location" {
                        let _ = self.whereIAm.displayLocationInfo(pm: pm, locationNeeds: self.flagLocationNeeds)
                    } else if self.flagLocationNeeds == "email" {
                        
                        let locationInfo = self.whereIAm.displayLocationInfo(pm: pm, locationNeeds: self.flagLocationNeeds)
                        
                        let JSONLocation =
                            ["email":
                                ["id": "UUID00806290153",
                                 "geo": ["lat": locationInfo[0], "lon": locationInfo[1], "name": locationInfo[2]],
                                 "email": "lmejia@hugeinc.com",
                                 "name": "Huger Tester" ]
                        ]
                        
                        let URL = "https://the-skywalkers.herokuapp.com/api/v1/mail"
                        self.requestManager.makeRequestPost(URL: URL, JSON: JSONLocation, feature: "email")
                        
                    }
                    else {
                        print("Problem with the data received from geocoder")
                    }
                    self.locationManager.stopUpdatingLocation()
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("I cant get your location: \(error)")
    }
    
    func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.bluetoothServiceImageView.image = UIImage(named: "connected")
                    
                    // Send current slider position
                    //self.sendPosition(UInt8(self.presetPosition))
                } else {
                    self.bluetoothServiceImageView.image = UIImage(named: "disconnected")
                }
            }
        })
    }
    
    
    //    func sendPosition(_ position: UInt8) {
    //        // Valid position range: 0 to 180
    //
    //        if !allowTX {
    //            return
    //        }
    //
    //        // Validate value
    //        if position == lastPosition {
    //            return
    //        }
    //        else if ((position < 0) || (position > 180)) {
    //            return
    //        }
    //
    //        // Send position to BLE Shield (if service exists and is connected)
    //        if let bluetoothService = BluetoothDiscoverSharedInstance.bluetoothService {
    //
    //
    //            bluetoothService.writePosition(position)
    //            lastPosition = position
    //
    //            // Start delay timer
    //            allowTX = false
    //            if timerTXDelay == nil {
    //                timerTXDelay = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.timerTXDelayElapsed), userInfo: nil, repeats: false)
    //            }
    //        }
    //    }
    
    //    func timerTXDelayElapsed() {
    //        self.allowTX = true
    //        self.stopTimerTXDelay()
    //
    //        // Send current slider position
    //        self.sendPosition(UInt8(presetPosition))
    //    }
    //
    //    func stopTimerTXDelay() {
    //        if self.timerTXDelay == nil {
    //            return
    //        }
    //
    //        timerTXDelay?.invalidate()
    //        self.timerTXDelay = nil
    //   }
    
}



