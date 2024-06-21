//
//  ConfigStoreAdapter.swift
//  
//
//  Created by Nikolai Nobadi on 6/21/24.
//

import Foundation

final class ConfigStoreAdapter {
    
}


// MARK: - Store
extension ConfigStoreAdapter: ConfigStore {
    func loadConfig() throws -> NnExConfig {
        fatalError()
    }
    
    func saveConfig(_ config: NnExConfig) throws {
        
    }
}
