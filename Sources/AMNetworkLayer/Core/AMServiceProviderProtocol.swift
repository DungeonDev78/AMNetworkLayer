//
//  AMServiceProviderProtocol.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

// MARK: - AMServiceProviderProtocol
public protocol AMServiceProviderProtocol: Codable {
            
    func getHost() -> String
    func getHTTPScheme() -> AMNetworkManager.SchemeKind
    func createHTTPHeader() -> [String: String]
    
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
