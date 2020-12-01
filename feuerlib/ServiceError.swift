//
//  ServiceError.swift
//  feuerlib
//
//  Created by Jannik Feuerhahn on 01.12.20.
//

import Foundation

public enum ServiceError: Error {
    case badUrl
    case noNetwork
    case noData
    case parserError
    case couldNotWrite
    case wrongFiletype
}

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badUrl:
            return "Bad URL"
        case .noNetwork:
            return "No network connection"
        case .noData:
            return "No data found"
        case .parserError:
            return "Couldn't parse data"
        case .couldNotWrite:
            return "Couldn't write to file"
        case .wrongFiletype:
            return "Wrong filetype"
        }
    }
}


