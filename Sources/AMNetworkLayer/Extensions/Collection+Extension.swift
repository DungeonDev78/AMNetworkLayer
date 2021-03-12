//
//  Collection+Extension.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

extension Collection {
    
    /// Convert any Swift Collection into a readable JSON String format
    public var jsonStringRepresentation: String {
        if #available(iOS 11.0, *) {
            
            guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                                options: [.prettyPrinted, .sortedKeys]) else {
                                                                    return "DICTIONARY TO JSON ERROR"
            }
            
            return String(data: theJSONData, encoding: .ascii) ?? "DICTIONARY TO JSON ERROR"
        } else {
            return "DICTIONARY TO JSON ERROR"
        }
    }
}
