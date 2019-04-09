%{
	#include "lex.yy.c"

	#include "symboltable.c"
	void yyerror(const char *s) {
		printf("Line %3d: %s" ,yylineno,s );
		exit(1);
	}
	char type[100];
	int scope = 0;

%}

%define parse.lac full
%define parse.error verbose

%union {
	char* str;
	int intval;
}

%token <str> WHILE FOR IF ELSE BREAK CONTINUE RETURN CHAR INT VOID FLOAT
%token <str> INTEGER_CONSTANT STRING_CONSTANT PREPROC INCREMENT DECREMENT
%token <str> IDENTIFIER 

%left '='
%left '<' '>'
%left '+' '-'
%left '/' '*' '%'

%nonassoc IFX
%nonassoc ELSE

%%

start
	: VarDec ';' start
	| PREPROC start
	| FunDec ';' start
	| FunDef start
	| ;

VarDec
	: DataType DecList

DecList
	: IDENTIFIER {redec($1, scope);insert($1, type,scope);}
	| IDENTIFIER ',' DecList {redec($1, scope);insert($1, type,scope);}
	| IDENTIFIER '[' ConstExpr ']' ',' DecList {redec($1, scope);insert($1, type,scope);}
	| IDENTIFIER '[' ConstExpr ']' {redec($1, scope);insert($1, type,scope);}
	| IDENTIFIER '=' Expr ',' DecList {redec($1, scope);insert($1, type,scope);}
	| IDENTIFIER '=' Expr  {redec($1, scope);insert($1, type,scope);}

FunDec
	: DataType IDENTIFIER OpenPar ParamList ClosePar {insert($2, type,scope);}
	| DataType IDENTIFIER '(' ')' {insert($2, type,scope);}
FunDef
	: DataType IDENTIFIER OpenPar ParamList ClosePar BlockStat {insert($2, type,scope);}
	| DataType IDENTIFIER '(' ')' BlockStat {insert($2, type,scope);}

OpenPar
	: '(' {scope++;}

ClosePar
	: ')' {scope--;}

ParamList
	: DataType IDENTIFIER {insert($2, type,scope);}
	| DataType IDENTIFIER ',' ParamList {insert($2, type,scope);}

BlockStat
	: '{' {scope++;} StatList '}' {while(stack[tos]->scope==scope) tos--;scope--;}

StatList
	: SingleStat StatList
	| BlockStat StatList
	| ;

SingleStat
	: ';'
	| VarDec ';'
	| RETURN ';'
	| Expr ';'
	| Assign ';'
	| IfStat 
	| ForStat
	| WhileStat

Expr
	: Term
	| Expr '+' Expr
	| Expr '-' Expr
	| Expr '/' Expr
	| Expr '*' Expr
	| Expr '%' Expr
	| Expr '<' Expr
	| Expr '>' Expr

Term
	: IDENTIFIER {undeclared($1);}
	| INCREMENT IDENTIFIER {undeclared($2);}
	| DECREMENT IDENTIFIER {undeclared($2);}
	| IDENTIFIER INCREMENT {undeclared($1);}
	| IDENTIFIER DECREMENT {undeclared($1);}
	| INTEGER_CONSTANT {insertc($1);}
	| IDENTIFIER '[' ConstExpr ']' {undeclared($1);}
	| STRING_CONSTANT {insertc($1);}
	| FunCall

DataType
	: VOID {strcpy(type, "void");}
	| FLOAT {strcpy(type, "float");}
	| INT {strcpy(type, "int");}
	| CHAR {strcpy(type, "char");}

ConstExpr
	: INTEGER_CONSTANT {insertc($1);}
	| ConstExpr '+' ConstExpr
	| ConstExpr '-' ConstExpr
	| ConstExpr '/' ConstExpr
	| ConstExpr '*' ConstExpr
	| ConstExpr '%' ConstExpr

Assign
	: Term '=' Expr

FunCall 
	: IDENTIFIER '(' ArgList ')' 
	| IDENTIFIER '('  ')'

ArgList 
	: Term ',' ArgList
	| Term

IfStat
	: IF '(' Expr ')' BlockStat %prec IFX
	| IF '(' Expr ')' SingleStat %prec IFX
	| IF '(' Expr ')' BlockStat ELSE BlockStat %prec IFX

WhileStat
	: WHILE '(' Expr ')' BlockStat

ForStat
	: FOR '(' VarDec ';' Expr ';' Expr ')' BlockStat
	| FOR '(' Expr ';' Expr ';' Expr ')' BlockStat
%%

int main() {

	yyparse();
	printf("PARSING COMPLETE\n");
	displaytable();
	displayConst();

}
