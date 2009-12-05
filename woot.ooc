import io/[File,FileReader]
import os/[Pipe,PipeReader,Process,Terminal]
import structs/ArrayList
import text/StringBuffer
import config

ExecuteResult: cover {
    retVal: Int
    output: String

    new: static func(.retVal, .output) -> This {
        this: This
        this retVal = retVal
        this output = output
        return this
    }
}

OocFile: class {

    stripped: String
    fileName: String
    path: String
    outName: String
    suiteName: String
    shouldFail: Int
    sets: Settings
    config: Config
    
    init: func(fName: String, fpath: String, =sets, defConf: Config) {
        fileName = fName
        path = fpath
        
        stripped = this stripEnding(fileName, Settings oocEnding) 
        outName = path + File separator + stripped + Settings outEnding
        suiteName = path + File separator + stripped + Settings suiteEnding
        if (hasSuite()) {
            config = sets getConfigger(suiteName)
        } else {
            config = defConf
        }
    }

    stripEnding: func(fileName: String, ending: String) -> String {
        fileName[0..fileName length() - ending length()]
    }
    
    hasOutput: func() -> Bool {
        return File new(outName) isFile()
    }

    hasSuite: func() -> Bool {
        return File new(suiteName) isFile()
    } 
    
    getOutput: func() -> String {
       if (hasOutput()) {
           fr  := FileReader new(outName)
           buf := StringBuffer new(Settings readSize)
           i := 0
           while (fr hasNext() && i < Settings readSize) { 
               buf append(fr read())
               i+=1
           }
           return buf toString()
        } else {
            return ""
        }
    }

    compile: func() -> Int {
        args := ArrayList<String> new()
        args add(config getCompiler()).add(this relativePath()) 
        args add("-o=%s" format(this relativeBinaryPath()))
        args add("-%s" format(config getCompilerBackend()))
        ("\n" + fileName + " " + config getCompilerBackend()+ "\n") println()
        SubProcess new(args) execute()
    }
    
    execute: func() -> ExecuteResult {
        
        args := ArrayList<String> new()
        args add(this relativeBinaryPath())
        proc := SubProcess new(args) 
        myPipe := Pipe new()
        proc setStdout(myPipe) // TODO: add pipe for stderr
        ret := proc execute()
        a := PipeReader new(myPipe)
        buf := StringBuffer new(Settings readSize)
        i := 0
        while (a hasNext() && i< Settings readSize) { 
            buf append(a read())
            i+=1 
        }
        result := ExecuteResult new(ret, buf toString())
        return result
    }   

    relativeBinaryPath: func() -> String {path + File separator + stripped}
    relativePath: func() -> String {path + File separator + fileName}
}

Result: class {

    oocFile: OocFile
    progRetVal: Int
    compilerRetVal: Int
    
    output: String
    specOutput: String
    specOutSet := false

    init: func(=oocFile) {
        specOutSet = hasSpecOutput()
    }

    setProgResult: func(r: ExecuteResult) {
        output = r output
        progRetVal = r retVal
    }
     
    getSpecOutput: func() -> String {
        
        if (specOutSet) { 
            specOutput = oocFile getOutput()
            return specOutput
        } else { // should never be reached 
            return ""
        }  
    }

    hasSpecOutput: func() -> Bool { // ALWAYS check before
        return oocFile hasOutput()
        
    }
    
    getCompareResult: func() -> Bool {
        if (specOutSet) {
            return compareOutput(specOutput, output)
        } else {
            return false // default value
        }
    }

    compareOutput: func(s1: String, s2: String) -> Bool {
        s1 == s2
    }

    checkCompilerRetVal: func() -> Bool {
        printf("%d %d\n",  oocFile config getCompilerStat(), compilerRetVal)
        oocFile config getCompilerStat() == compilerRetVal
    }
}


findOOCFiles: func(path: String, oocList: ArrayList<OocFile>, sets: Settings, defConfig: Config, depth: Int) -> ArrayList<OocFile> {
    if (!depth) {
        return oocList
    } 
    currentDir := File new(path)
    files :ArrayList<String>
    files = currentDir getChildrenNames()
    
    for(item: String in files) {
        if (item endsWith(".ooc")) {
            oocList add(OocFile new(item, path, sets, defConfig))
        }
        if (File new(path + File separator + item) isDir()) {
            oocList = findOOCFiles(path + File separator + item, oocList, sets, defConfig,  depth-1)
        }
    }
    return oocList
}


coloredOutput: func(s: String) {
    Terminal setFgColor(Color red)
    s print()
    Terminal reset()
}


printResult: func (res: Result) {
    coloredOutput("[FILE] ")
    (res oocFile path + File separator + res oocFile fileName) println()
    /*
    match res compilerRetVal {
        case 0 => coloredOutput("[COMPILED]\n")
        case 1 => coloredOutput("[OOC-ERROR]\n")
        case 2 => coloredOutput("[BACKEND-ERROR]\n")
    }
    */
    if (res checkCompilerRetVal()) {
        coloredOutput("[COMPILE-SUCESS] ") 
    } else {
        coloredOutput("[COMPILE-FAIL] ")
    }
    match res compilerRetVal {
        case 0 => coloredOutput("[NO ERROR]\n")
        case 1 => coloredOutput("[OOC ERROR]\n")
        case 2 => coloredOutput("[BACKEND ERROR]\n")
    }

    if (res hasSpecOutput()) {
        coloredOutput("[SPECIFIED OUTPUT] ")
        res getSpecOutput() print()
        coloredOutput("[OUTPUT] ")
        res output print()
    
        if (!res getCompareResult()) {
            coloredOutput("[PASSED]\n\n")
        } else {
            coloredOutput("[FAILED]\n\n")   
        }
    }
}

checkFiles: func(path: String, files: ArrayList<OocFile>) -> ArrayList<Result> {
    results := ArrayList<Result> new()
    for (item: OocFile in files) {
        res := Result new(item)
        res compilerRetVal = item compile()
        res setProgResult(item execute())
        results add(res)
    }        
    return results
}

main: func() {
    sets := Settings new()
    conf := sets getConfigger(Settings defSuite)
    path := conf getTestDir()
    files := findOOCFiles(path, ArrayList<OocFile> new(), sets, conf, sets depth) 
    "" println() // newline
    a := checkFiles(path, files)
    for (res: Result in a) {
        printResult(res)
    }
}

