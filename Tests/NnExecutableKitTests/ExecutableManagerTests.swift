//
//  ExecutableManagerTests.swift
//  NnExecutableKitTests
//
//  Created by Nikolai Nobadi on 3/14/25.
//

import Files
import XCTest
@testable import NnExecutableKit

final class ExecutableManagerTests: XCTestCase {
    private var tempFolder: Folder!

    override func setUp() {
        super.setUp()
        tempFolder = try? Folder.temporary.createSubfolderIfNeeded(withName: "TestProject")
    }

    override func tearDown() {
        super.tearDown()
        if let tempFolder = tempFolder {
            deleteFolderContents(tempFolder)
            
            try? tempFolder.delete()
        }
        
        tempFolder = nil
    }
}


// MARK: - Unit Tests
extension ExecutableManagerTests {
    func test_starting_values_are_empty() {
        let (_, builder) = makeSUT(currentFolderPath: nil)
        
        XCTAssertNil(builder.name)
        XCTAssertNil(builder.path)
        XCTAssertNil(builder.buildType)
        XCTAssertNil(builder.projectType)
    }
    
    func test_fails_if_no_destination_path_is_set() {
        let (sut, _) = makeSUT(testPath: nil, currentFolderPath: nil) // No folder path set

        XCTAssertThrowsError(try sut.manageExecutable(buildType: .release)) { error in
            XCTAssertEqual(error as? ExecutableError, ExecutableError.missingToolPath)
        }
    }
    
    func test_fails_if_no_project_type_is_found_in_current_folder() throws {
        try tempFolder!.createSubfolderIfNeeded(withName: ".build/release") // No executables

        let (sut, _) = makeSUT(currentFolderPath: tempFolder!.path)

        XCTAssertThrowsError(try sut.manageExecutable(buildType: .release)) { error in
            XCTAssertEqual(error as? ExecutableError, ExecutableError.missingProjectType)
        }
    }
    
    func test_fails_if_the_build_process_encounters_an_error() throws {
        let (sut, _) = makeSUT(currentFolderPath: tempFolder!.path, shouldThrowError: true)
        
        try tempFolder!.createFile(at: "Package.swift")

        XCTAssertThrowsError(try sut.manageExecutable(buildType: .release)) { error in
            XCTAssertEqual(error as? ExecutableError, ExecutableError.cannotCreateBuild)
        }
    }

    func test_fails_if_no_executable_is_found_after_building() throws {
        try tempFolder!.createSubfolderIfNeeded(withName: ".build/release") // No executables

        let (sut, _) = makeSUT(currentFolderPath: tempFolder!.path)
        
        try tempFolder!.createFile(at: "Package.swift")

        XCTAssertThrowsError(try sut.manageExecutable(buildType: .release)) { error in
            XCTAssertEqual(error as? ExecutableError, ExecutableError.fetchFailure)
        }
    }
    
    func test_builds_swift_packages_and_moves_executable_when_everything_is_set_up_correctly() throws {
        let tempFolder = try Folder.temporary.createSubfolderIfNeeded(withName: "TestProject")
        let buildFolder = try tempFolder.createSubfolderIfNeeded(withName: ".build/release")
        let (sut, builder) = makeSUT(currentFolderPath: tempFolder.path)
        
        try tempFolder.createFile(at: "Package.swift")
        try buildFolder.createFile(named: "TestProject")
        try sut.manageExecutable(buildType: .release)

        XCTAssertNotNil(builder.name)
        XCTAssertNotNil(builder.path)
        XCTAssertNotNil(builder.buildType)
        XCTAssertEqual(builder.projectType, .package)
    }
    
    func test_builds_xcode_projects_and_moves_executable_when_everything_is_set_up_correctly() throws {
        let tempFolder = try Folder.temporary.createSubfolderIfNeeded(withName: "TestProject")
        let buildFolder = try tempFolder.createSubfolderIfNeeded(withName: ".build/release")
        let (sut, builder) = makeSUT(currentFolderPath: tempFolder.path)
        
        try tempFolder.createSubfolder(named: "TestApp.xcodeproj")
        try buildFolder.createFile(named: "TestProject")
        try sut.manageExecutable(buildType: .release)

        XCTAssertNotNil(builder.name)
        XCTAssertNotNil(builder.path)
        XCTAssertNotNil(builder.buildType)
        XCTAssertEqual(builder.projectType, .project)
    }
}


// MARK: - SUT
private extension ExecutableManagerTests {
    func makeSUT(testKey: String = "testKey", testPath: String? = Folder.temporary.path, currentFolderPath: String?, shouldThrowError: Bool = false) -> (sut: ExecutableManager, projectBuilder: MockProjectBuilder) {
        let testSuiteName = "com.nikolainobadi.executableManagerTests"
        let userDefaults = UserDefaults(suiteName: testSuiteName)!
        userDefaults.removePersistentDomain(forName: testSuiteName) // Ensure a clean state
        
        if let testPath {
            userDefaults.set(testPath, forKey: testKey)
        }

        let projectBuilder = MockProjectBuilder(shouldThrowError: shouldThrowError)
        let sut = ExecutableManager(key: testKey, defaults: userDefaults, currentFolderPath: currentFolderPath, projectBuilder: projectBuilder)

        return (sut, projectBuilder)
    }
    
    func makeDefaults() -> UserDefaults {
        let testSuiteName = "com.nikolainobadi.executableManagerTests"
        let userDefaults = UserDefaults(suiteName: testSuiteName)!
        userDefaults.removePersistentDomain(forName: testSuiteName)
        
        return userDefaults
        
    }
}


// MARK: - Helper Classes
extension ExecutableManagerTests {
    final class MockProjectBuilder: ProjectBuilder {
        private let shouldThrowError: Bool
        
        private(set) var name: String?
        private(set) var path: String?
        private(set) var buildType: BuildType?
        private(set) var projectType: ProjectType?
        
        init(shouldThrowError: Bool = false) {
            self.shouldThrowError = shouldThrowError
        }

        func buildProject(name: String, path: String, projectType: ProjectType, buildType: BuildType) throws {
            if shouldThrowError { throw ExecutableError.cannotCreateBuild }
            
            self.name = name
            self.path = path
            self.buildType = buildType
            self.projectType = projectType
        }
    }
}


// MARK: - Helpers
private extension ExecutableManagerTests {
    func deleteFolderContents(_ folder: Folder) {
        for file in folder.files {
            try? file.delete()
        }
        
        for subfolder in folder.subfolders {
            deleteFolderContents(subfolder)
            try? subfolder.delete()
        }
    }
}
