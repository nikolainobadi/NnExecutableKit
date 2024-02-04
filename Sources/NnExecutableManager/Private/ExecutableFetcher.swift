//
//  ExecutableFetcher.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files

enum ExecutableFetcher {
    static func fetchExecutable(buildType: BuildType) throws -> File? {
        let projectFolder = Folder.current
        let projectName = projectFolder.name
        
        guard let buildFolder = try? projectFolder.subfolder(at: ".build/\(buildType.rawValue)") else {
            print("unable to locate build folder for project at path", projectFolder.path)
            return nil
        }
        
        return buildFolder.files.first(where: { $0.nameExcludingExtension.contains("\(projectName)") && $0.extension == nil })
    }
}


// MARK: - Private Methods
private extension ExecutableFetcher {
    static func determineBuildFolderPath(buildType: BuildType) -> String {
        return Folder.current.path
    }
}
