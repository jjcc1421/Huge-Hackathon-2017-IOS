//
//  BluetoothDiscover.swift
//  HackathonChange
//
//  Created by Laura Mejia Arroyave on 1/11/17.
//  Copyright © 2017 Laura Mejia Arroyave. All rights reserved.
//

import UIKit
import CoreBluetooth

let BluetoothDiscoverSharedInstance = BluetoothDiscover()

class BluetoothDiscover: NSObject, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager?
    private var peripheralBluetooth: CBPeripheral?
    
    override init() {
        super.init()
        
        let centralQueue = DispatchQueue(label: "laura-bluetooth-HACKATHON", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func startScanningDevices() {
        if let central = centralManager {
            central.scanForPeripherals(withServices: [BluetoothServiceUUID], options: nil)
        }
    }
    
    var bluetoothService: BluetoothManager? {
        didSet {
            if let service = self.bluetoothService {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if ((peripheral.name == nil) || (peripheral.name == "")) {
            return
        }
    
        if ((self.peripheralBluetooth == nil) || (self.peripheralBluetooth?.state == CBPeripheralState.disconnected)) {
            self.peripheralBluetooth = peripheral
            self.bluetoothService = nil
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if (peripheral == self.peripheralBluetooth) {
            self.bluetoothService = BluetoothManager(initWithPeripheral: peripheral)
        }
        
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if (peripheral == self.peripheralBluetooth) {
            self.bluetoothService = nil;
            self.peripheralBluetooth = nil;
        }
        self.startScanningDevices()
    }
    
    private func clearDevices() {
        self.bluetoothService = nil
        self.peripheralBluetooth = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
            
        case .poweredOff:
            self.clearDevices()
            
        case .poweredOn:
            self.startScanningDevices()
            
        case .resetting:
            self.clearDevices()
            
        case .unauthorized, .unsupported, .unknown:
            break
        }
    }
    
}
