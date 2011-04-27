all: change

change: change.c makechange.o
	gcc -g -o change change.c makechange.o

makechange.o: makechange.s
	as -g -o makechange.o makechange.s

clean:
	rm -rf *.o change
