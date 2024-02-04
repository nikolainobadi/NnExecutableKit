//
//  ExecutableFetcher.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files

enum ExecutableFetcher {
    static func fetchExecutable(folderName: String, buildType: String, buildFolderPath: String? = nil) throws -> File? {
        let buildFolderPath = buildFolderPath ?? determineBuildFolderPath(buildType: buildType)
        let buildFolder = try? Folder(path: buildFolderPath)
        
        if buildFolder == nil {
            print("unable to locate build folder at path: \(buildFolderPath)")
            return nil
        }
        
        return buildFolder?.files.first(where: { $0.nameExcludingExtension.contains(folderName) && $0.extension == nil })
    }
}


// MARK: - Private Methods
private extension ExecutableFetcher {
    static func determineBuildFolderPath(buildType: String) -> String {
        return Folder.current.path + ".build/\(buildType)"
    }
}

