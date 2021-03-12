//
//  AMBaseRequest.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

open class AMBaseRequest<Response> {
    
    public var endpoint: String
    
    public var params = [String: Any]()
    public var timeout = 60.0
    public var httpMethod: AMNetworkManager.HTTPMethodKind = .get
    public var scheme: AMNetworkManager.SchemeKind = .https
    public var serviceProvider: AMServiceProviderProtocol
    public var mockedResponseFilename = "*** PLEASE INSERT FILENAME ***"
    
    public init(serviceProvider: AMServiceProviderProtocol, endpoint: String) {
        self.serviceProvider = serviceProvider
        self.endpoint = endpoint
    }
    
    func createURLRequest() -> URLRequest {
        let url = createURL()!
        var urlrequest = URLRequest(url: url)
        urlrequest.httpMethod = httpMethod.rawValue
        urlrequest.timeoutInterval = timeout
        
        switch httpMethod {
        case .post, .put, .patch, .delete:
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { break }
            urlrequest.httpBody = httpBody
        default: break
        }
        
        for (key, value) in serviceProvider.createHTTPHeader() {
            urlrequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return urlrequest
    }
}

private extension AMBaseRequest {

    func createURL() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = serviceProvider.getHTTPScheme().rawValue
        urlComponents.host = serviceProvider.getHost()
        urlComponents.path = endpoint
        switch httpMethod {
        case .get:
            urlComponents.queryItems = getQueryItems()
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
                // manually encode + into percent encoding
                .replacingOccurrences(of: "+", with: "%2B")
                // optional, probably unnecessary: convert percent-encoded spaces into +
                .replacingOccurrences(of: "%20", with: "+")
            
        default:
            break
        }
        
        return urlComponents.url
    }
    
    func getQueryItems() -> [URLQueryItem]? {
        
        guard !params.isEmpty else { return nil }
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        return queryItems
    }
}

extension AMBaseRequest {
    
    var identifier: String {
        get { return String(describing: self) }
    }
}
