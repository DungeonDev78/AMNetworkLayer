//
//  AMNetworkLogger.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

class AMNetworkLogger {
    
    static func logRequest<U: Codable>(_ urlReqest: URLRequest, request: AMBaseRequest<U>) {
        
        let title = request.endpoint.components(separatedBy: "/").last ?? "---"
        print("\n***************************************************************")
        print("*** REQUEST LOG STARTS HERE - \(title) ***")
        print("*** URL: \(urlReqest.url?.absoluteString ?? "---")")
        print("*** ENDPOINT: \(request.endpoint)")
        print("*** HTTP HEADERS:\(urlReqest.allHTTPHeaderFields?.jsonStringRepresentation ?? "---")")
        print("*** HTTP METHOD: \(urlReqest.httpMethod ?? "---")")
        print("*** HTTP PARAMS: \(request.params.jsonStringRepresentation)")
        print("*** REQUEST LOG ENDS HERE ***")
        print("***************************************************************\n")
    }
    
    static func logResponse(_ httpResponse: HTTPURLResponse, responseData: Data?) {
        
        let title = httpResponse.url?.absoluteString.components(separatedBy: "/").last ?? "---"
        print("\n***************************************************************")
        print("*** RESPONSE LOG STARTS HERE - \(title) ***")
        print("*** URL: \(httpResponse.url?.absoluteString ?? "---")")
        print("*** STATUS CODE: \(httpResponse.statusCode)")
        print("*** HEADER:")
        print(httpResponse.allHeaderFields.jsonStringRepresentation)
        
        guard let gResponse = responseData else {
            print("*** Response Data not readable\n")
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: gResponse, options: []) as AnyObject {
            print("\n*** JSON response:")
            
            if let jsonResponseArray = json as? [Any] {
                print(jsonResponseArray.jsonStringRepresentation)
            }
            
            if let jsonResponseDictionary = json as? [String: Any] {
                print(jsonResponseDictionary.jsonStringRepresentation)
            }
        } else if let responseString = String(data: gResponse, encoding: String.Encoding.utf8) {
            print("\n*** STRING response:")
            print(responseString)
        }
        
        print("*** RESPONSE LOG ENDS HERE ***")
        print("***************************************************************\n")
    }
    
    static func mockedServiceLog() {
        print("\n**********************")
        print("***                ***")
        print("*** SERVICE MOCKED ***")
        print("***                ***")
        print("**********************\n")
    }
}
