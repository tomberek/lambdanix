posix_openpt.so: posix_openpt.c
	gcc --std=c99 -o posix_openpt.so -shared posix_openpt.c -Wall -Wfatal-errors -fPIC -g -ldl
install: posix_openpt.so
	cp posix_openpt.so $$PREFIX


