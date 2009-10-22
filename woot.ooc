import io/File
import os/Directory
import os/Process
import structs/ArrayList

suiteEnding := ".woot"
oocEnding   := ".ooc"
outEnding   := ".output"

compiler := "ooc"

findOOCFiles: func(path: String) -> ArrayList<String> {
    currentDir := Directory new(path)
    files :ArrayList<String>
    files = currentDir getFileNames()
    result := ArrayList<String> new()
    for(item: String in files) {
        if (item endsWith(oocEnding)) {
            result add(path + File separator + item)
        }
    }
    return result
}

compileFile: func(fileName: String, path: String) -> Int {
    exec := SubProcess new([compiler, fileName, "-outpath="+path, null])
    exec execute()
}

main: func() {
    path := "tests/"
    File separator println()
    files := findOOCFiles(path) 
    for (item: String in files) {
        compileFile(item, path)
    }
}

