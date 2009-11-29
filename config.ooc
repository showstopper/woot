use oocini
import io/File
import structs/[HashMap,ArrayList]
import INI

Config: class {
    
    oocEnding   :static String = ".ooc"
    outEnding   :static String = ".out"
    readSize    :static Int = 1000 // For StringBuffer
    depth       :static Int = 25 // walk depth for findOOCFiles   
    dict        :HashMap<String>
    
    ini        : INI = null
    init: func() {
        dict = HashMap<String> new()
        dict put("compiler","ooc").put("compilerBackend","gcc").put("testDir", "tests/").put("suiteFile","suite.wt")
        if (File new(dict get("suiteFile")) isFile()) {
            ini = INI new(dict get("suiteFile"))
            dict =  parseINIFile(ini, dict)
        }
    }      
    parseINIFile: func (iniObj: INI, dict: HashMap<String>) -> HashMap<String> {
        ini setCurrentSection("general")
        for (key: String in dict keys) {
            dict put(key, ini getEntry(key, dict get(key))) 
        }
        return dict
    }

    getTestDir: func() -> String {
       dict get("testDir") 
    }

    getCompiler: func() -> String {
       dict get("compiler")     
    }

    getCompilerBackend: func() -> String {
        dict get("compilerBackend")
    }

    
}

