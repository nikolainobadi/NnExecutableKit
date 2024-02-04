//
//  FileCopier.swift
//
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files

enum FileCopier {
    static func copyExecutable(file: File, to projectFolder: Folder) throws {
        if projectFolder.containsFile(named: file.name) {
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
    }
}
