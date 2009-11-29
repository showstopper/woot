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
    init: func(fName: String, fpath: String) {
        fileName = fName
        path = fpath
        stripped = this stripEnding(fileName, ".ooc")
        outName = path + File separator + stripped + ".out"
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
            buf := StringBuffer new(Config readSize)
            i := 0
            while (fr hasNext() && i < Config readSize) { 
                buf append(fr read())
                i+=1
            }
            return buf toString()
        } else {
            return ""
        }
    }

    compile: func(compiler: String, cBackend: String) -> Int {
        args := ArrayList<String> new()
        args add(compiler).add(this relativePath()) 
        args add("-o=%s" format(this relativeBinaryPath()))
        args add("-%s" format(cBackend))
        SubProcess new(args) execute()
    }
    
    execute: func() -> ExecuteResult {
        
        args := ArrayList<String> new()
        args add(this relativeBinaryPath())
        proc := SubProcess new(args) 
        myPipe := Pipe new()
        proc setStdout(myPipe)
        ret := proc execute()
        a := PipeReader new(myPipe)
        buf := StringBuffer new(Config readSize)
        i := 0
        while (a hasNext() && i< Config readSize) { 
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
}


findOOCFiles: func(path: String, oocList: ArrayList<OocFile>, depth: Int) -> ArrayList<OocFile> {
    if (!depth) {
        return oocList
    } 
    currentDir := File new(path)
    files :ArrayList<String>
    files = currentDir getChildrenNames()
    
    for(item: String in files) {
        if (item endsWith(".ooc")) {
            oocList add(OocFile new(item, path))
        }
        if (File new(path + File separator + item) isDir()) {
            oocList = findOOCFiles(path + File separator + item, oocList, depth-1)
        }
    }
    return oocList
}

compareOutput: func(s1: String, s2: String) -> Bool {
    s1 == s2[0..s2 length()-1] // s2 always contains another null-byte, needs a fix 
}

coloredOutput: func(s: String) {
    Terminal setFgColor(Color red)
    s print()
    Terminal reset()
}


printResult: func (res: Result) {
    coloredOutput("[FILE] ")
    (res oocFile path + File separator + res oocFile fileName) println()
   
    match res compilerRetVal {
        case 0 => coloredOutput("[COMPILED]\n")
        case 1 => coloredOutput("[OOC-ERROR]\n")
        case 2 => coloredOutput("[BACKEND-ERROR]\n")
    }
    
    if (res hasSpecOutput()) {
        coloredOutput("[SPECIFIED OUTPUT] ")
        res getSpecOutput() println()
        
        coloredOutput("[OUTPUT] ")
        res output print()
    
        if (!res getCompareResult()) {
            coloredOutput("[PASSED]\n\n")
        } else {
            coloredOutput("[FAILED]\n\n")   
        }
    }
}

checkFiles: func(config: Config, path: String, files: ArrayList<OocFile>) -> ArrayList<Result> {
    results := ArrayList<Result> new()
    for (item: OocFile in files) {
        res := Result new(item)
        res compilerRetVal = (item compile(config getCompiler(), config getCompilerBackend()))
        res setProgResult(item execute())
        results add(res)
    }        
    return results
}

main: func() {
    config := Config new()
    path := config getTestDir()
    files := findOOCFiles(path, ArrayList<OocFile> new(), Config depth) 
    "" println() // newline
    a := checkFiles(config, path, files)
    for (res: Result in a) {
        printResult(res)
    }
}

