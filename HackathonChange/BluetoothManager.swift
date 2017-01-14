//
//  BluetoothManager.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/11/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BluetoothServiceUUID = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")
let BluetoothPositionCharUUID = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb")
var BLEServiceChangedStatusNotification = "KEYESBluetoothServiceChangedStatus"

protocol BluetoothServiceManagerDelegate {
    func bluetoothConnectionStatusDidChange(bluetoothConnected status: Bool)
}

class BluetoothManager: NSObject, CBPeripheralDelegate {
    
    var peripheral: CBPeripheral?
    var positionCharacteristic: CBCharacteristic?
    var delegate: BluetoothServiceManagerDelegate?
    
    var completeString = ""
    var inProgressBLEService = false
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([BluetoothServiceUUID])
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        self.sendBluetoothTServiceAdviceWhenIsBluetoothConnected(false)
    }
    
    func writePosition(_ position: UInt8) {
        
        if let positionCharacteristic = self.positionCharacteristic {
            let data = Data(bytes: [position])
            self.peripheral?.writeValue(data as Data, for: positionCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    func sendBluetoothTServiceAdviceWhenIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let uuidsForBTService: [CBUUID] = [BluetoothPositionCharUUID]
        
        if (peripheral != self.peripheral) {
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            return
        }
        
        for service in peripheral.services! {
            if service.uuid == BluetoothServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (peripheral != self.peripheral) {
            return
        }
        
        if (error != nil) {
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == BluetoothPositionCharUUID {
                    self.positionCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    sendBluetoothTServiceAdviceWhenIsBluetoothConnected(true)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (error != nil) {
            print("Error rading characteristics: \(error)......)")
            return;
        }
        
        
        if let data = characteristic.value {
            if let dataBLE = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                print("String Data from Arduino: \(dataBLE)")
                
                let last4 = dataBLE.substring(from:dataBLE.index(dataBLE.endIndex, offsetBy: -1))
                if last4 != "\r\n" {
                    
                    inProgressBLEService = true
                    completeString = completeString + dataBLE
                    
                } else {
                    completeString = completeString + dataBLE
                    
                    let index = completeString.index(completeString.startIndex, offsetBy: 8)
                    
                    let supposedFeature = completeString.substring(to: index)
                    
                    detectFeature(firstString: supposedFeature, completedString: completeString)
                    
                    print(completeString)
                    completeString = ""
                    inProgressBLEService = false
                }
                
            }
            print("characteristic uuid: \(characteristic.uuid), value:  \(characteristic.value)")
            
            print("Data from Arduino: \(data[0])")
        }
    }
    
    func detectFeature(firstString: String, completedString: String) {
        
        var connectionDetails = [String: Any]()
        
        switch firstString {
        case "Feature1":
            let supposedResponse = completeString.replacingOccurrences(of: firstString, with: "")
            print(supposedResponse)
            connectionDetails = ["button": 1, "completeString": supposedResponse]
            NotificationCenter.default.post(name: Notification.Name(rawValue: PressedButtonNotification), object: self, userInfo: connectionDetails)
        case "Feature2":
            connectionDetails = ["button": 2]
            NotificationCenter.default.post(name: Notification.Name(rawValue: PressedButtonNotification), object: self, userInfo: connectionDetails)
        case "Feature3":
            connectionDetails = ["button": 3]
            NotificationCenter.default.post(name: Notification.Name(rawValue: PressedButtonNotification), object: self, userInfo: connectionDetails)
        case "Feature4":
            connectionDetails = ["button": 4]
            NotificationCenter.default.post(name: Notification.Name(rawValue: PressedButtonNotification), object: self, userInfo: connectionDetails)
        default:
            break
        }
    }
}
