// Default Values

Config: class {

    suiteEnding := ".woot"
    oocEnding   :static String = ".ooc"
    outEnding   := ".output"
    compiler := "ooc"
    compilerBackend := "gcc"
    testDir := "tests/"   
    
    getTestDir: func() -> String {
        testDir
    }

    getCompiler: func() -> String {
        compiler
    }

    getCompilerBackend: func() -> String {
        compilerBackend
    }

}

