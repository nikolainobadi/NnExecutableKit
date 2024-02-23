// The Swift Programming Language
// https://docs.swift.org/swift-book

import Files
import Foundation
import SwiftPickerCLI

public enum NnExecutableManager {
    private static let copier = FileCopier.self
    private static let picker = SwiftPickerCLI.self
    private static let buildManager = BuildManager.self
    private static let fetcher = ExecutableFetcher.self
    private static let detector = ProjectTypeDetector.self
    private static let configManager = ConfigurationManager.self
}


// MARK: - Executable
public extension NnExecutableManager {
    static func manageExecutable(buildConfiguration: BuildType, at path: String? = nil) throws {
        configManager.loadConfiguration()
        let config = configManager.getCurrentConfiguration()
        let folder = Folder.current

        guard try detector.directoryCanBuildExecutable(folder) else {
            throw NnExecutableError.cannotCreateBuild
        }
        
        try buildManager.buildProject(buildType: buildConfiguration, in: folder)
        
        guard let executableFile = try? fetcher.fetchExecutable(buildType: buildConfiguration) else {
            throw NnExecutableError.fetchFailure
        }
        
        try copyExecutableFile(executableFile, to: folder, config: config)
    }
}


// MARK: - Private Methods
private extension NnExecutableManager {
    static func copyExecutableFile(_ file: File, to folder: Folder, config: Configuration) throws {
        let nnToolsFolder = try Folder(path: config.nnToolsPath)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: folder.name)
        try copier.copyExecutable(file: file, to: projectFolder)
        
        print("Successfully managed executable for \(folder.name)")
    }
    
    static func shouldBuildExecutable() -> Bool {
        return picker.getPermission(title: "No executable exists yet for this project. Would you like to build one?", clearScreenBeforeDisplayingList: true)
    }
}
