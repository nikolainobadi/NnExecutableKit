//
//  BuildType.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

public enum BuildType: String {
    case debug, release
    
    public init?(type: String?) {
        guard let type = type, let instance = BuildType(rawValue: type) else { return nil }
        
        self = instance
    }
}
