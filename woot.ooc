import io.File

main: func {

	printHierarchy(File new("."))

}

printHierarchy: func (f: File) {
	
	printHierarchy(f, 0)
	
}

printHierarchy: func (f: File, i: Int) {

	iter := f children() iterator()
	printTabs(i)
	printf("%s\n", f name())
	while(iter hasNext()) {
		File child = iter next()
		if(child isDir()) {
			printHierarchy(child, i + 1)
		} else {
			printTabs(i + 1)
			printf("%s\n", child name())
		}
	}

}

printTabs: func (count: Int) {

	for(i: Int in 0..count) {
		printf("    ");
	}

}
