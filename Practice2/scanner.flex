%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "y.tab.h"
%}

%option yylineno
%x cmnt

alpha [a-zA-Z]
num [0-9]

%% 

(" "|\t|\v)+ ;

"//"[^\n]* ;

"#include"(" ")*\<({alpha})+\.h\> {return PREPROC;}

"/*" {BEGIN cmnt;}

<cmnt>"*/" {BEGIN INITIAL;}
<cmnt>"/*" {printf("Line %3d: Nested comment not allowed\n", yylineno);exit(1);}
<cmnt>[^\n] ;
<cmnt>\n {yylineno++;}
<cmnt><<EOF>> {printf("Line %3d: Unterminated comment\n", yylineno);exit(1);}

"int" {return INT;}
"float" {return FLOAT;}
"void" {return VOID;}
"char" {return CHAR;}
"while" {return WHILE;}
"for" {return FOR;}
"if" {return IF;}
"else" {return ELSE;}
"break" {return BREAK;}
"continue" {return CONTINUE;}
"return" {return RETURN;}

(\+|\-)?{num}+ {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return INTEGER_CONSTANT;}

({alpha}|_)({alpha}|_|{num})* {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return IDENTIFIER;}

({num})({alpha}|_|{num})* {printf("Line %3d: Invalid identifier\n", yylineno);exit(1);}


\"[^"\n]*\" {yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return STRING_CONSTANT;}

[\=|\(|\)|\[|\]|\{|\}|\+|\-|\/|\*|\%|\<|\>|\;|\,] {return *yytext;}

"++" {return INCREMENT;}
"--" {return DECREMENT;}


%%

int yywrap(void) {

	return 1;

}
