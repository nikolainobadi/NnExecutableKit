//
//  BuildManager.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files
import SwiftShell

enum BuildManager {
    static func buildProject(buildType: BuildType, in directory: Folder? = nil) throws {
        let buildCommand = "swift build -c \(buildType.rawValue)"
        let finalCommand = directory != nil ? "\(buildCommand) --package-path '\(directory!.path)'" : buildCommand
        
        print("preparing to build project with command:", finalCommand)
        
        try runAndPrint(bash: finalCommand)
        
        print("project has build successfully")
    }
}
