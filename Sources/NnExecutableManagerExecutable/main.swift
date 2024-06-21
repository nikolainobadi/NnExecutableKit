//
//  main.swift
//  
//
//  Created by Nikolai Nobadi on 2/3/24.
//

import NnExecutableManager

do {
    try OldNnExecutableManager.loadConfig()
    ExecutableManagerCommand.main()
} catch {
    print("Unable to launch NnExecutableManager")
    print("error", error)
}
