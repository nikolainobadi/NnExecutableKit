// The Swift Programming Language
// https://docs.swift.org/swift-book

import Files
import Foundation

public enum NnExecutableManager {
    static let defaultNnToolsPath = "/Users/nelix/nnTools"
    static var nnToolsPath = defaultNnToolsPath
    static var buildConfiguration = "debug" // Default value
}

public extension NnExecutableManager {
    static func configure(with config: Configuration) {
        nnToolsPath = config.nnToolsPath
        buildConfiguration = config.buildConfiguration
    }
    
    static func loadConfiguration(from jsonFilePath: String) throws {
        let file = try File(path: jsonFilePath)
        let data = try file.read()
        let decoder = JSONDecoder()
        let config = try decoder.decode(Configuration.self, from: Data(data))
        
        configure(with: config)
    }
}

public extension NnExecutableManager {
    static func fetchExecutable(projectName: String) throws -> File? {
        let buildFolderPath = ".build/\(buildConfiguration)"
        
        guard let buildFolder = try? Folder(path: buildFolderPath) else {
            print("could not find build folder")
            return nil
        }
        
        return buildFolder.files.first(where: {
            $0.nameExcludingExtension == projectName && $0.extension == nil
        })
    }
    
    static func copyExecutable(file: File, to projectFolder: Folder) throws {
        if projectFolder.containsFile(named: file.name) {
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
        
        print("Successfully copied \(buildConfiguration) executable to \(projectFolder.path)/\(file.name)")
    }
}


// MARK: - Dependencies
public struct Configuration: Codable {
    public var nnToolsPath: String
    public var buildConfiguration: String

    public init(nnToolsPath: String, buildConfiguration: String) {
        self.nnToolsPath = nnToolsPath
        self.buildConfiguration = buildConfiguration
    }
}
