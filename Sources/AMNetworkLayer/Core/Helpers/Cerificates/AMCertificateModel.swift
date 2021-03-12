//
//  AMCertificateModel.swift
//  
//  Created by Alessandro Manilii on 11/03/21.
//

import Foundation

public struct AMCertificateModel {
    
    public enum ExtensionType {
        case cer
        case crt
        case der
        case other(fileExtension: String)
        
        func getExtension() -> String {
            switch self {
            case .cer                      : return "cer"
            case .crt                      : return "crt"
            case .der                      : return "der"
            case .other(let fileExtension) : return fileExtension
            }
        }
    }
    
    var filename: String
    var fileExtension: ExtensionType
    
    public init(filename: String, fileExtension: ExtensionType) {
        self.filename = filename
        self.fileExtension = fileExtension
    }
    
    func convertToData() -> Data {
        let certificateUrl = Bundle.main.url(forResource: filename, withExtension: fileExtension.getExtension())
        // WARNING: IF NIL MUST CRASH!!!
        return  try! Data(contentsOf: certificateUrl!)
    }
}
