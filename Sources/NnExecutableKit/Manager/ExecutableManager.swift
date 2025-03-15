//
//  ExecutableManager.swift
//  
//
//  Created by Nikolai Nobadi on 6/21/24.
//

import Files
import Foundation

public struct ExecutableManager {
    private let key: String
    private let defaults: UserDefaults
    private let currentFolderPath: String?
    private let projectBuilder: ProjectBuilder
    
    init(key: String = "", defaults: UserDefaults = .standard, currentFolderPath: String?, projectBuilder: ProjectBuilder) {
        self.key = key
        self.defaults = defaults
        self.currentFolderPath = currentFolderPath
        self.projectBuilder = projectBuilder
    }
}


// MARK: - Init
public extension ExecutableManager {
    init() {
        self.init(currentFolderPath: nil, projectBuilder: DefaultProjectBuilder())
    }
}


// MARK: - Actions
public extension ExecutableManager {
    func setPath(path: String) throws {
        if path.isEmpty {
            throw ExecutableError.missingToolPath
        }
        
        defaults.set(path, forKey: key)
    }
    
    func deletePath() {
        defaults.removeObject(forKey: key)
    }
    
    func printPath() {
        guard let path = try? loadDestination() else {
            print("No Destination path set")
            return
        }
        
        print("Current Destination:", path)
    }
    
    func manageExecutable(buildType: BuildType) throws {
        let destination = try loadDestination()
        let currentFolder = try getCurrentFolder()
        let projectType = try getProjectType(of: currentFolder)

        try projectBuilder.buildProject(name: currentFolder.name, path: currentFolder.path, projectType: projectType, buildType: buildType)

        guard let file = try? fetchExecutableFilePath(buildType: buildType, folder: currentFolder) else {
            throw ExecutableError.fetchFailure
        }

        try copyExecutableFile(file, projectName: currentFolder.name, destination: destination)
    }
}


// MARK: - Private Methods
private extension ExecutableManager {
    func getCurrentFolder() throws -> Folder {
        guard let currentFolderPath else {
            return Folder.current
        }
        
        return try Folder(path: currentFolderPath)
    }
    
    func getProjectType(of folder: Folder) throws -> ProjectType {
        if folder.containsFile(named: "Package.swift") {
            return .package
        }
        
        if folder.subfolders.contains(where: { $0.extension == "xcodeproj" }) {
            return .project
        }
        
        throw ExecutableError.missingProjectType
    }
    
    func loadDestination() throws -> String {
        guard let path = defaults.string(forKey: key), !path.isEmpty else {
            print("Missing Path (use 'set-path' to set the destination for your executables)")
            throw ExecutableError.missingToolPath
        }
        
        return path
    }

    func fetchExecutableFilePath(buildType: BuildType, folder: Folder) throws -> File? {
        guard let buildFolder = try? folder.subfolder(named: ".build/\(buildType.rawValue)") else {
            return nil
        }

        return buildFolder.files.map({ $0 }).first(where: { $0.nameExcludingExtension.contains(folder.name) && $0.extension == nil })
    }

    func copyExecutableFile(_ file: File, projectName: String, destination: String) throws {
        let toolsFolder = try Folder(path: destination)
        let projectFolder = try toolsFolder.createSubfolderIfNeeded(withName: projectName)

        if projectFolder.containsFile(named: file.name) {
            print("Deleting old executable to replace with latest build...")
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
        
        print("Successfully managed executable for \(projectName)")
    }
}


// MARK: - Dependencies
public protocol ProjectBuilder {
    func buildProject(name: String, path: String, projectType: ProjectType, buildType: BuildType) throws
}
