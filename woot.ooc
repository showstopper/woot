import io/File
import os/[Process,unistd]
import structs/ArrayList
import config


findOOCFiles: func(path: String) -> ArrayList<String> {
    currentDir := File new(path)
    files :ArrayList<String>
    files = currentDir getChildrenNames()
    result := ArrayList<String> new()
    for(item: String in files) {
        if (item endsWith(Config oocEnding)) {
            result add(item)
        }
    }
    return result
}

stripEnding: func(fileName: String, ending: String) -> String {
    return fileName substring(0, (fileName length()) - (ending length()))
}

compileFile: func(fileName: String, path: String, compiler: String, cBackend: String) -> Int {
    args := ArrayList<String> new()
    exec := stripEnding(fileName, Config oocEnding)
    args add(compiler).add(path + File separator + fileName)
    args add("-o="+path + File separator + exec)
    args add("-" + cBackend)
    SubProcess new(args) execute()
}

executeFile: func(fileName: String, path: String) -> Int {
    args := ArrayList<String> new()
    args add(path + File separator + stripEnding(fileName, Config oocEnding))
    SubProcess new(args) execute()
}
main: func() {
    config := Config new()
    path := config getTestDir()
    files := findOOCFiles(path) 
    for (item: String in files) {
        compileFile(item, path, config getCompiler(), config getCompilerBackend())
        executeFile(item, path)
    }
}

