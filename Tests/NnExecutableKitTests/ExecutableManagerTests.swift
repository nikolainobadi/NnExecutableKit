//
//  ExecutableManagerTests.swift
//  NnExecutableKit
//
//  Created by Nikolai Nobadi on 3/14/25.
//

import Files
import Testing
@testable import NnExecutableKit

@Suite
struct ExecutableManagerTests {
    @Test
    func builds_the_project_and_moves_the_executable_when_everything_is_set_up_correctly() throws {
        let mockPathStore = MockPathStore(storedPath: Folder.temporary.path)
        let tempFolder = try Folder.temporary.createSubfolderIfNeeded(withName: "TestProject")
        let buildFolder = try tempFolder.createSubfolderIfNeeded(withName: ".build/release")
        let executableFile = try buildFolder.createFile(named: "TestProject")

        let mockFolderHandler = MockFolderHandler(
            simulatedProjectFolder: ProjectFolder(folder: tempFolder, type: .package),
            simulatedBuildFolder: buildFolder,
            simulatedFiles: [executableFile]
        )

        let mockProjectBuilder = MockProjectBuilder()
        let manager = ExecutableManager(
            pathStore: mockPathStore,
            folderHandler: mockFolderHandler,
            projectBuilder: mockProjectBuilder
        )

        try manager.manageExecutable(buildType: .release)

        #expect(mockProjectBuilder.buildCalled)
    }

    @Test
    func fails_if_no_destination_path_is_set() {
        let mockPathStore = MockPathStore(storedPath: nil)
        let mockFolderHandler = MockFolderHandler()
        let mockProjectBuilder = MockProjectBuilder()

        let manager = ExecutableManager(
            pathStore: mockPathStore,
            folderHandler: mockFolderHandler,
            projectBuilder: mockProjectBuilder
        )

        #expect(throws: NnExecutableError.missingToolPath) {
            try manager.manageExecutable(buildType: .release)
        }
    }

    @Test
    func fails_if_the_build_process_encounters_an_error() {
        let mockPathStore = MockPathStore(storedPath: try! Folder.home.subfolder(named: "Desktop").createSubfolderIfNeeded(withName: "NnExTests").path)
        let mockFolderHandler = MockFolderHandler(simulatedProjectFolder: ProjectFolder(folder: Folder.temporary, type: .package))
        var mockProjectBuilder = MockProjectBuilder(shouldThrowError: true)

        let manager = ExecutableManager(
            pathStore: mockPathStore,
            folderHandler: mockFolderHandler,
            projectBuilder: mockProjectBuilder
        )

        #expect(throws: NnExecutableError.cannotCreateBuild) {
            try manager.manageExecutable(buildType: .release)
        }
    }

    @Test
    func fails_if_no_executable_is_found_after_building() {
        let mockPathStore = MockPathStore(storedPath: "/mock/destination")
        let tempFolder = try! Folder.temporary.createSubfolderIfNeeded(withName: "TestProject")
        let buildFolder = try! tempFolder.createSubfolderIfNeeded(withName: ".build/release")

        let mockFolderHandler = MockFolderHandler(
            simulatedProjectFolder: ProjectFolder(folder: tempFolder, type: .package),
            simulatedBuildFolder: buildFolder,
            simulatedFiles: [] // No executables found
        )

        let mockProjectBuilder = MockProjectBuilder()

        let manager = ExecutableManager(
            pathStore: mockPathStore,
            folderHandler: mockFolderHandler,
            projectBuilder: mockProjectBuilder
        )

        #expect(throws: NnExecutableError.fetchFailure) {
            try manager.manageExecutable(buildType: .release)
        }
    }
}

// MARK: - Mock PathStore
final class MockPathStore: PathStore {
    private(set) var storedPath: String?
    
    init(storedPath: String? = nil) {
        self.storedPath = storedPath
    }

    func getDestinationPath() -> String? {
        return storedPath
    }
    
    func setDestinationPath(_ path: String) {
        storedPath = path
    }
}

// MARK: - Mock FolderHandler
struct MockFolderHandler: FolderHandler {
    var simulatedProjectFolder: ProjectFolder?
    var simulatedBuildFolder: Folder?
    var simulatedFiles: [File] = []
    var shouldThrowError = false

    func getCurrentFolder() throws -> ProjectFolder {
        if shouldThrowError { throw NnExecutableError.cannotCreateBuild }
        return simulatedProjectFolder!
    }

    func getSubfolder(named: String, in folder: ProjectFolder) throws -> Folder {
        if shouldThrowError { throw NnExecutableError.fetchFailure }
        return simulatedBuildFolder!
    }

    func getFiles(in folder: Folder) -> [File] { simulatedFiles }

    func createSubfolderIfNeeded(named: String, in folder: Folder) throws -> Folder {
        try folder.createSubfolderIfNeeded(withName: named)
    }

    func copyFile(_ file: File, to destination: Folder) throws {}
}

// MARK: - Mock ProjectBuilder
final class MockProjectBuilder: ProjectBuilder {
    private let shouldThrowError: Bool
    
    private(set) var buildCalled = false
    
    init(shouldThrowError: Bool = false) {
        self.shouldThrowError = shouldThrowError
    }

    func build(project: ProjectFolder, buildType: BuildType) throws {
        if shouldThrowError { throw NnExecutableError.cannotCreateBuild }
        buildCalled = true
    }
}
