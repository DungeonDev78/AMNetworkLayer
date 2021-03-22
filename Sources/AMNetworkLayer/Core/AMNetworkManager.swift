//
//  AMNetworkManager.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

public typealias AMNetworkCompletionHandler<U: Codable> = (Result<U, AMError>) -> Void

public protocol AMInjectionReachabilityProtocol {
    func isReachable(urlString: String) -> Bool
}

public let AMNet = AMNetworkManager.shared

public class AMNetworkManager: NSObject, AMInjectionReachabilityProtocol {
    
    public enum HTTPMethodKind: String, Codable {
        case get        = "GET"
        case post       = "POST"
        case delete     = "DELETE"
        case put        = "PUT"
        case patch      = "PATCH"
        case head       = "HEAD"
        case connect    = "CONNECT"
        case options    = "OPTIONS"
        case trace      = "TRACE"
    }
    
    public enum SchemeKind: String, Codable {
        case http
        case https
    }
    
    // MARK: - Initialization
    public static let shared = AMNetworkManager()
    
    public var isVerbose = true
    public var areMocksEnabled = false
    
    private var session: URLSession
    private var certificateManager = AMNetworkCertificateManager(certificates: [], isEnabled: false)
    
    private override init() {
        session = URLSession.init(configuration: .ephemeral)
    }
    
    public func configurePinningWith(certificates: [AMCertificateModel], isEnabled: Bool) {
        certificateManager = AMNetworkCertificateManager(certificates: certificates, isEnabled: isEnabled)
        session = URLSession.init(configuration: .ephemeral, delegate: certificateManager, delegateQueue: nil)
    }
    
    public func performRequest<U: Codable, T: AMBaseRequest<U>>(
        request: T,
        completion: @escaping AMNetworkCompletionHandler<U?>) {
        
        // Mocked services
        if areMocksEnabled {
            // Print log if wanted
            if isVerbose { AMNetworkLogger.mockedServiceLog() }
            
            parseMockedResponse(request: request, completion: completion)
            return
        }
        
        let urlRequest = request.createURLRequest()

        // Print request log if wanted
        if isVerbose {
            AMNetworkLogger.logRequest(urlRequest, request: request)
        }
       
        let task = session.dataTask(with: urlRequest, completionHandler: { [weak self] data, response, error in
            
            if let error = error as? URLError {
                switch URLError.Code(rawValue: error.code.rawValue) {
                case .notConnectedToInternet:
                    completion(.failure(.reachability))
                    return
                case .timedOut:
                    completion(.failure(.timeOut))
                    return
                case .cancelled:
                    completion(.failure(.invalidCertificate))
                    return
                default: break
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                var error: AMError?
            
                if self?.isVerbose == true {
                    AMNetworkLogger.logResponse(httpResponse, responseData: data)
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    break
                case 401:
                    error = AMError.unauthorizedAccess
                case 404:
                    error = AMError.notFound
                case 500:
                    error = AMError.generic()
                default:
                    error = AMError.generic(code: httpResponse.statusCode)
                }
                
                guard let gData = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.serialization))
                    }
                    return
                }
                
                self?.finalizeResponse(data: gData,
                                       serviceProvider: request.serviceProvider,
                                       error: error,
                                       completion: { result in completion(result) })

            } else {
                DispatchQueue.main.async {
                    completion(.failure(.generic()))
                }
            }
        })
        
        task.resume()
    }
    
    /// Check if the device is connected online
    /// - Returns: the result of the test
    public func isReachable(urlString: String = "https://www.apple.com") -> Bool {
        
        guard let url = URL(string: urlString) else { return false }
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (_, _, error) in
            if let error = error as? URLError {
                switch URLError.Code(rawValue: error.code.rawValue) {
                case .notConnectedToInternet:
                    success = false
                default: break
                }
            } else {
                success = true
            }
            
            semaphore.signal()
        })
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return success
    }
}

// MARK: - Private
private extension AMNetworkManager {
    
    func parseMockedResponse<U: Codable, T: AMBaseRequest<U>>(
        request: T,
        completion: @escaping AMNetworkCompletionHandler<U?>) {
        
        if let data = request.serviceProvider.getDataFrom(mockedResponseFilename: request.mockedResponseFilename) {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + request.serviceProvider.mockedServiceTime) { [weak self] in
                self?.finalizeResponse(data: data, serviceProvider: request.serviceProvider,
                                       error: nil, completion: completion)
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(.serialization))
            }
        }
    }
    
    func finalizeResponse<U: Codable>(data: Data,
                                      serviceProvider: AMServiceProviderProtocol,
                                      error: AMError?,
                                      completion: @escaping AMNetworkCompletionHandler<U?>) {
        serviceProvider.parseAndValidate(data, responseType: U.self, error: error) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let responseError):
                    completion(.failure(responseError))
                }
            }
        }
    }
}
