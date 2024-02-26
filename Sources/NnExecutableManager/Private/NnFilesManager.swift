//
//  NnFilesManager.swift
//
//
//  Created by Nikolai Nobadi on 2/26/24.
//

import Files

enum NnFilesManager {
    static var currentFolder: Folder {
        return Folder.current
    }
    
    static func folderCanBuildExecutable(_ folder: Folder = .current) throws -> Bool {
        if folder.containsFile(named: "Package.swift") {
            return true
        }
        
        if folder.files.filter({ $0.extension == "xcodeproj" }).count > 0 {
            return true
        }
        
        return false
    }
    
    static func fetchExecutable(buildType: BuildType, projectFolder: Folder) throws -> File? {
        let projectName = projectFolder.name
        
        guard let buildFolder = try? projectFolder.subfolder(at: ".build/\(buildType.rawValue)") else {
            print("unable to locate build folder for project at path", projectFolder.path)
            return nil
        }
        
        return buildFolder.files.first(where: { $0.nameExcludingExtension.contains("\(projectName)") && $0.extension == nil })
    }
    
    static func copyExecutableFile(_ file: File, to folder: Folder, config: NnExConfig) throws {
        let nnToolsFolder = try Folder(path: config.nnToolsPath)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: folder.name)
        try copyExecutable(file: file, to: projectFolder)
        
        print("Successfully managed executable for \(folder.name)")
    }
}


// MARK: - Private Methods
private extension NnFilesManager {
    static func copyExecutable(file: File, to projectFolder: Folder) throws {
        if projectFolder.containsFile(named: file.name) {
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
    }
}
