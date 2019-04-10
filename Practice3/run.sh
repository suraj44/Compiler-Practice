flex scanner.flex
yacc -d -v parser.y
gcc -g y.tab.c
