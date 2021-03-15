//
//  AMServiceProviderProtocol.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

// MARK: - AMServiceProviderProtocol
public protocol AMServiceProviderProtocol: Codable {
    
    /// Get the host of the service provider. Could be different accorfing to different environments; implement an enum with the possible options.
    func getHost() -> String
    
    /// Get the HTTP Scheme of the service provider. Could be different accorfing to different environments; implement an enum with the possible options.
    func getHTTPScheme() -> AMNetworkManager.SchemeKind
    
    /// Create the HTTP Header of the service provider according to the rules of the server
    func createHTTPHeader() -> [String: String]
    
    /// Perform a parse and a validation of the response according to the rules of the server
    /// - Parameters:
    ///   - data: the raw data of the response
    ///   - request: the original request, needed for the phantom type of the response type
    ///   - error: the possible general error of the given service
    ///   - completion: the completion handler
    func parseAndValidate<U: Codable, T: AMBaseRequest<U>>(_ data: Data,
                                                      request: T,
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
