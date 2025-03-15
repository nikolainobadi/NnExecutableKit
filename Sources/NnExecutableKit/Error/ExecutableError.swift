//
//  ExecutableError.swift
//
//
//  Created by Nikolai Nobadi on 2/22/24.
//

public enum ExecutableError: Error {
    case fetchFailure
    case missingScheme
    case missingToolPath
    case cannotCreateBuild
    case missingProjectType
}
