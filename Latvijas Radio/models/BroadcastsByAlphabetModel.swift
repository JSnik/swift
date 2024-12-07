//
//  BroadcastsByAlphabetModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByAlphabetModel: Codable {
    
    static let TAG = String(describing: BroadcastsByAlphabetModel.self)

    static let TYPE_SYMBOL = "TYPE_SYMBOL"
    static let TYPE_BROADCAST = "TYPE_BROADCAST"
    
    private let type: String
    private var symbol: String?
    private var broadcast: BroadcastModel?
    
    init(_ type: String, _ symbol: String?, _ broadcast: BroadcastModel?){
        self.type = type
        self.symbol = symbol
        self.broadcast = broadcast
    }
    
    func getType() -> String {
        return type
    }
    
    func getSymbol() -> String? {
        return symbol
    }
    
    func getBroadcast() -> BroadcastModel? {
        return broadcast
    }
}
