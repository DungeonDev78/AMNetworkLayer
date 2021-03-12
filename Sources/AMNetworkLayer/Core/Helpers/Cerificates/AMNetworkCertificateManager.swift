//
//  AMNetworkCertificateManager.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

class AMNetworkCertificateManager: NSObject {
    
    // MARK: - Properties
    private var certificatesData: [Data]
    private var isEnabled: Bool
    
    // MARK: - Initialization
    /// The init of the certificate manager. It takes a list of certificates in the form of AMCertificateModel and a bool that states if the pinning is enabled or not. It can be useful to disable it in any desired environment
    /// - Parameters:
    ///   - certificates: an array of AMCertificateModel
    ///   - isEnabled: the bool that activates the manager or not
    init(certificates: [AMCertificateModel], isEnabled: Bool) {
        self.certificatesData = certificates.map{ $0.convertToData() }
        self.isEnabled = isEnabled
        super.init()
    }
}

// MARK: - URLSessionDelegate (PINNING)
extension AMNetworkCertificateManager: URLSessionDelegate {
 
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
       // If not enabled, always secure connection
        if !isEnabled {
            if let trust = challenge.protectionSpace.serverTrust {
                completionHandler(.performDefaultHandling, URLCredential(trust: trust))
                return
            }
        }
            
        if let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 {
            // Iterate over the list of received certs and try to find our certificate
            for index in 0...(SecTrustGetCertificateCount(trust)-1) {
                if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                    let data = SecCertificateCopyData(certificate) as Data
                    if certificatesData.contains(data) {
                        // Found, go on
                        completionHandler(.performDefaultHandling, URLCredential(trust: trust))
                        return
                    }
                }
            }
        }
        
        // If fails / not found, stop everything
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
