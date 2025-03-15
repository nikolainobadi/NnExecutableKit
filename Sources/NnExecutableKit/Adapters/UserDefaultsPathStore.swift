//
//  UserDefaultsPathStore.swift
//  NnExecutableKit
//
//  Created by Nikolai Nobadi on 3/15/25.
//

import Foundation

struct UserDefaultsPathStore {
    private let key: String
    private let defaults: UserDefaults
    
    init(key: String = "destinationKey", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }
}


// MARK: - Store
extension UserDefaultsPathStore: PathStore {
    func getDestinationPath() -> String? {
        return defaults.string(forKey: key)
    }
    
    func setDestinationPath(_ path: String) {
        defaults.set(path, forKey: key)
    }
}
