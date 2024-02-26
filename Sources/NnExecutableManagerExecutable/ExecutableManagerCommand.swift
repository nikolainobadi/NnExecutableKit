//
//  ExecutableManagerCommand.swift
//  
//
//  Created by Nikolai Nobadi on 2/26/24.
//

import ArgumentParser
import NnExecutableManager

struct ExecutableManagerCommand: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Utility to manage and copy Swift project executables into nnTools directory.")
    
    @Option(name: [.customLong("exec"), .customShort("e")], help: "Specify 'debug' or 'release' to copy the corresponding executable.")
    var buildConfiguration: String?
    
    @Option(name: [.customLong("path"), .customShort("p")], help: "Optional path to the project directory.")
    var path: String?
    
    func run() throws {
        let buildType = BuildType(type: buildConfiguration) ?? .debug
        
        try NnExecutableManager.manageExecutable(buildConfiguration: buildType, at: path)
    }
}
