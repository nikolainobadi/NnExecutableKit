//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 6/21/24.
//

import Files
import SwiftShell

public struct NnExecutableManager {
    let store: ConfigStore
}


// MARK: - Init
public extension NnExecutableManager {
    init() {
        self.init(store: ConfigStoreAdapter())
    }
}


// MARK: - Actions
public extension NnExecutableManager {
    func manageExecutable(buildType: BuildType) throws {
        let config = try loadConfig()
        let projectFolder = try loadCurrentFolderWithExecutable()
        
        try buildProject(buildType: buildType, path: projectFolder.path)
        
        guard let executableFile = try? fetchExecutable(buildType: buildType, projectFolder: projectFolder) else {
            throw NnExecutableError.fetchFailure
        }
        
        try copyExecutableFile(executableFile, projectName: projectFolder.name, config: config)
    }
}


// MARK: - Private Methods
private extension NnExecutableManager {
    func loadConfig() throws -> NnExConfig {
        do {
            return try store.loadConfig()
        } catch {
            fatalError()
        }
    }
    
    func loadCurrentFolderWithExecutable() throws -> Folder {
        let folder = Folder.current
        if folder.containsFile(named: "Package.swift") {
            return folder
        }
        
        if folder.files.filter({ $0.extension == "xcodeproj" }).count > 0 {
            return folder
        }
        
        throw NnExecutableError.cannotCreateBuild
    }
    
    func buildProject(buildType: BuildType, path: String) throws {
        let buildCommand = "swift build -c \(buildType.rawValue)"
        print("preparing to build project for \(buildType.rawValue)")
        try runAndPrint(bash: buildCommand)
        print("project has build successfully")
    }
    
    func fetchExecutable(buildType: BuildType, projectFolder: Folder) throws -> File? {
        let projectName = projectFolder.name
        
        guard let buildFolder = try? projectFolder.subfolder(at: ".build/\(buildType.rawValue)") else {
            print("unable to locate build folder for project at path", projectFolder.path)
            return nil
        }
        
        return buildFolder.files.first(where: { $0.nameExcludingExtension.contains("\(projectName)") && $0.extension == nil })
    }
    
    func copyExecutableFile(_ file: File, projectName: String, config: NnExConfig) throws {
        let nnToolsFolder = try Folder(path: config.nnToolsPath)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: projectName)
        
        if projectFolder.containsFile(named: file.name) {
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
        
        print("Successfully managed executable for \(projectName)")
    }
}


// MARK: - Dependencies
protocol ConfigStore {
    func loadConfig() throws -> NnExConfig
    func saveConfig(_ config: NnExConfig) throws
}
