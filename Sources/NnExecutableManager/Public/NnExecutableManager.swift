// The Swift Programming Language
// https://docs.swift.org/swift-book

import Files
import Foundation

public enum NnExecutableManager {
    private static let copier = FileCopier.self
    private static let buildManager = BuildManager.self
    private static let fetcher = ExecutableFetcher.self
    private static let detector = ProjectTypeDetector.self
    private static let configManager = ConfigManager.self
}


// MARK: - Config
public extension NnExecutableManager {
    static func loadConfig() throws {
        do {
            try configManager.loadConfig()
        } catch {
            if configManager.noConfig {
                print("Couldn't find config file, creating default.")
                try configManager.createDefaultConfig()
            }
        }
    }
}


// MARK: - Executable
public extension NnExecutableManager {
    static func manageExecutable(buildConfiguration: BuildType, at path: String? = nil) throws {
        let folder = Folder.current

        guard try detector.directoryCanBuildExecutable(folder) else {
            throw NnExecutableError.cannotCreateBuild
        }
        
        try buildManager.buildProject(buildType: buildConfiguration, path: path ?? folder.path)
        
        guard let executableFile = try? fetcher.fetchExecutable(buildType: buildConfiguration) else {
            throw NnExecutableError.fetchFailure
        }
        
        try copyExecutableFile(executableFile, to: folder, config: configManager.config)
    }
}


// MARK: - Private Methods
private extension NnExecutableManager {
    static func copyExecutableFile(_ file: File, to folder: Folder, config: NnExConfig) throws {
        let nnToolsFolder = try Folder(path: config.nnToolsPath)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: folder.name)
        try copier.copyExecutable(file: file, to: projectFolder)
        
        print("Successfully managed executable for \(folder.name)")
    }
}
