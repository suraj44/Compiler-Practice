%{
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


%type <intval> ParamList ArgList

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
	: DataType IDENTIFIER OpenParanthesis ParamList CloseParanthesis ';' { redeclared($2); node *temp = insert($2, type, curr_scope); temp->num_params = $4;}
	| DataType IDENTIFIER OpenParanthesis CloseParanthesis ';'           { redeclared($2); node* temp = insert($2, type, curr_scope); temp->num_params = 0;}

OpenParanthesis
	: '(' {curr_scope++;}

CloseParanthesis
	: ')' {curr_scope--;}

ParamList
	: DataType IDENTIFIER ',' ParamList { $$ = $4 + 1;redeclared($2); insert($2, type, curr_scope);}
	| DataType IDENTIFIER               { $$ =1 ;redeclared($2); insert($2, type, curr_scope);}
	;

VarDec
	: DataType VarList ;

VarList
	: IDENTIFIER                                       {redeclared($1); insert($1, type, curr_scope);}
	| IDENTIFIER ',' VarList                           {redeclared($1); insert($1, type, curr_scope);}
	| IDENTIFIER '[' ConstExpression ']'               {redeclared($1); insert($1, type, curr_scope);}
	| IDENTIFIER '[' ConstExpression ']' ',' ParamList {redeclared($1); insert($1, type, curr_scope);}
	| IDENTIFIER '=' Expression                        {redeclared($1); insert($1, type, curr_scope);}

FuncDef
	: DataType IDENTIFIER OpenParanthesis ParamList CloseParanthesis {redeclared($2); node* temp = insert($2, type, curr_scope); temp->num_params = $4;} BlockStatement 
	| DataType IDENTIFIER OpenParanthesis CloseParanthesis {redeclared($2); node* temp = insert($2, type, curr_scope); temp->num_params = 0;} BlockStatement

BlockStatement
	: '{' {curr_scope++;}
	 StatList 
	  '}' {curr_scope--;}

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
	: IDENTIFIER '(' ArgList ')'  {undeclared($1); not_function($1); num_params_check($1, $3);}
	| IDENTIFIER '(' ')'          {undeclared($1); not_function($1); num_params_check($1, 0);}

ArgList
	: Expression ',' ArgList {$$ = $3 + 1;} 
	| Expression             {$$ = 1;}

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
	: IDENTIFIER            {undeclared($1);}
	| INTEGER_CONSTANT
	| FLOAT_CONSTANT
	| IDENTIFIER INCREMENT  {undeclared($1);}
	| IDENTIFIER DECREMENT  {undeclared($1);}
	| INCREMENT IDENTIFIER  {undeclared($2);}
	| DECREMENT IDENTIFIER  {undeclared($2);}
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

/*
** Added scopes to symbol table
** Undeclared variable check
** Reclared variable check
** Is a function check
** Check if function call params match func definition
*/
