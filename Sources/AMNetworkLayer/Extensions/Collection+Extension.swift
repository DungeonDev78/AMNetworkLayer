//
//  Collection+Extension.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

extension Collection {
        
    private var collectionError: String {
        "*** COLLECTION TO JSON ERROR ***"
    }
    
    /// Convert any Dictionary into a readable JSON String format
    public var jsonStringRepresentation: String {
        if #available(iOS 11.0, *) {
            
            guard let theJSONData = try? JSONSerialization.data(
                    withJSONObject: self,
                    options: [.prettyPrinted, .sortedKeys]) else {
                return collectionError
            }
            
            return String(data: theJSONData, encoding: .ascii) ?? collectionError
        } else {
            return collectionError
        }
    }
}
