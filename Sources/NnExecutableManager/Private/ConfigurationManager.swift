//
//  ConfigurationManager.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files
import Foundation

enum ConfigurationManager {
    private static var configuration: Configuration?
    private static let defaultConfiguration = Configuration(nnToolsPath: "/Users/nelix/nnTools", buildConfiguration: "debug")
    private static let configFilePath = "\(Folder.home.path).config/NnExecutableManager/config.json"
}


// MARK: -
extension ConfigurationManager {
    static func loadConfiguration() {
        do {
            let configFile = try File(path: configFilePath)
            let data = try configFile.read()
            
            configuration = try JSONDecoder().decode(Configuration.self, from: Data(data))
        } catch {
            print("Failed to load or decode configuration, using default. Error: \(error)")
            configuration = defaultConfiguration
            // Optionally, save the default configuration to the file for future reference
             saveConfiguration()
        }
    }
    
    static func saveConfiguration() {
        guard let configuration = configuration else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(configuration)
            let configFolder = try Folder.home.createSubfolderIfNeeded(withName: ".config")
            let nnConfigFolder = try configFolder.createSubfolderIfNeeded(withName: "NnExecutableManager")
            let _ = try? nnConfigFolder.createFileIfNeeded(withName: "config.json", contents: data) 
        } catch {
            print("Failed to encode or save configuration: \(error)")
        }
    }
    
    static func updateConfiguration(nnToolsPath: String? = nil, buildConfiguration: String? = nil) {
        if configuration == nil {
            loadConfiguration()
        }
        
        if let nnToolsPath = nnToolsPath {
            configuration?.nnToolsPath = nnToolsPath
        }
        
        if let buildConfiguration = buildConfiguration {
            configuration?.buildConfiguration = buildConfiguration
        }
        
        saveConfiguration()
    }
    
    static func getCurrentConfiguration() -> Configuration {
        if let configuration = configuration {
            return configuration
        } else {
            loadConfiguration()
            return configuration ?? defaultConfiguration
        }
    }
}
