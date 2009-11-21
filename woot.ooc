import io/File
import os/[Process,unistd]
import structs/ArrayList
import config

OocFile: class {

    stripped: String
    fileName: String
    path: String

    init: func(fName: String, fpath: String) {
        fileName = fName
        path = fpath
        stripped = this stripEnding(fileName, Config oocEnding)
    }

    stripEnding: func(fileName: String, ending: String) -> String {
        return fileName substring(0, (fileName length()) - (ending length()))
    }

    relativeBinaryPath: func() -> String {path + File separator + stripped}
    relativePath: func() -> String {path + File separator + fileName}
}

findOOCFiles: func(path: String) -> ArrayList<OocFile> {
    currentDir := File new(path)
    files :ArrayList<OocFile>
    files = currentDir getChildrenNames()
    result := ArrayList<OocFile> new()
    tmp :OocFile
    for(item: String in files) {
        if (item endsWith(Config oocEnding)) {
            tmp = OocFile new(item, path)
            result add(OocFile new(item, path))
        }
    }
    return result
}



compileFile: func(f: OocFile, compiler: String, cBackend: String) -> Int {
    args := ArrayList<String> new()
    args add(compiler).add(f relativePath()) 
    args add("-o=%s" format(f relativeBinaryPath()))
    args add("-%s" format(cBackend))
    SubProcess new(args) execute()
}

executeFile: func(f: OocFile) -> Int {
    args := ArrayList<String> new()
    args add(f relativeBinaryPath())
    SubProcess new(args) execute()
}
main: func() {
    config := Config new()
    path := config getTestDir()
    files := findOOCFiles(path) 
    for (item: OocFile in files) {
        compileFile(item, config getCompiler(), config getCompilerBackend())
        executeFile(item)
    }
}

