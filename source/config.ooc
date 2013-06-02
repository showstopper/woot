use gifnooc

import gifnooc/Entity
import gifnooc/entities/[INI, Fixed]


Settings: class {
    
    oocEnding: static String = ".ooc"
    outEnding: static String = ".out"
    suiteEnding: static String = ".wt" 
    defSuite: static String = "suite" + suiteEnding
    
    readSize: static Int = 1000 // For StringBuffer
    depth: static Int = 25 // walk depth for findOOCFiles   
    
    SUCCESS     :static Int = 0 // everything compiled fine
    C_FAIL      :static Int = 1 // the ooc-compiler failed
    B_FAIL      :static Int = 2 // the backend-compiler failed

    defaults: FixedEntity

    init: func() {
        defaults = FixedEntity new(null)
        defaults addValue("Settings.Compiler", "ooc").addValue("Settings.CompilerBackend", "gcc")
        defaults addValue("Settings.CompilerStat", SUCCESS).addValue("Settings.TestDir", ".")
    }

    getConfigger: func~withSuite(confFile: String) -> Entity {
        return INIEntity new(defaults, confFile)
    }
    
    getConfigger: func() -> Entity {
        return defaults
    }
}


