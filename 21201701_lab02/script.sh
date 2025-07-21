#!/bin/bash

yacc -d -y --debug --verbose 21201701_ver06.y
echo 'Generated the parser C file as well as the header file'

g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'

flex 21201701_ver06.l
echo 'Generated the scanner C file'

g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'

g++ y.o l.o -o a.out
echo 'All ready, running'

./a.out input.txt
