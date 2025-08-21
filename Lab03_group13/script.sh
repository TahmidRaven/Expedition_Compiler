#!/bin/bash

yacc -d -y --debug --verbose syntax_analyzer.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex lex_analyzer.l
echo 'Generated the scanner C file'
g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o -o semantic_analyzer
echo 'All ready, running'
./semantic_analyzer input.c
echo 'Log file contents:'
cat my_log.txt
echo 'Error file contents:'
cat my_error.txt