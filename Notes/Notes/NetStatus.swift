//
//  NetStatus.swift
//  Notes
//
//  Created by ios_school on 3/27/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import Network
import Foundation

class NetStatus {
    static let shared = NetStatus()
    
    private var monitor: NWPathMonitor?
    private var isMonitoring = false
    private var didStartMonitoringHandler: (() -> Void)?
    private var didStopMonitoringHandler: (() -> Void)?
    private var netStatusChangeHandler: (() -> Void)?
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        
        return monitor.currentPath.status == .satisfied
    }
    
    private init() {
        
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetStatus_Monitor")
        
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
        
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        
        monitor.cancel()
        
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
}
