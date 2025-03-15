//
//  NnExecutableError.swift
//
//
//  Created by Nikolai Nobadi on 2/22/24.
//

public enum NnExecutableError: Error {
    case missingToolPath
    case cannotCreateBuild
    case fetchFailure
    case missingScheme
}
