//
//  NnExecutableManager.swift
//  
//
//  Created by Nikolai Nobadi on 6/21/24.
//

import Files
import SwiftShell
import Foundation
import SwiftPicker

public struct NnExecutableManager {
    private let picker: SwiftPicker
    private let defaults: UserDefaults
    
    public init(picker: SwiftPicker = .init(), defaults: UserDefaults = .standard) {
        self.picker = picker
        self.defaults = defaults
    }
}


// MARK: - Actions
public extension NnExecutableManager {
    func manageExecutable(buildType: BuildType) throws {
        let destination = try loadDestination()
        let projectFolder = try loadCurrentFolderWithExecutable()
        
        try buildProject(project: projectFolder, buildType: buildType)
        
        guard let executableFile = try? fetchExecutable(buildType: buildType, projectFolder: projectFolder) else {
            throw NnExecutableError.fetchFailure
        }
        
        try copyExecutableFile(executableFile, projectName: projectFolder.name, destination: destination)
    }
}


// MARK: - Private Methods
private extension NnExecutableManager {
    func loadDestination() throws -> String {
        if let path = defaults.string(forKey: .destinationKey), !path.isEmpty {
            return path
        }
        
        let path = try picker.getRequiredInput("Enter the path to the folder where you want your tools to reside.")
        
        defaults.set(path, forKey: .destinationKey)
        
        guard let path = defaults.string(forKey: .destinationKey), !path.isEmpty else {
            throw NnExecutableError.cannotCreateBuild
        }
        
        return path
    }
    
    func loadCurrentFolderWithExecutable() throws -> ProjectFolder {
        let folder = Folder.current
        
        if folder.containsFile(named: "Package.swift") {
            return .init(folder: folder, type: .package)
        }
        
        if folder.subfolders.filter({ $0.extension == "xcodeproj" }).count > 0 {
            return .init(folder: folder, type: .project)
        }
        
        throw NnExecutableError.cannotCreateBuild
    }
    
    func buildProject(project: ProjectFolder, buildType: BuildType) throws {
        let buildCommand = try makeBuildCommand(for: project, buildType: buildType)
        
        try runAndPrint(bash: buildCommand)
    }
    
    func makeBuildCommand(for project: ProjectFolder, buildType: BuildType) throws -> String {
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
    
    func selectScheme(_ path: String) -> String? {
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
    
    func fetchExecutable(buildType: BuildType, projectFolder: ProjectFolder) throws -> File? {
        let projectName = projectFolder.name
        
        guard let buildFolder = try? projectFolder.folder.subfolder(at: ".build/\(buildType.rawValue)") else {
            print("unable to locate build folder for project at path", projectFolder.path)
            return nil
        }
    
        return buildFolder.files.first(where: { $0.nameExcludingExtension.contains("\(projectName)") && $0.extension == nil })
    }
    
    func copyExecutableFile(_ file: File, projectName: String, destination: String) throws {
        let nnToolsFolder = try Folder(path: destination)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: projectName)
        
        if projectFolder.containsFile(named: file.name) {
            print("Deleting old executable to replace with latest build...")
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
        
        print("Successfully managed executable for \(projectName)")
    }
}

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
