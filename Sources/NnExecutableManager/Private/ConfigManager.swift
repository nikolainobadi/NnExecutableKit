//
//  ConfigManager.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import NnConfigKit

struct ConfigManager {
    let configGen: NnConfigManager<NnExConfig>
    
    init() {
        self.configGen = .init(projectName: "NnExecutableManager")
    }
}


// MARK: - Config
extension ConfigManager {
    func loadConfig() throws {
//        config = try configGen.loadConfig()
    }
    
    func createDefaultConfig() throws {
//        config = .defaultConfig
//        try configGen.saveConfig(config)
    }
}
