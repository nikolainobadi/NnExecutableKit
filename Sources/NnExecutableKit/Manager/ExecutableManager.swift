//
//  ExecutableManager.swift
//  
//
//  Created by Nikolai Nobadi on 6/21/24.
//

import Files
import SwiftShell
import Foundation
import SwiftPicker

//public struct ExecutableManager {
//    private let picker: SwiftPicker
//    private let defaults: UserDefaults
//    
//    public init(picker: SwiftPicker = .init(), defaults: UserDefaults = .standard) {
//        self.picker = picker
//        self.defaults = defaults
//    }
//}
//
//
//// MARK: - Actions
//public extension ExecutableManager {
//    func manageExecutable(buildType: BuildType) throws {
//        let destination = try loadDestination()
//        let projectFolder = try loadCurrentFolderWithExecutable()
//        
//        try buildProject(project: projectFolder, buildType: buildType)
//        
//        guard let executableFile = try? fetchExecutable(buildType: buildType, projectFolder: projectFolder) else {
//            throw NnExecutableError.fetchFailure
//        }
//        
//        try copyExecutableFile(executableFile, projectName: projectFolder.name, destination: destination)
//    }
//}
//
//
//// MARK: - Private Methods
//private extension ExecutableManager {
//    func loadDestination() throws -> String {
//        if let path = defaults.string(forKey: .destinationKey), !path.isEmpty {
//            return path
//        }
//        
//        let path = try picker.getRequiredInput("Enter the path to the folder where you want your tools to reside.")
//        
//        defaults.set(path, forKey: .destinationKey)
//        
//        guard let path = defaults.string(forKey: .destinationKey), !path.isEmpty else {
//            throw NnExecutableError.cannotCreateBuild
//        }
//        
//        return path
//    }
//    
//    func loadCurrentFolderWithExecutable() throws -> ProjectFolder {
//        let folder = Folder.current
//        
//        if folder.containsFile(named: "Package.swift") {
//            return .init(folder: folder, type: .package)
//        }
//        
//        if folder.subfolders.filter({ $0.extension == "xcodeproj" }).count > 0 {
//            return .init(folder: folder, type: .project)
//        }
//        
//        throw NnExecutableError.cannotCreateBuild
//    }
//    
//    func buildProject(project: ProjectFolder, buildType: BuildType) throws {
//        let buildCommand = try makeBuildCommand(for: project, buildType: buildType)
//        
//        try runAndPrint(bash: buildCommand)
//    }
//    
//    func makeBuildCommand(for project: ProjectFolder, buildType: BuildType) throws -> String {
//        switch project.type {
//        case .package:
//            return "swift build -c \(buildType.rawValue)"
//        case .project:
//            guard let scheme = selectScheme("\(project.path)\(project.name).xcodeproj") else {
//                throw NnExecutableError.missingScheme
//            }
//            
//            return "xcodebuild -scheme \(scheme) -configuration \(buildType.rawValue) SYMROOT=$(PWD)/.build"
//        }
//    }
//    
//    func selectScheme(_ path: String) -> String? {
//        let output = run(bash: "xcodebuild -list -project \(path)").stdout
//        var schemes = [String]()
//        var schemesSection = false
//        
//        for line in output.split(separator: "\n") {
//            if line.contains("Schemes:") {
//                schemesSection = true
//                continue
//            }
//            if schemesSection {
//                if line.trimmingCharacters(in: .whitespaces).isEmpty {
//                    break
//                }
//                schemes.append(line.trimmingCharacters(in: .whitespaces))
//            }
//        }
//        
//        return schemes.first
//    }
//    
//    func fetchExecutable(buildType: BuildType, projectFolder: ProjectFolder) throws -> File? {
//        let projectName = projectFolder.name
//        
//        guard let buildFolder = try? projectFolder.folder.subfolder(at: ".build/\(buildType.rawValue)") else {
//            print("unable to locate build folder for project at path", projectFolder.path)
//            return nil
//        }
//    
//        return buildFolder.files.first(where: { $0.nameExcludingExtension.contains("\(projectName)") && $0.extension == nil })
//    }
//    
//    func copyExecutableFile(_ file: File, projectName: String, destination: String) throws {
//        let nnToolsFolder = try Folder(path: destination)
//        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: projectName)
//        
//        if projectFolder.containsFile(named: file.name) {
//            print("Deleting old executable to replace with latest build...")
//            try projectFolder.file(named: file.name).delete()
//        }
//        
//        try file.copy(to: projectFolder)
//        
//        print("Successfully managed executable for \(projectName)")
//    }
//}

