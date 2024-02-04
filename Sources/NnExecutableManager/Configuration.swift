//
//  Configuration.swift
//  
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Foundation

public struct Configuration: Codable {
    public var nnToolsPath: String
    public var buildConfiguration: String

    public init(nnToolsPath: String, buildConfiguration: String) {
        self.nnToolsPath = nnToolsPath
        self.buildConfiguration = buildConfiguration
    }
}
