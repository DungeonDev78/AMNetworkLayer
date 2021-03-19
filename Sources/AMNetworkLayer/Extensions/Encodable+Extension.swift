//
//  File.swift
//  
//
//  Created by Alessandro Manilii on 19/03/21.
//

import Foundation

extension Encodable {
   
    /// Create a json of the Codable object
    var jsonRepresentation: String? {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(self),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return nil
    }
}
