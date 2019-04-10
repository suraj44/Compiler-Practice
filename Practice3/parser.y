%{
	#include "lex.yy.c"
	#include "symboltable.c"
	void yyerror(const char * s);
	char type[100];
	int scope = 0;
	int in_loop = 0;
%}

%union {
	char *str;
	int intval;
	float floatval;
}
%define parse.lac full
%define parse.error verbose

%token <str> PREPROC IF ELSE WHILE FOR INT BREAK
%token <str> STRING_CONSTANT INT_CONSTANT FLOAT_CONSTANT IDENTIFIER
%token <str> NE GE AND INCREMENT


%left '='
%left AND GE NE
%left '<'
%left '*'

%nonassoc IFX
%nonassoc ELSE

%%

start
	: PREPROC start	
	| VarDec ';' start
	| FunDef start
	| ;

VarDec
	: DataType VarList

VarList
	: IDENTIFIER {redeclared($1, scope);insert($1, type, scope);}
	| IDENTIFIER ',' VarList {insert($1, type, scope);}
	| IDENTIFIER '=' Expr {insert($1, type, scope);}
	| IDENTIFIER '=' Expr ',' VarList {insert($1, type, scope);}

DataType
	: INT {strcpy(type, "int");}

Expr
	: Expr GE Expr
	| Expr NE Expr
	| Expr '*' Expr
	| Expr AND Expr
	| Expr '=' Expr
	| Expr '<' Expr
	| Term

Term
	: IDENTIFIER {undeclared($1); }
	| INCREMENT IDENTIFIER {undeclared($2);}
	| INT_CONSTANT {insertc($1);}
	| FLOAT_CONSTANT {insertc($1);}
	| STRING_CONSTANT {insertc($1);}

FunDef
	: DataType IDENTIFIER OpenParan ParamList CloseParan BlockStat
	| DataType IDENTIFIER '(' ')' BlockStat

OpenParan
	: '(' {scope++;}

CloseParan
	: ')' {scope--;}

ParamList
	: DataType IDENTIFIER
	| DataType IDENTIFIER ',' ParamList

BlockStat
	: '{' {scope++;} StatType '}' {while(tos>=0 && stack[tos]->scope==scope)tos--;scope--;}

StatType
	: BlockStat StatType
	| SingleStat StatType
	| ;

SingleStat
	: ';'
	| Expr ';'
	| IfStat 
	| VarDec ';'
	| BREAK ';' {if(in_loop==0){printf("Line %3d: Illegal break statement\n", yylineno); exit(1);}}
	| ForStat

IfStat
	: IF '(' Expr ')' BlockStat %prec IFX
	| IF '(' Expr ')' BlockStat ELSE BlockStat %prec ELSE
	| IF '(' Expr ')' BlockStat ELSE SingleStat %prec ELSE
	| IF '(' Expr ')' SingleStat ELSE SingleStat %prec ELSE

ForStat
	: FOR '(' VarDec ';' Expr ';' Expr ')' {in_loop++;} BlockStat {in_loop--;}

%%

void yyerror(const char * s) {

	printf("Line %3d: %s\n",yylineno, s);
	exit(1);
}

int main() {

	yyparse();
	printf("PARSING COMPLETE\n");
	displayS();
	displayC();
}
