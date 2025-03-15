//
//  DefaultProjectBuilder.swift
//  NnExecutableKit
//
//  Created by Nikolai Nobadi on 3/15/25.
//

import SwiftShell

struct DefaultProjectBuilder: ProjectBuilder {
    func build(project: ProjectFolder, buildType: BuildType) throws {
        let buildCommand = try makeBuildCommand(for: project, buildType: buildType)
        
        try runAndPrint(bash: buildCommand)
    }
}


// MARK: - Builder
private extension DefaultProjectBuilder {
    func makeBuildCommand(for project: ProjectFolder, buildType: BuildType) throws -> String {
        switch project.type {
        case .package:
            return "swift build -c \(buildType.rawValue)"
        case .project:
            guard let scheme = selectScheme("\(project.path)\(project.name).xcodeproj") else {
                throw NnExecutableError.missingScheme
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
