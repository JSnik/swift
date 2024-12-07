//
//  NetworkConnectivityManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 19/03/2023.
//

import Network

public class NetworkConnectivityManager {

    let TAG = String(describing: NetworkConnectivityManager.self)

    private var mediaPlayerManager: MediaPlayerManager!
    private let nwPathMonitor = NWPathMonitor()

    init(_ mediaPlayerManager: MediaPlayerManager) {
        self.mediaPlayerManager = mediaPlayerManager
    }
    
    func registerNetworkCallback() {
        guard nwPathMonitor.pathUpdateHandler == nil else { return }
        
        nwPathMonitor.pathUpdateHandler = { [weak self] path in
            if let self = self {
                // Note: Must test on actual devices, because Simulators are using MacOS network stack, not iOS.
                
                switch path.status {
                case .satisfied:
                    if (self.mediaPlayerManager.playerWasInterruptedDueToNetworkConnectivityIssue) {
                        self.mediaPlayerManager.playerWasInterruptedDueToNetworkConnectivityIssue = false
                        
                        DispatchQueue.main.async {
                            if (self.mediaPlayerManager.mediaPlayer.timeControlStatus == .paused) {
                                self.mediaPlayerManager.performActionToggleMediaPlayback()
                            }
                        }
                    }
                    
                    break
                case .unsatisfied, .requiresConnection:
                    break
                @unknown default:
                    break
                }
                
                // Leaving for reference:
//                if path.usesInterfaceType(.wifi) {
//                    self?.typeOfCurrentConnection.send(.wifi)
//                } else if path.usesInterfaceType(.cellular) {
//                    self?.typeOfCurrentConnection.send(.cellular)
//                } else if path.usesInterfaceType(.loopback) {
//                    self?.typeOfCurrentConnection.send(.loopBack)
//                } else if path.usesInterfaceType(.wiredEthernet) {
//                    self?.typeOfCurrentConnection.send(.wired)
//                } else if path.usesInterfaceType(.other) {
//                    self?.typeOfCurrentConnection.send(.other)
//                }
            }
        }
        
        nwPathMonitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func unregisterNetworkCallback() {
        nwPathMonitor.cancel()
    }
}
