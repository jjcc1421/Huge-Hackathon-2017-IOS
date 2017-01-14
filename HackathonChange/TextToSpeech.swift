//
//  TextToSpeech.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/9/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit
import AVFoundation
class TextToSpeech: NSObject {
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(text: String){
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = 0.4
        speechSynthesizer.speak(speechUtterance)
    }

}
