%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

%}

%option yylineno
 
alpha [a-zA-Z] 
num [0-9] 
 
%x comment


%% 

[" "|\n|\t] ;

"//"[^\n]* ;

"/*" {BEGIN comment;}

<comment>.|[ ] ;
<comment>\n {yylineno++;}
<comment>"*/" {BEGIN INITIAL;}
<comment>"/*" {printf("Illegal nested comment\n");exit(1);}
<comment><<EOF>> {printf("Unterminated comment\n");exit(1);}

"#include"" "*"<"({alpha})+".h>" {return PREPROCESS;}

"int" {return INT;}
"float" {return FLOAT;}
"char" {return CHAR;}
"while" {return WHILE;}
"for" {return FOR;}
"if" {return IF;}
"else" {return ELSE;}
"void" {return VOID;}
"return" {return RETURN;}
"break" {return BREAK;}
"continue" {return CONTINUE;}

\"[^\n"]*\" {return STRING_CONSTANT;}

[\+|\-]?{num}+ {yylval.str = (char*)malloc(sizeof(char)*100); strcpy(yylval.str, yytext);return INTEGER_CONSTANT;}

(_|{alpha})({alpha}|{num}|_)* {yylval.str = (char*)malloc(sizeof(char)*100); strcpy(yylval.str, yytext);return IDENTIFIER;}


({num})({alpha}|{num}|_)+ {printf("Line %3d: Invalid identifier %s \n", yylineno, yytext); exit(1);}



[\=|\+|\-|\/|\*|\%|\(|\)|\[|\]|\{|\}|\,|\;|\>|\<] {return *yytext;}

"++" {return INCREMENT;}
"--" {return DECREMENT;}
"+=" {return PLUSEQ;}



%%

int yywrap(void) {
	return 1;
}
