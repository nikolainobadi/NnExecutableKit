//
//  DefaultProjectBuilder.swift
//  NnExecutableKit
//
//  Created by Nikolai Nobadi on 3/15/25.
//

import SwiftShell

struct DefaultProjectBuilder: ProjectBuilder {
    func buildProject(name: String, path: String, projectType: ProjectType, buildType: BuildType) throws {
        let buildCommand = try makeBuildCommand(name: name, path: path, projectType: projectType, buildType: buildType)
        
        try runAndPrint(bash: buildCommand)
    }
}


// MARK: - Builder
private extension DefaultProjectBuilder {
    func makeBuildCommand(name: String, path: String, projectType: ProjectType, buildType: BuildType) throws -> String {
        switch projectType {
        case .package:
            return "swift build -c \(buildType.rawValue) --arch arm64 --arch x86_64"
        case .project:
            guard let scheme = selectScheme("\(path)\(name).xcodeproj") else {
                throw ExecutableError.missingScheme
            }
            
            print("using scheme \(scheme) to create \(buildType.rawValue) build", terminator: "\n\n")
            return "xcodebuild -scheme \(scheme) -configuration \(buildType.rawValue) SYMROOT=$(PWD)/.build -quiet"
        }
    }

    func selectScheme(_ path: String) -> String? {
        print("Selecting project scheme...")
        let output = run(bash: "xcodebuild -list -project \(path)").stdout
        let lines = output.split(separator: "\n")
        guard let startIndex = lines.firstIndex(where: { $0.contains("Schemes:") }) else { return nil }
        
        return lines[(startIndex + 1)...].first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }?.trimmingCharacters(in: .whitespaces)
    }
}
