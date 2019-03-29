flex scanner.flex
yacc -d -v parser.y
gcc y.tab.c
