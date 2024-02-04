//
//  main.swift
//  
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import ArgumentParser
import NnExecutableManager

struct MainCommand: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Utility to manage and copy Swift project executables into nnTools directory.")
    
    @Option(name: [.customLong("exec"), .customShort("e")], help: "Specify 'debug' or 'release' to copy the corresponding executable.")
    var buildConfiguration: String
    
    @Option(name: [.customLong("path"), .customShort("p")], help: "Optional path to the project directory.")
        var path: String?
    
    func validate() throws {
        guard buildConfiguration == "debug" || buildConfiguration == "release" else {
            throw ValidationError("Invalid build configuration: \(buildConfiguration). Use 'debug' or 'release'.")
        }
    }
    
    func run() throws {
        let buildType = BuildType(rawValue: buildConfiguration) ?? .debug
        
        try NnExecutableManager.manageExecutable(buildConfiguration: buildType, at: path)
    }
}

MainCommand.main()
