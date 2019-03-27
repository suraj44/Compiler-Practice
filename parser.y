%{
	#include "lex.yy.c"

	void yyerror(char *s) {
		fprintf(stderr, "%s\n", s);
		exit(1);
	}
%}


%union {
	char *str;
	int intval;
}

%token <str> INT WHILE CHAR FOR RETURN IF ELSE VOID
%token <str> PREPROCESS SINGLE_LINE MULTI_LINE
%token <str> INTEGER_CONSTANT FLOAT_CONSTANT STRING_CONSTANT
%token <str> INCREMENT DECREMENT PLUSEQ
%token <str> IDENTIFIER

%%
start:
	PREPROCESS|MULTI_LINE|IDENTIFIER;

%%

int main() {

	yyparse();
	printf("PARSING COMPLETE\n");
	return 0;
}
