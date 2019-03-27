%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	
	#include "y.tab.h"

%}

%option yylineno

%x comment

number [0-9]
alpha [a-zA-Z]
alphanum [{alpha}|{number}]

%%


[\n|" "|\t] ;

"int"    { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return INT;}
"while"  { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return WHILE;}
"char"   { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return CHAR;}
"for"    { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return FOR;}
"return" { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return RETURN;}
"if"     { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return IF;}
"else"   { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return ELSE;}
"void"   { yylval.str = (char*)malloc(100*sizeof(char)); strcpy(yylval.str, yytext); return VOID;}


"#include"[ ]*"<"({alpha})*".h>" {

	
	return PREPROCESS;
}

({number})+ {
	yylval.str = (char*)malloc(100*sizeof(char));
	strcpy(yylval.str, yytext);
	return INTEGER_CONSTANT;
}

({number}+"."+{number}*)|({number}*"."{number}+) {

	return FLOAT_CONSTANT;
}

\"[^"\n]\" {
	return STRING_CONSTANT;
}


"//"[^\n]* {return SINGLE_LINE;}

"/*" {BEGIN comment;}
<comment>.|[ ] ;
<comment>\n {yylineno++;}
<comment>"*/" {BEGIN INITIAL; return MULTI_LINE;}
<comment>"/*" {printf("nested comment\n");exit(1); }
<comment><<EOF>> {printf("unterminated comment\n");exit(1); }

[+|\-|=|/|*|%|&|\(|\)|\[|\]|\;|,|\{|\}|<|>] {return *yytext;}

"++" {return INCREMENT;}
"--" {return DECREMENT;}
"+=" {return PLUSEQ;}

(_|{alpha})(_|{alpha}|{number})* {
	printf("IDENTIFIER\n");
	return IDENTIFIER;
}

({number})(_|{alpha}|{number})* {
	printf("invalid identifier\n");
	exit(1);
}


%%
int yywrap(void) {
	return 1;
}
