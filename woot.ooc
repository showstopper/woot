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
compileFile: func(fileName: String, path: String, compiler: String) -> Int {
    args := ArrayList<String> new()
    args add(compiler).add(path + File separator + fileName)
    proc := SubProcess new(args)
    proc execute()
    /* workaround - need option to specify output-file! */
    exec := stripEnding(fileName, Config oocEnding)
    args = ArrayList<String> new()
    args add("mv").add(exec).add(path)
    proc = SubProcess new(args)
    proc execute()
    
}

executeFile: func(fileName: String, path: String) -> Int {
    args := ArrayList<String> new()
    args add(path + File separator + stripEnding(fileName, Config oocEnding))
    proc := SubProcess new(args)
    proc execute()
}
main: func() {
    config := Config new()
    path := config getTestDir()
    files := findOOCFiles(path) 
    for (item: String in files) {
        compileFile(item, path, config getCompiler())
        executeFile(item, path)
    }
}

