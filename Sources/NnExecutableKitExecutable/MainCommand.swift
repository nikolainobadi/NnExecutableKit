//
//  MainCommand.swift
//
//
//  Created by Nikolai Nobadi on 2/26/24.
//

import ArgumentParser
import NnExecutableKit

struct MainCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Utility to manage and copy Swift project executables into a more convenient directory.",
        subcommands: [
            Move.self,
            SetPath.self, DeletePath.self, PrintPath.self
        ]
    )
}


// MARK: - Default Command: Manage Executables
struct Move: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Build an executable file and move it to a pre-defined directory")
    
    @Flag(help: "Select build type: -d for Debug, -r for Release.")
    var buildType: BuildType = .release

    func run() throws {
        try ExecutableManager().manageExecutable(buildType: buildType)
    }
}


// MARK: - SetPath
struct SetPath: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Set the destination path for executables.")

    @Argument(help: "Path to the destination folder.")
    var path: String?

    func run() throws {
//        try ExecutableManager().setPath(path)
    }
}


// MARK: - DeletePath
struct DeletePath: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Delete the saved destination path.")

    func run() throws {
//        ExecutableManager().deletePath()
    }
}


// MARK: - PrintPath
struct PrintPath: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Print the saved destination path.")

    func run() throws {
//        ExecutableManager().printPath()
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
