import os/Directory
import structs/ArrayList

suiteEnding := ".woot"
oocEnding   := ".ooc"
outEnding   := ".output"

findOOCFiles: func(path: String) -> ArrayList<String> {
    currentDir := Directory new(path)
    files :ArrayList<String>
    files = currentDir getFileNames()
    result := ArrayList<String> new()
    for(item: String in files) {
        if (item endsWith(oocEnding)) {
            result add(item)
        }
    }
    return result
}

main: func() {
    files := findOOCFiles(".") 
    for (item: String in files) {
        item println()
    }
}