struct ProjectFolder {
    let folder: Folder
    let type: ProjectType
    
    var name: String {
        return folder.name
    }
    
    var path: String {
        return folder.path
    }
}

enum ProjectType {
    case package, project
}

extension String {
    static var destinationKey: String {
        return "destinationKey"
    }
}

protocol PathStore {
    func getDestinationPath() -> String?
    func setDestinationPath(_ path: String)
}

struct UserDefaultsPathStore: PathStore {
    private let defaults: UserDefaults
    private let key = "destinationKey"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func getDestinationPath() -> String? {
        return defaults.string(forKey: key)
    }
    
    func setDestinationPath(_ path: String) {
        defaults.set(path, forKey: key)
    }
}

protocol FolderHandler {
    func getCurrentFolder() throws -> ProjectFolder
    func getSubfolder(named: String, in folder: ProjectFolder) throws -> Folder
    func getFiles(in folder: Folder) -> [File]
    func createSubfolderIfNeeded(named: String, in folder: Folder) throws -> Folder
    func copyFile(_ file: File, to destination: Folder) throws
}

struct DefaultFolderHandler: FolderHandler {
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
}

protocol ProjectBuilder {
    func build(project: ProjectFolder, buildType: BuildType) throws
}

struct DefaultProjectBuilder: ProjectBuilder {
    func build(project: ProjectFolder, buildType: BuildType) throws {
        let buildCommand = try makeBuildCommand(for: project, buildType: buildType)
        try runAndPrint(bash: buildCommand)
    }
    
    private func makeBuildCommand(for project: ProjectFolder, buildType: BuildType) throws -> String {
        switch project.type {
        case .package:
            return "swift build -c \(buildType.rawValue)"
        case .project:
            guard let scheme = selectScheme("\(project.path)\(project.name).xcodeproj") else {
                throw NnExecutableError.missingScheme
            }
            return "xcodebuild -scheme \(scheme) -configuration \(buildType.rawValue) SYMROOT=$(PWD)/.build"
        }
    }

    private func selectScheme(_ path: String) -> String? {
        let output = run(bash: "xcodebuild -list -project \(path)").stdout
        var schemes = [String]()
        var schemesSection = false
        
        for line in output.split(separator: "\n") {
            if line.contains("Schemes:") {
                schemesSection = true
                continue
            }
            if schemesSection {
                if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    break
                }
                schemes.append(line.trimmingCharacters(in: .whitespaces))
            }
        }
        return schemes.first
    }
}

public struct ExecutableManager {
    private let pathStore: PathStore
    private let folderHandler: FolderHandler
    private let projectBuilder: ProjectBuilder

    init(pathStore: PathStore, folderHandler: FolderHandler, projectBuilder: ProjectBuilder) {
        self.pathStore = pathStore
        self.folderHandler = folderHandler
        self.projectBuilder = projectBuilder
    }
}

public extension ExecutableManager {
    init() {
        self.init(pathStore: UserDefaultsPathStore(), folderHandler: DefaultFolderHandler(), projectBuilder: DefaultProjectBuilder())
    }
}

// MARK: - Actions
public extension ExecutableManager {
    func manageExecutable(buildType: BuildType) throws {
        let destination = try loadDestination()
        let projectFolder = try folderHandler.getCurrentFolder()

        try projectBuilder.build(project: projectFolder, buildType: buildType)

        guard let executableFile = try? fetchExecutable(buildType: buildType, projectFolder: projectFolder) else {
            throw NnExecutableError.fetchFailure
        }

        try copyExecutableFile(executableFile, projectName: projectFolder.name, destination: destination)
    }
}

// MARK: - Private Methods
private extension ExecutableManager {
    func loadDestination() throws -> String {
        guard let path = pathStore.getDestinationPath(), !path.isEmpty else {
            print("Missing Path (use 'set-path' to set the destination for your executables)")
            throw NnExecutableError.missingToolPath
        }
        
        return path
    }

    func fetchExecutable(buildType: BuildType, projectFolder: ProjectFolder) throws -> File? {
        let buildFolder = try? folderHandler.getSubfolder(named: ".build/\(buildType.rawValue)", in: projectFolder)
        guard let buildFolder = buildFolder else { return nil }

        return folderHandler.getFiles(in: buildFolder).first {
            $0.nameExcludingExtension.contains(projectFolder.name) && $0.extension == nil
        }
    }

    func copyExecutableFile(_ file: File, projectName: String, destination: String) throws {
        let nnToolsFolder = try Folder(path: destination)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: projectName)

        try folderHandler.copyFile(file, to: projectFolder)
        print("Successfully managed executable for \(projectName)")
    }
}
