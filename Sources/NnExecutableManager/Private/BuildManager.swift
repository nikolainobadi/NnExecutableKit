//
//  BuildManager.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import SwiftShell

enum BuildManager {
    // MARK: - TODO -> make use of path arg
    static func buildProject(buildType: BuildType, path: String) throws {
        let buildCommand = "swift build -c \(buildType.rawValue)"
        print("preparing to build project for \(buildType.rawValue)")
        try runAndPrint(bash: buildCommand)
        print("project has build successfully")
    }
    
//    static func buildProject(buildType: BuildType, in directory: Folder? = nil) throws {
//        let buildCommand = "swift build -c \(buildType.rawValue)"
//        let finalCommand = directory != nil ? "\(buildCommand) --package-path '\(directory!.path)'" : buildCommand
//        
//        print("preparing to build project for \(buildType.rawValue)")
//        
//        try runAndPrint(bash: finalCommand)
//        
//        print("project has build successfully")
//    }
}
