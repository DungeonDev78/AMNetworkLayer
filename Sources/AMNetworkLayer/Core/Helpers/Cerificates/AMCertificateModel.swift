//
//  AMCertificateModel.swift
//  
//  Created by Alessandro Manilii on 11/03/21.
//

import Foundation

public struct AMCertificateModel {
    
    // MARK: - ExtensionType
    /// The types of possible certification extension. Other accept any type.
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
    
    // MARK: - Properties
    var filename: String
    var fileExtension: ExtensionType
    
    // MARK: - Initialization
    public init(filename: String, fileExtension: ExtensionType) {
        self.filename = filename
        self.fileExtension = fileExtension
    }
    
    /// Convert the certificate model into a data. If there is any error in the certificate file, the app will crash... this is wanted since the sensitive topic of app security.
    /// - Returns: The converted data
    func convertToData() -> Data {
        let certificateUrl = Bundle.main.url(forResource: filename, withExtension: fileExtension.getExtension())
        // WARNING: IF NIL MUST CRASH!!!
        return  try! Data(contentsOf: certificateUrl!)
    }
}
