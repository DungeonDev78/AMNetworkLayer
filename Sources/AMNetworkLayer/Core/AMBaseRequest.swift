//
//  AMBaseRequest.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

/// Create a request class inherited from this object.
/// Must use the Phantom Type to specify the type of the response.
open class AMBaseRequest<Response> {
    // MARK: - Properties
    public var endpoint: String
    public var params = [String: Any]()
    public var timeout = 60.0
    public var httpMethod: AMNetworkManager.HTTPMethodKind = .get
    
    // Hold the infos of the contacted server
    public var serviceProvider: AMServiceProviderProtocol
    
    // Filename of the json mocked response
    public var mockedResponseFilename = "*** PLEASE INSERT FILENAME ***"
    
    // MARK: - Initialization
    public init(serviceProvider: AMServiceProviderProtocol, endpoint: String) {
        self.serviceProvider = serviceProvider
        self.endpoint = endpoint
    }
}

// MARK: - Request Creation
extension AMBaseRequest {
    
    /// Create the URLRequest using all the available infos
    /// - Returns: the created URLRequest
    func createURLRequest() -> URLRequest {
        // MUST CRASH IF WRONG URL
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
        
        for (key, value) in serviceProvider.createHTTPHeaders() {
            urlrequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return urlrequest
    }
}

// MARK: - Private
private extension AMBaseRequest {

    /// Create the URLusing all the available infos
    /// - Returns: the created URL
    func createURL() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = serviceProvider.httpScheme.rawValue
        urlComponents.host = serviceProvider.host
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
    
    /// Creates the query items from the params dictionary
    /// - Returns: the list of query items
    func getQueryItems() -> [URLQueryItem]? {
        
        guard !params.isEmpty else { return nil }
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        return queryItems
    }
}

// MARK: - Extension
extension AMBaseRequest {
    
    var identifier: String {
        get { return String(describing: self) }
    }
}
