//
//  WhereIAm.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/9/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit
import CoreLocation
class WhereIAm: NSObject {
    
    let textToSpeech = TextToSpeech()
    var address = ""
    
    func displayLocationInfo(pm: CLPlacemark?, locationNeeds: String) -> [String] {
        address = ""
        if let placemark = pm {
            print(placemark.locality ?? "")
            print(placemark.name ?? "")
            print(placemark.administrativeArea ?? "")
            print(placemark.country ?? "")
            
            let locality = placemark.locality ?? ""
            let name = placemark.name ?? ""
            let administrativeArea = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            
            if name != "" {
                address = name
            }
            if locality != "" {
                address = address + ", " + locality
            }
            //            if administrativeArea != "" {
            //                address = address + ", in: " + administrativeArea
            //            }
            //            if country != "" {
            //                address = address + ", " + country
            //            }
            
            if locationNeeds == "email"{
                return [String(describing: placemark.location!.coordinate.latitude), String(describing: placemark.location!.coordinate.longitude), address]
            } else {
                speech()
                return [""]
            }
        }
        return [""]
    }
    
    
    private func speech() {
        textToSpeech.speak(text: "You are in: ")
        textToSpeech.speak(text: address)
    }
}
