use deadlogger
 
import io/[File,FileReader]
import os/[Pipe,PipeReader,Process,Terminal]
import structs/ArrayList
import text/StringBuffer
import deadlogger/[Log, Handler, Level, Formatter, Filter]
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
    
    init: func(fName: String, fpath: String, =sets, defConf: Config, loggy: Log) {
        fileName = fName
        path = fpath
        
        stripped = this stripEnding(path, Settings oocEnding) 
        //outName = path + File separator + stripped + Settings outEnding
        outName = stripped + Settings outEnding
        //suiteName = path + File separator + stripped + Settings suiteEnding
        suiteName = stripped + Settings suiteEnding
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
        fileName  println()
        args add(config getCompiler()).add(fileName)//.add(this relativePath()) 
        args add("-o=%s" format(stripped))
        args add("-%s" format(config getCompilerBackend()))
        ("\n" + fileName + " " + config getCompilerBackend()+ "\n") println()
        myPipe := Pipe new()

        proc := SubProcess new(args) 
        proc setStdout(myPipe).setStderr(myPipe) // make the compiler stfu!!
        proc execute()
    }
    
    execute: func() -> ExecuteResult {
        
        args := ArrayList<String> new()
        args add(stripped)
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
        oocFile config getCompilerStat() == compilerRetVal
    }
}


findOOCFiles: func(path: String, oocList: ArrayList<OocFile>, sets: Settings, defConfig: Config, depth: Int, loggy: Log) -> ArrayList<OocFile> {
    if (!depth) {
        return oocList
    } 
    currentDir := File new(path)
    files :ArrayList<File>
    files = currentDir getChildren()
    for(item in files) {
        if (item path endsWith(".ooc")) {
            oocList add(OocFile new(item path, path, sets, defConfig, loggy))
        }
        if (item isDir()) {
            oocList = findOOCFiles(item path, oocList, sets, defConfig, depth-1, loggy)
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
    res oocFile fileName println()
    // + File separator + res oocFile fileName) println()
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
        res getSpecOutput() println()
        coloredOutput("[OUTPUT] ")
        res output println()
    
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
    conf: Config
    file := FileHandler new("woot.log")
    file setFormatter(NiceFormatter new("{{level}}: {{msg}}"))
    Log root attachHandler(file)
    logger := Log getLogger("main")
    if (File new(Settings defSuite) isFile()) {
        logger info("Suite-File found")
        conf = sets getConfigger(Settings defSuite)
    } else {
        conf = sets getConfigger()
    }
    path := conf getTestDir()
    files := findOOCFiles(path, ArrayList<OocFile> new(), sets, conf, sets depth, logger) 
    "" println() // newline
    a := checkFiles(path, files)
    printf("%daaaa\n", a size())
    for (res: Result in a) {
        printResult(res)
    }
}

