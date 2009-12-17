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
        defaults := FixedEntity new(null)
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

/*
    dict put("compiler","ooc").put("compilerBackend","gcc").put("testDir", ".").put("compilerStat", SUCCESS toString())
        allowedCBackends add("tcc").add("gcc").add("icc").add("clang")
*/

/*
use oocini
import io/File
import structs/[HashMap,ArrayList]
import oocini/INI

cloneHashMap: func (hmap: HashMap<String>) -> HashMap<String> {
    clone := HashMap<String> new()
    for (a: String in hmap keys) {
        clone put(a, hmap get(a))
    }
    return clone
}

Settings: class {

/*
oocEnding
outEnding
readSize
depth
suiteFile
compile-status

    
    oocEnding: static String = ".ooc"
    outEnding: static String = ".out"
    suiteEnding: static String = ".wt" 
    defSuite: static String = "suite" + suiteEnding
    
    readSize: static Int = 1000 // For StringBuffer
    depth: static Int = 25 // walk depth for findOOCFiles   
    
    dict: HashMap<String>
    
    SUCCESS     :static Int = 0 // everything compiled fine
    C_FAIL      :static Int = 1 // the ooc-compiler failed
    B_FAIL      :static Int = 2 // the backend-compiler failed
    
    allowedCBackends: ArrayList<String>

    init: func() {
        dict = HashMap<String> new()
        allowedCBackends = ArrayList<String> new()
        dict put("compiler","ooc").put("compilerBackend","gcc").put("testDir", ".").put("compilerStat", SUCCESS toString())
        allowedCBackends add("tcc").add("gcc").add("icc").add("clang")
    }      
    
    getConfigger: func ~withSuite(confFile: String) -> Config {
        return Config new(confFile, cloneHashMap(dict))
    }
    getConfigger: func() -> Config {
        return Config new(cloneHashMap(dict))
    }
}

Config: class {

    sets: HashMap<String>
    ini: INI
    init: func ~withSuite(confFile: String, =sets) {
        if (File new(confFile) isFile()) {
            ini = INI new(confFile)
            sets = parseINIFile(ini, sets)
        }
    }
    init: func(=sets) {}
 
    parseINIFile: func (iniObj: INI, dict: HashMap<String>) -> HashMap<String> {
        ini setCurrentSection("general")
        for (key: String in sets keys) {
            dict put(key, ini getEntry(key, sets get(key))) 
        }
        return sets
    }
    
    getTestDir: func() -> String {
       sets get("testDir") 
    }

    getCompiler: func() -> String {
       sets get("compiler")     
    }

    getCompilerBackend: func() -> String {
        sets get("compilerBackend")
    }

    getOutput: func() -> String {
        sets get("output")
    }

    getCompilerStat: func() -> Int {
        sets get("compilerStat") toInt()
    }
}
*/
