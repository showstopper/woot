import io/[File,FileReader]
import os/Process
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
            while (fr hasNext()) { // IMPORTANT: Possible place for segfault 
                buf append(fr read())
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
    
    execute: func() -> Int {
        args := ArrayList<String> new()
        args add(this relativeBinaryPath())
        SubProcess new(args) execute()
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

main: func() {
    config := Config new()
    path := config getTestDir()
    files := findOOCFiles(path) 
    for (item: OocFile in files) {
        item compile(config getCompiler(), config getCompilerBackend())
        item execute()
    }
}

