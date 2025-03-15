//
//  DefaultFolderHandler.swift
//  NnExecutableKit
//
//  Created by Nikolai Nobadi on 3/15/25.
//

import Files

struct DefaultFolderHandler: FolderHandler {
    func getSubfolder(named: String, in folder: ProjectFolder) throws -> Folder {
        return try folder.folder.subfolder(at: named)
    }

    func getFiles(in folder: Folder) -> [File] {
        return folder.files.map({ $0 })
    }

    func createSubfolderIfNeeded(named: String, in folder: Folder) throws -> Folder {
        return try folder.createSubfolderIfNeeded(withName: named)
    }

    func copyFile(_ file: File, to destination: Folder) throws {
        try file.copy(to: destination)
    }
    
    func getCurrentFolder() throws -> ProjectFolder {
        let folder = Folder.current
        if folder.containsFile(named: "Package.swift") {
            return ProjectFolder(folder: folder, type: .package)
        }
        if folder.subfolders.contains(where: { $0.extension == "xcodeproj" }) {
            return ProjectFolder(folder: folder, type: .project)
        }
        throw NnExecutableError.cannotCreateBuild
    }
}
