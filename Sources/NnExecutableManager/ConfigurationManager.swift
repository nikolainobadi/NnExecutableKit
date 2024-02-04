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
            let decoder = JSONDecoder()
            configuration = try decoder.decode(Configuration.self, from: Data(data))
        } catch {
            print("Failed to load or decode configuration, using default. Error: \(error)")
            configuration = defaultConfiguration
            // Optionally, save the default configuration to the file for future reference
            // saveConfiguration()
        }
    }
    
    static func saveConfiguration() {
        guard let configuration = configuration else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(configuration)
            if let folder = try? Folder(path: "\(Folder.home.path).config/NnExecutableManager"),
               let _ = try? folder.createFileIfNeeded(withName: "config.json", contents: data) {
                print("Configuration saved successfully.")
            } else {
                print("Failed to save configuration: Folder not found or inaccessible.")
            }
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
