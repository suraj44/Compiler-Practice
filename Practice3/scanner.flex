%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	int cmnt_begin = 0;
%}

%option yylineno
%x cmnt

alpha [a-zA-Z]
num [0-9]

%% 

(" "|\n|\t|\r) ;

"//"[^\n]* ;

"/*" {cmnt_begin = yylineno;BEGIN cmnt;}

<cmnt>[^\n] ;
<cmnt>\n ;
<cmnt>"*/" {BEGIN INITIAL;}
<cmnt>"/*" {printf("Line %3d: Nested comment not allowed\n", yylineno); exit(1);}
<cmnt><<EOF>> printf("Line %3d: Unterminated comment\n", cmnt_begin); exit(1);

"#include"(" ")*\<{alpha}+\.h\> {return PREPROC;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"int" {return INT;}
"break" {return BREAK;}

(\+|\-)?{num}+"."{num}+ {yylval.str = (char*)malloc(100&sizeof(char)); strcpy(yylval.str, yytext); return FLOAT_CONSTANT;}

{num}+ {yylval.str = (char*)malloc(100&sizeof(char)); strcpy(yylval.str, yytext); return INT_CONSTANT;}

\"[^"\n]*\" {yylval.str = (char*)malloc(100&sizeof(char)); strcpy(yylval.str, yytext);return STRING_CONSTANT;}

({alpha}|\_)({alpha}|\_|{num})* {yylval.str = (char*)malloc(100&sizeof(char)); strcpy(yylval.str, yytext); return IDENTIFIER;}

({num})({alpha}|\_|{num})+ {printf("Line %3d: Invalid identifier\n", yylineno); exit(1);}

[\;|\,|\;(|\)|\{|\}|\*|\=|<] {return *yytext;}

">=" {return GE;}
"!=" {return NE;}
"&&" {return AND;}
"++" {return INCREMENT;}

"!" {printf("Line %3d: Unexpected '!'\n", yylineno); exit(1);}
"\\" {printf("Line %3d: Unexpected '\\'\n", yylineno); exit(1);}

%%

int yywrap(void) {
	return 1;
}
