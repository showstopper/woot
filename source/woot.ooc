use gifnooc
use deadlogger

import io/[File,FileReader]
import os/[Pipe,PipeReader,Process,Terminal]
import structs/ArrayList
import lang/Buffer
import deadlogger/[Log, Handler, Level, Formatter, Filter, Logger]
import config
import gifnooc/Entity

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
    config: Entity
    loggy: Logger 
    init: func(fName: String, fpath: String, =sets, defConf: Entity, =loggy) {
        fileName = fName
        path = fpath
        loggy info("Created new OocFile "+fileName)
        stripped = stripEnding(fileName, Settings oocEnding) 
        outName = stripped + Settings outEnding
        suiteName = stripped + Settings suiteEnding
        if (hasSuite()) {
            loggy info(fileName + "has info")
            config = sets getConfigger(suiteName)
        } else {
            loggy info(fileName + "has no info")
            config = defConf
        }
    }

    stripEnding: func(fileName: String, ending: String) -> String {
        fileName[0..fileName length() - ending length()]
    }

    hasOutput: func() -> Bool {
        return File new(outName) isFile()
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
    
    hasSuite: func() -> Bool {
        return File new(suiteName) isFile()
    } 
    
    compile: func() -> Int {
        args := ArrayList<String> new()
        loggy info(fileName + " compile")
        args add(config getOption("Settings.Compiler", String)).add(fileName)
        args add("-o=%s" format(stripped))
        args add("-%s" format(config getOption("Settings.CompilerBackend", String)))
	    proc := Process new(args) 
	    return proc execute()
    }

    execute: func() -> ExecuteResult {

        args := ArrayList<String> new()
        args add(stripped)
        proc := Process new(args) 
        ret := proc execute() // return value of the process
        buf := proc getOutput() // output of the process
        return ExecuteResult new(ret, buf)

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
            return specOutput == output
        } else {
            return false // default value
        }
    }
    
    checkCompilerRetVal: func() -> Bool {
        oocFile config getOption("Settings.CompilerStat", Int) == compilerRetVal
    }
}


findOOCFiles: func(path: String, oocList: ArrayList<OocFile>, sets: Settings, defConfig: Entity, depth: Int, loggy: Logger) -> ArrayList<OocFile> {
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
    if (res checkCompilerRetVal()) {
        coloredOutput("[COMPILE-SUCESS] ") 
    } else {
        coloredOutput("[COMPILE-FAIL] ")
    }
    match (res compilerRetVal) {
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

checkFiles: func(files: ArrayList<OocFile>) -> ArrayList<Result> {
    results := ArrayList<Result> new()
    for (item in files) {
        res := Result new(item)//item)
        res compilerRetVal = item compile()
        if (res compilerRetVal == Settings SUCCESS) {
            res setProgResult(item execute())
        }
        results add(res)
    }        
    return results
}

main: func() {
    sets := Settings new()
    conf: Entity
    file := FileHandler new("session.log")
    file setFormatter(NiceFormatter new("{{level}}: {{msg}}"))
    Log root attachHandler(file)
    logger := Log getLogger("main")
    if (File new(Settings defSuite) isFile()) {
        logger info("Suite-File found")
        conf = sets getConfigger(Settings defSuite)
    } else {
        conf = sets getConfigger()
    }
    path := conf getOption("Settings.TestDir", String)
    files := findOOCFiles(path, ArrayList<OocFile> new(), sets, conf, sets depth, logger) 
    a: ArrayList<Result>
    a = checkFiles(files)
    for (res: Result in a) {
        printResult(res)
    }
}

