//
//  ExecutableManagerCommand.swift
//  
//
//  Created by Nikolai Nobadi on 2/26/24.
//

import ArgumentParser
import NnExecutableKit

struct ExecutableManagerCommand: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Utility to manage and copy Swift project executables into a more convenient directory.")
    
    @Flag(help: "Select build type: -d for Debug, -r for Release.")
    var buildType: BuildType = .release
    
    func run() throws {
        try NnExecutableManager().manageExecutable(buildType: buildType)
    }
}


// MARK: - Extension Dependencies
extension BuildType: EnumerableFlag {
    public static func name(for value: BuildType) -> NameSpecification {
        switch value {
        case .debug:
            return [.customShort("d")]
        case .release:
            return [.customShort("r")]
        }
    }
}
