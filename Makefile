
build:
	gnat compile maze
	gnat compile adamazing
	gnat bind adamazing
	gnat link adamazing
	gnat make adamazing

run:
	./adamazing
