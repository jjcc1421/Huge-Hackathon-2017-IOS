//
//  WhatTimeIsIt.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/11/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit

class WhatTimeIsIt: NSObject {
    
    let date = Date()
    let textToSpeech = TextToSpeech()
    var time = ""
    
    func getTime() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date as Date)
        
        time = "The time is, \(hour) with \(minutes) minutes"
        textToSpeech.speak(text: time)
    }
}
