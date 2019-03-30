%{
	#include "lex.yy.c"
	#include "symbol_table.c"
	void yyerror(const char *s) {
		fprintf(stderr, "%d: %s\n", yylineno,s);
		exit(1);
	}

	char type[100];
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

%nonassoc IFX
%nonassoc ELSE

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
	: DataType IDENTIFIER OpenParanthesis ParamList CloseParanthesis ';' {insert($2, type);}
	| DataType IDENTIFIER OpenParanthesis CloseParanthesis ';'           {insert($2, type);}

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
	: IDENTIFIER                                       {insert($1, type);}
	| IDENTIFIER ',' VarList                           {insert($1, type);}
	| IDENTIFIER '[' ConstExpression ']'               {insert($1, type);}
	| IDENTIFIER '[' ConstExpression ']' ',' ParamList {insert($1, type);}
	| IDENTIFIER '=' Expression                        {insert($1, type);}

FuncDef
	: DataType IDENTIFIER OpenParanthesis ParamList CloseParanthesis BlockStatement {insert($2, type);}
	| DataType IDENTIFIER OpenParanthesis CloseParanthesis BlockStatement           {insert($2, type);}

BlockStatement
	: '{' StatList '}' ;

StatList
	: SingleStatement StatList
	| BlockStatement StatList
	| ;

SingleStatement
	: VarDec ';' 
	| IfStat
	| Expression ';'
	| WhileStat
	| ForStat
	| ReturnStat ';'
	| ';'

DataType
	: INT  {strcpy(type, $1);}
	| CHAR {strcpy(type, $1);}
	| VOID {strcpy(type, $1);}

FunCall
	: IDENTIFIER '(' ArgList ')'
	| IDENTIFIER '(' ')'

ArgList
	: Expression ',' ArgList
	| Expression

ReturnStat
	: RETURN Expression
	| RETURN
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
	| FunCall
	| IDENTIFIER '[' ConstExpression ']'

IfStat
	: IF '(' Expression ')' SingleStatement %prec IFX
	| IF '(' Expression ')' BlockStatement  %prec IFX
	| IF '(' Expression ')' SingleStatement ELSE SingleStatement %prec ELSE
	| IF '(' Expression ')' SingleStatement ELSE BlockStatement %prec ELSE
	| IF '(' Expression ')' BlockStatement ELSE SingleStatement %prec ELSE
	| IF '(' Expression ')' BlockStatement ELSE BlockStatement %prec ELSE

WhileStat
	: WHILE '(' Expression ')' SingleStatement
	| WHILE '(' Expression ')' BlockStatement


ForStat
	: FOR '(' VarDec ';' Expression ';' Expression ')' SingleStatement
	| FOR '(' VarDec ';' Expression ';' Expression ')' BlockStatement
	| FOR '(' Expression ';' Expression ';' Expression ')' SingleStatement
	| FOR '(' Expression ';' Expression ';' Expression ')' BlockStatement
%%

int main() {

	yyparse();
	printf("PARSING COMPLETE\n");
	printSymbolTable();
	return 0;
}
