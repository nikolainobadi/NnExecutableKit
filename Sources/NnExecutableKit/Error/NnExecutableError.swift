//
//  NnExecutableError.swift
//
//
//  Created by Nikolai Nobadi on 2/22/24.
//

public enum NnExecutableError: Error {
    case cannotCreateBuild
    case fetchFailure
    case missingScheme
}

extension NnExecutableError {
    var message: String {
        switch self {
        case .cannotCreateBuild:
            return "Directory cannot build an executable."
        case .fetchFailure:
            return "Failed to fetch executable."
        case .missingScheme:
            return "Cannot find scheme for xcode project"
        }
    }
}
