//
//  Feature.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/11/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit

class Feature: NSObject {
    
    enum FeatureType {
        case detectBill, whatTimeIsIt, whereIAm, helpMe
        
        var features: String {
            switch self {
            case .detectBill:
                return "Detect Bill"
                
            case .whatTimeIsIt:
                return "What time is it?"
                
            case .whereIAm:
                return "Where i am?"
                
            case .helpMe:
                return "SOS"
                
            }
        }
    }
    
    
    let features = ["Detect Bill", "What time is it?", "Where i am?", "SOS"]

}
