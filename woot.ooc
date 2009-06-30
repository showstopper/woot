import io.File;

func main {

	printHierarchy(new File("."));

}

func printHierarchy(File f) {
	
	printHierarchy(f, 0);
	
}

func printHierarchy(File f, Int i) {

	printf("%s\n", f.path);
	List children = f.children;
	for(File c: children) {
		if(c.isDir) {
			printHierarchy(c);
		} else {
			printf("%s\n", c.path);
		}
	}

}

func printTabs(Int count) {

	for(Int i: 0..count) {
		printf("\t");
	}

}
