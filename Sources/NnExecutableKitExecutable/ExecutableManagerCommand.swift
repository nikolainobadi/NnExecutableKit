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
    
    @Option(name: [.customLong("exec"), .customShort("e")], help: "Specify 'debug' or 'release' to copy the corresponding executable.")
    var buildType: BuildType?
    
    func run() throws {
        try NnExecutableManager().manageExecutable(buildType: buildType)
    }
}


// MARK: - Extension Dependencies
extension BuildType: ExpressibleByArgument { }
