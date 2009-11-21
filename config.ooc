// Default Values

Config: class {

    suiteEnding := ".woot"
    oocEnding   :static String = ".ooc"
    outEnding   := ".output"
    compiler := "ooc"
    testDir := "tests/"   
    
    getTestDir: func() -> String {
        testDir
    }

    getCompiler: func() -> String {
        compiler
    }

}

