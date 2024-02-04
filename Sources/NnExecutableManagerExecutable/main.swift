//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import Files
import ArgumentParser
import NnExecutableManager

fileprivate let nnToolsPath = "/Users/nelix/nnTools"

struct MainCommand: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Utility to manage and copy Swift project executables into nnTools directory.")
    
    @Option(name: [.customLong("exec"), .customShort("e")], help: "Specify 'debug' or 'release' to copy the corresponding executable.")
    var buildConfiguration: String
    
    func validate() throws {
        guard buildConfiguration == "debug" || buildConfiguration == "release" else {
            throw ValidationError("Invalid build configuration: \(buildConfiguration). Use 'debug' or 'release'.")
        }
    }
    
    func run() throws {
        let currentFolderName = Folder.current.name
        let nnToolsFolder = try Folder(path: nnToolsPath)
        let projectFolder = try nnToolsFolder.createSubfolderIfNeeded(withName: currentFolderName)
        
        guard let executableFile = try fetchExecutable(folderName: currentFolderName) else {
            print("Executable not found. Make sure to build the project first.")
            return
        }
        
        try copyExecutable(file: executableFile, to: projectFolder)
    }
    
    func fetchExecutable(folderName: String) throws -> File? {
        let buildFolder = try Folder.current.subfolder(at: ".build/\(buildConfiguration)")
    
        return buildFolder.files.first(where: { $0.nameExcludingExtension.contains("\(folderName)") && $0.extension == nil })
    }
    
    func copyExecutable(file: File, to projectFolder: Folder) throws {
        if projectFolder.containsFile(named: file.name) {
            try projectFolder.file(named: file.name).delete()
        }
        
        try file.copy(to: projectFolder)
        
        print("Successfully copied \(buildConfiguration) executable to \(projectFolder.path)/\(file.name)")
    }
}
