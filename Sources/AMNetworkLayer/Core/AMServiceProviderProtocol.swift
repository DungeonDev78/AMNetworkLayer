//
//  AMServiceProviderProtocol.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

// MARK: - AMServiceProviderProtocol
public protocol AMServiceProviderProtocol: Codable {
    
    /// It's the url host of the service provider. Could be different accodfing to different environments.
    /// If nededed implement an enum with the possible options using a computed var for host
    var host: String { get }
    
    /// It's the  HTTP Scheme of the service provider. Could be different according to different environments.
    /// If nededed implement an enum with the possible options using a computed var for httpScheme
    var httpScheme: AMNetworkManager.SchemeKind { get }
    
    /// Create the HTTP Headers of the service provider according to the rules of the server
    func createHTTPHeaders() -> [String: String]
    
    /// Perform a parse and a validation of the response according to the rules of the server
    /// - Parameters:
    ///   - data: the raw data of the response
    ///   - responseType: the generic of the response
    ///   - error: the possible general error of the given service
    ///   - completion: the completion handler
    func parseAndValidate<U: Codable>(_ data: Data,
                                      responseType: U.Type,
                                      error: AMError?,
                                      completion: @escaping AMNetworkCompletionHandler<U>)
}

// MARK: - Mocking stuff
extension AMServiceProviderProtocol {
    
    /// Mocks the time needed to fetch a response froma a server
       var mockedServiceTime: Double {
           get { return Double.random(in: 0.25 ..< 0.35) }
       }
    
    /// read data from json filename
    /// - Parameter fileName: the needed filename
    /// - Returns: the extracted data
    func getDataFrom(mockedResponseFilename fileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            assertionFailure("*** NO JSON FILE FOUND ***")
            return nil
        }
        
        return try? NSData(contentsOf: NSURL(fileURLWithPath: path) as URL, options: .alwaysMapped) as Data
    }
}
