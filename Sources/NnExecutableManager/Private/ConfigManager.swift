//
//  ConfigManager.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import NnConfigGen

enum ConfigManager {
    private static let configGen = NnConfigGen.self
    
    static var config: NnExConfig = .init()
    static var noConfig: Bool {
        return config.nnToolsPath.isEmpty
    }
}


// MARK: - Config
extension ConfigManager {
    static func loadConfig() throws {
        config = try configGen.loadConfig(projectName: config.projectName)
    }
    
    static func createDefaultConfig() throws {
        config = .defaultConfig
        try configGen.saveConfig(config: config)
    }
}


// MARK: - Extension Dependencies
extension NnExConfig: NnConfig {
    public var projectName: String {
        return "NnExecutableManager"
    }
}
