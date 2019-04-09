flex scanner.flex
yacc parser.y -d -v 
gcc y.tab.c
