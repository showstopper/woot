// Default Values

Config: class {

    suiteEnding := ".woot"
    oocEnding   :static String = ".ooc"
    outEnding   :static String = ".out"
    compiler := "ooc"
    compilerBackend := "gcc"
    testDir := "tests/"
    readSize :static Int = 1000 // For StringBuffer   
    
    init: func(){}
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

