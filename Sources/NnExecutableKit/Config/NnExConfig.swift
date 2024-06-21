//
//  NnExConfig.swift
//  
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files

public struct NnExConfig: Codable {
    public var nnToolsPath: String

    public init(nnToolsPath: String = "") {
        self.nnToolsPath = nnToolsPath
    }
}


// MARK: - Default
extension NnExConfig {
    static var defaultConfig: NnExConfig {
        return .init(nnToolsPath: "\(Folder.home.path)nnTools")
    }
}
