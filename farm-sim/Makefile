all: main.cc 
	gcc -Wall -o main main.cc -llua

library: main.cc 
	gcc main.cc -shared -o windSimulatorUsb.dll -fPIC -llua

  clean: 
	  $(RM) main