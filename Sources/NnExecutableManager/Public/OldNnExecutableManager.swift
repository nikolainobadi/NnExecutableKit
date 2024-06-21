// The Swift Programming Language
// https://docs.swift.org/swift-book

public enum OldNnExecutableManager {
    private static let fileManager = NnFilesManager.self
    private static let buildManager = BuildManager.self
    private static let configManager = ConfigManager.self
}


// MARK: - Config
public extension OldNnExecutableManager {
    static func loadConfig() throws {
//        do {
//            try configManager.loadConfig()
//        } catch {
//            if configManager.noConfig {
//                print("Couldn't find config file, creating default.")
//                try configManager.createDefaultConfig()
//            }
//        }
    }
}


// MARK: - Executable
public extension OldNnExecutableManager {
    static func manageExecutable(buildConfiguration: BuildType, at path: String? = nil) throws {
        let folder = fileManager.currentFolder

        guard try fileManager.folderCanBuildExecutable(folder) else {
            throw NnExecutableError.cannotCreateBuild
        }
        
        try buildManager.buildProject(buildType: buildConfiguration, path: folder.path)
        
        guard let executableFile = try? fileManager.fetchExecutable(buildType: buildConfiguration, projectFolder: folder) else {
            throw NnExecutableError.fetchFailure
        }
        
//        try fileManager.copyExecutableFile(executableFile, to: folder, config: configManager.config)
    }
}
