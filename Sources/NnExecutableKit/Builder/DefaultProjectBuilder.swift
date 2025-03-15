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
            return "swift build -c \(buildType.rawValue)"
        case .project:
            guard let scheme = selectScheme("\(path)\(name).xcodeproj") else {
                throw ExecutableError.missingScheme
            }
            return "xcodebuild -scheme \(scheme) -configuration \(buildType.rawValue) SYMROOT=$(PWD)/.build"
        }
    }

    func selectScheme(_ path: String) -> String? {
        let output = run(bash: "xcodebuild -list -project \(path)").stdout
        var schemes = [String]()
        var schemesSection = false
        
        for line in output.split(separator: "\n") {
            if line.contains("Schemes:") {
                schemesSection = true
                continue
            }
            if schemesSection {
                if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    break
                }
                schemes.append(line.trimmingCharacters(in: .whitespaces))
            }
        }
        return schemes.first
    }
}
