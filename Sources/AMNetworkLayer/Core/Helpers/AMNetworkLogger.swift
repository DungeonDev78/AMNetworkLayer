//
//  AMNetworkLogger.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

class AMNetworkLogger {
    
    /// Create the full log (printed) of a request
    /// - Parameters:
    ///   - urlReqest: the URLRequest to log
    ///   - request: the AMBaseRequest to log, needed for Params and the Endpoint
    static func logRequest<U: Codable>(_ urlReqest: URLRequest, request: AMBaseRequest<U>) {
        
        debugPrint(urlReqest)
        
//        let title = request.endpoint.components(separatedBy: "/").last ?? "---"
//        print("\n***************************************************************")
//        print("*** REQUEST LOG STARTS HERE - \(title) ***")
//        print("*** URL: \(urlReqest.url?.absoluteString ?? "---")")
//        print("*** ENDPOINT: \(request.endpoint)")
//        print("*** HTTP HEADERS:\(urlReqest.allHTTPHeaderFields?.jsonStringRepresentation ?? "---")")
//        print("*** HTTP METHOD: \(urlReqest.httpMethod ?? "---")")
//        print("*** PARAMS: \(request.params.jsonStringRepresentation)")
//        print("*** REQUEST LOG ENDS HERE ***")
        print("***************************************************************\n")
    }
    
    /// Create the full log (printed) of a response
    /// - Parameters:
    ///   - httpResponse: the HTTPURLResponse to log
    ///   - responseData: the data of the response to log as JSON or String
    static func logResponse(_ httpResponse: HTTPURLResponse, responseData: Data?) {
        
    debugPrint(httpResponse)
        
//        let title = httpResponse.url?.absoluteString.components(separatedBy: "/").last ?? "---"
        print("\n***************************************************************")
        debugPrint(responseData)
//        print("*** RESPONSE LOG STARTS HERE - \(title) ***")
//        print("*** URL: \(httpResponse.url?.absoluteString ?? "---")")
//        print("*** STATUS CODE: \(httpResponse.statusCode)")
//        print("*** HEADERS:")
//        print(httpResponse.allHeaderFields.jsonStringRepresentation)
//
//        guard let gResponse = responseData else {
//            print("*** Response Data not readable\n")
//            return
//        }
//
//        if let json = try? JSONSerialization.jsonObject(with: gResponse, options: []) as AnyObject {
//            print("\n*** JSON response:")
//
//            if let jsonResponseArray = json as? [Any] {
//                print(jsonResponseArray.jsonStringRepresentation)
//            }
//
//            if let jsonResponseDictionary = json as? [String: Any] {
//                print(jsonResponseDictionary.jsonStringRepresentation)
//            }
//
//        // In the case that we are expeting a simple string
//        } else if let responseString = String(data: gResponse, encoding: String.Encoding.utf8) {
//            print("\n*** STRING response:")
//            print(responseString)
//        }
        
        print("*** RESPONSE LOG ENDS HERE ***")
        print("***************************************************************\n")
    }
    
    /// Print a moked warning
    static func mockedServiceLog() {
        print("\n**********************")
        print("***                ***")
        print("*** SERVICE MOCKED ***")
        print("***                ***")
        print("**********************\n")
    }
}
