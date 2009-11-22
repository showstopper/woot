import io/[File,FileReader]
import os/[Pipe,PipeReader,Process]
import structs/ArrayList
import text/StringBuffer
import config

OocFile: class {

    stripped: String
    fileName: String
    path: String
    outName: String
    init: func(fName: String, fpath: String) {
        fileName = fName
        path = fpath
        stripped = this stripEnding(fileName, Config oocEnding)
        outName = path + File separator + stripped + Config outEnding
    }

    stripEnding: func(fileName: String, ending: String) -> String {
        return fileName substring(0, (fileName length()) - (ending length()))
    }

    getOutput: func() -> String {
        if (File new(outName) isFile()) {
            fr  := FileReader new(outName)
            buf := StringBuffer new(Config readSize)
            i := 0
            while (fr hasNext() && i < Config readSize) { 
                buf append(fr read())
                i++
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
    
    execute: func() -> String {
        args := ArrayList<String> new()
        args add(this relativeBinaryPath())
        proc := SubProcess new(args) 
        myPipe := Pipe new()
        proc setStdout(myPipe)
        proc execute()
        a := PipeReader new(myPipe)
        buf := StringBuffer new(Config readSize)
        i := 0
        while (a hasNext() && i< Config readSize) { 
            buf append(a read())
            i++ 
        }
        return buf toString()                
    }   

    relativeBinaryPath: func() -> String {path + File separator + stripped}
    relativePath: func() -> String {path + File separator + fileName}
}

findOOCFiles: func(path: String) -> ArrayList<OocFile> {
    currentDir := File new(path)
    files :ArrayList<OocFile>
    files = currentDir getChildrenNames()
    result := ArrayList<OocFile> new()
    for(item: String in files) {
        if (item endsWith(Config oocEnding)) {
            result add(OocFile new(item, path))
        }
    }
    return result
}

compareOutput: func(s1: String, s2: String) -> Bool {
    s1 equals(s2 substring(0, s2 length()-1)) // s2 always contains another null-byte, needs a fix 
}

main: func() {
    config := Config new()
    path := config getTestDir()
    files := findOOCFiles(path) 
    for (item: OocFile in files) {
        item compile(config getCompiler(), config getCompilerBackend())
        if (compareOutput(item execute(), item getOutput())) {
            "%s" format(item stripped + " PASSED") println()     
        }
    }
}

