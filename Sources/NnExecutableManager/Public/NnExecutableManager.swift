// The Swift Programming Language
// https://docs.swift.org/swift-book

import Files
import Foundation
import SwiftPickerCLI

public enum NnExecutableManager {
    private static let fetchLimit = 2
    private static var fetchCount = 0
}


// MARK: - Executable
public extension NnExecutableManager {
    static func manageExecutable(buildConfiguration: BuildType, at path: String? = nil) throws {
        fetchCount = 0
        ConfigurationManager.loadConfiguration()
        let config = ConfigurationManager.getCurrentConfiguration()
        let folder = try path.flatMap { try Folder(path: $0) } ?? Folder.current

        guard try ProjectTypeDetector.directoryCanBuildExecutable(folder) else {
            throw NSError(domain: "NnExecutableManagerError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Directory cannot build an executable."])
        }
        
        print("preparing to fetch executable and copy")
    
        try fetchAndCopyExecutable(to: folder, config: config, buildType: buildConfiguration, buildFolderPath: path)
    }
}


// MARK: - Private Methods
private extension NnExecutableManager {
    static func fetchAndCopyExecutable(to folder: Folder, config: Configuration, buildType: BuildType, buildFolderPath: String?) throws {
        guard fetchCount < fetchLimit else {
            throw NSError(domain: "NnExecutableManagerError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch executable after \(fetchLimit) attempts."])
        }
        
        if let executableFile = try? ExecutableFetcher.fetchExecutable(buildType: buildType) {
            try copyExecutableFile(executableFile, to: folder, config: config)
            fetchCount = 0
        } else {
            guard shouldBuildExecutable() else {
                throw NSError(domain: "NnExecutableManagerError", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Executable build was cancelled by the user."])
            }
                
            try BuildManager.buildProject(buildType: buildType, in: folder)
            fetchCount += 1
            try fetchAndCopyExecutable(to: folder, config: config, buildType: buildType, buildFolderPath: buildFolderPath)
        }
    }
    
    static func copyExecutableFile(_ file: File, to folder: Folder, config: Configuration) throws {
        let nnToolsFolder = try Folder(path: config.nnToolsPath)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: folder.name)
        try FileCopier.copyExecutable(file: file, to: projectFolder)
        
        print("Successfully managed executable for \(folder.name)")
    }
    
    static func shouldBuildExecutable() -> Bool {
        return SwiftPickerCLI.getPermission(title: "No executable exists yet for this project. Would you like to build one?", clearScreenBeforeDisplayingList: true)
    }
}
