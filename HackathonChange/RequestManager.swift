//
//  RequestManager.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/12/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestManager: NSObject {

    
    let textToSpeech = TextToSpeech()
    
    func makeRequestPost(URL: String, JSON: [String: Any], feature: String) {
        
        let nsurl = NSURL(string: URL)!
        var request = URLRequest(url: nsurl as URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: JSON)
        
        Alamofire.request(request).responseString { response in
            let result = response.result
            
            switch result {
                
            case .failure(let error):
                
                if feature == "email" {
                    self.textToSpeech.speak(text: "Error sending the email, please try again!")
                }
                print(error)
                
            case .success(let responseObject):
                
                if feature == "email" {
                    self.textToSpeech.speak(text: "Email sent!")
                }
            }
        }
    }
}
