//
//  ProjectTypeDetector.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files

enum ProjectTypeDetector {
    static func directoryCanBuildExecutable(_ folder: Folder = .current) throws -> Bool {
        if folder.containsFile(named: "Package.swift") {
            return true
        }
        
        if folder.files.filter({ $0.extension == "xcodeproj" }).count > 0 {
            return true
        }
        
        return false
    }
}
