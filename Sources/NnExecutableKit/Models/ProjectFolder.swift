//
//  ProjectFolder.swift
//  NnExecutableKit
//
//  Created by Nikolai Nobadi on 3/15/25.
//

import Files

struct ProjectFolder {
    let folder: Folder
    let type: ProjectType
}

extension ProjectFolder {
    var name: String {
        return folder.name
    }
    
    var path: String {
        return folder.path
    }
}
