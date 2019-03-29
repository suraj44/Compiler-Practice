%{
	#include "lex.yy.c"

	void yyerror(const char *s) {
		fprintf(stderr, "%d: %s\n", yylineno,s);
		exit(1);
	}
%}

%define parse.lac full
%define parse.error verbose

%union {
	char *str;
	int intval;
}

%token <str> INT WHILE CHAR FOR RETURN IF ELSE VOID
%token <str> PREPROCESS SINGLE_LINE MULTI_LINE
%token <str> INTEGER_CONSTANT FLOAT_CONSTANT STRING_CONSTANT
%token <str> INCREMENT DECREMENT PLUSEQ
%token <str> IDENTIFIER

%left '='
%left '<' '>'
%left '+' '-'
%left '/' '*' '%'
%left INCREMENT DECREMENT

%%
start
	: PREPROCESS start
	| FuncDef start
	| FuncDec start
	| VarDec ';' start
	| SINGLE_LINE start
	| MULTI_LINE start
	| ;

FuncDec
	: DataType IDENTIFIER OpenParanthesis ParamList CloseParanthesis ';'

OpenParanthesis
	: '(' ;

CloseParanthesis
	: ')' ;

ParamList
	: DataType IDENTIFIER ',' ParamList
	| DataType IDENTIFIER 
	;

VarDec
	: DataType VarList ;

VarList
	: IDENTIFIER
	| IDENTIFIER ',' VarList
	| IDENTIFIER '[' ConstExpression ']'
	| IDENTIFIER '[' ConstExpression ']' ',' ParamList 
	| IDENTIFIER '=' Expression

FuncDef
	: DataType IDENTIFIER OpenParanthesis ParamList CloseParanthesis BlockStatement ;

BlockStatement
	: '{' StatList '}' ;

StatList
	: SingleStatement StatList
	| BlockStatement StatList
	| ;

SingleStatement
	: VarDec ';' 
	| Expression ';'
	| ';'

DataType
	: INT 
	| CHAR
	| VOID;


ConstExpression
	: INTEGER_CONSTANT
	| ConstExpression '>' ConstExpression
	| ConstExpression '<' ConstExpression
	| ConstExpression '-' ConstExpression
	| ConstExpression '+' ConstExpression
	| ConstExpression '*' ConstExpression
	| ConstExpression '/' ConstExpression
	| ConstExpression '%' ConstExpression

Expression 
	: Term
	| Expression '>' Expression
	| Expression '<' Expression
	| Expression '-' Expression
	| Expression '+' Expression
	| Expression '*' Expression
	| Expression '/' Expression
	| Expression '%' Expression

Term
	: IDENTIFIER
	| INTEGER_CONSTANT
	| FLOAT_CONSTANT
	| IDENTIFIER INCREMENT
	| IDENTIFIER DECREMENT
	| INCREMENT IDENTIFIER
	| DECREMENT IDENTIFIER

%%

int main() {

	yyparse();
	printf("PARSING COMPLETE\n");
	return 0;
}
