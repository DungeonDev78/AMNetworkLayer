//
//  AMError.swift
//  AMNetworkLayer
//
//  Created by Alessandro Manilii on 11/03/2021.
//

import Foundation

public enum AMError: Error {
    case generic(code: Int? = nil)
    case reachability
    case timeOut
    case invalidCertificate
    case serialization
    case notFound
    case unauthorizedAccess
    case customUser(description: String, recovery: String = "", code: Int?)
}

// MARK: - Error Messages
extension AMError: LocalizedError {
    
    public var localizedDescription: String {
        switch self {
        case .generic(let code):
            var codeString = ""
            if let code = code { codeString =  " - Code \(code)" }
            return "*** Generic Error" + codeString + " ***"
        case .reachability:
            return "*** Reachability Error ***"
        case .timeOut:
            return "*** Timeout Error ***"
        case .invalidCertificate:
            return "*** Invalid Certificate Error ***"
        case .serialization:
            return "*** Serialization Error ***"
        case .notFound:
            return "*** 404 NotFound Error ***"
        case .unauthorizedAccess:
            return "*** 403 Unauthorized Access Error ***"
        case .customUser(let description, _, _):
            return description
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .customUser(_, let recovery, _):
            return recovery
        default:
            return "*** Recovery Suggestion ***"
        }
    }
}
