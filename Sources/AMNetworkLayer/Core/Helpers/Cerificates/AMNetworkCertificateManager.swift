//
//  AMNetworkCertificateManager.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

class AMNetworkCertificateManager: NSObject {
    
    private var certificatesData: [Data]
    private var isEnabled: Bool
    
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
    
       
        if !isEnabled {
            if let trust = challenge.protectionSpace.serverTrust {
                completionHandler(.performDefaultHandling, URLCredential(trust: trust))
//                completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: trust))
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
