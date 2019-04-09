%{

	#include "lex.yy.c"
	#include "symbolTable.c"
	char type[100];
	int scope = 0;
	void yyerror(const char* s);
%}	

%define parse.lac full
%define parse.error verbose

%union {
	char * str;
	int intval;

}

%token INT FLOAT WHILE FOR IF ELSE CHAR VOID RETURN BREAK CONTINUE
%token <str> INTEGER_CONSTANT IDENTIFIER
%token STRING_CONSTANT
%token INCREMENT DECREMENT PLUSEQ
%token PREPROCESS

%left '='
%left '<' '>'
%left '+' '-'
%left '/' '*' '%'
%left INCREMENT DECREMENT

%type<intval> ParamList ArgList ConstExpr 

%nonassoc DEC
%nonassoc DEF


%nonassoc IFX
%nonassoc ELSE


%%
start
	: PREPROCESS start
	| FunDec ';' start
	| FunDef start
	| VarDec ';' start
	| ;

FunDec
	: DataType IDENTIFIER OpenParan ParamList CloseParan   {insert($2, type, scope); setfunc($4);} 
	| DataType IDENTIFIER '(' ')'                        {insert($2, type, scope); setfunc(0);}

FunDef
	: DataType IDENTIFIER OpenParan ParamList CloseParan { insert($2, type, scope); setfunc($4); }  BlockStat 
	| DataType IDENTIFIER '(' ')' BlockStat { insert($2, type, scope);setfunc(0);}

OpenParan
	: '(' {scope++;}

CloseParan
	: ')' {scope--;}

DataType
	: VOID {strcpy(type, "void");}
	| INT  {strcpy(type, "int");}
	| CHAR {strcpy(type, "char");}
	| FLOAT {strcpy(type, "float");}



ParamList
	: DataType IDENTIFIER ',' ParamList {$$ = $4 + 1;insert($2, type, scope);}
	| DataType IDENTIFIER		    {$$ = 1;insert($2, type, scope);}

VarDec
	: DataType VarList

VarList
	: IDENTIFIER                                       {redeclared($1, scope);  insert($1, type, scope);}
	| IDENTIFIER ',' VarList                           {redeclared($1, scope); insert($1, type, scope);}
	| IDENTIFIER '[' ConstExpr ']'              {redeclared($1, scope); insert($1, type, scope); setarray($3);}
	| IDENTIFIER '[' ConstExpr ']' ',' VarList  {redeclared($1, scope); insert($1, type, scope); setarray($3);}
	| IDENTIFIER '=' Expr {redeclared($1, scope); insert($1, type, scope);}

FunCall  
	: IDENTIFIER '(' ArgList ')' {undeclared($1); isfunc($1); check_params($1, $3);}
	| IDENTIFIER '(' ')' {undeclared($1); isfunc($1); check_params($1, 0);}

ReturnStat
	: RETURN 
	| RETURN Expr

ArgList
	: Expr ',' ArgList {$$ = 1 + $3;}
	| STRING_CONSTANT ',' ArgList {$$ = 1 + $3;}
	| Expr {$$ = 1;}
	| STRING_CONSTANT {$$ = 1;}

StatType
	: SingleStat StatType
	| BlockStat StatType
	| ;

SingleStat
	: ';'
	| Expr ';'
	| ReturnStat ';'
	| VarDec ';'
	| IfStat 
	| WhileStat
	| ForStat
	| BREAK ';'
	| CONTINUE ';'

BlockStat
	: '{' {scope++;}
	StatType  
	'}' {
while(stack[tos]->scope == scope)
                tos--;
		scope--;}

ConstExpr
	: INTEGER_CONSTANT {$$ = atoi(yytext);}
	| ConstExpr '+' ConstExpr {$$ = $1 + $3;}
	| ConstExpr '-' ConstExpr {$$ = $1 - $3;}
	| ConstExpr '*' ConstExpr {$$ = $1 * $3;}
	| ConstExpr '/' ConstExpr {$$ = $1 / $3;}
	| ConstExpr '%' ConstExpr {$$ = $1 % $3;}
	| '(' ConstExpr ')'	  {$$ = $2;}

Expr
	: Term
	| Expr '+' Expr
	| Expr '-' Expr
	| Expr '/' Expr
	| Expr '*' Expr
	| Expr '%' Expr
	| Expr '<' Expr
	| Expr '>' Expr
	| Expr '=' Expr
	| '(' Expr ')'

Term
	: INTEGER_CONSTANT
	| IDENTIFIER 			{undeclared($1);}
	| IDENTIFIER '[' ConstExpr ']'  {undeclared($1); isarr($1); checkdims($1, $3);}
	| INCREMENT IDENTIFIER          {undeclared($2);}
	| DECREMENT IDENTIFIER          {undeclared($2);}
	| IDENTIFIER INCREMENT          {undeclared($1);}
	| IDENTIFIER DECREMENT          {undeclared($1);}
	| FunCall                     

IfStat
	: IF '(' Expr ')' SingleStat %prec IFX
	| IF '(' Expr ')' BlockStat %prec IFX
	| IF '(' Expr ')' SingleStat ELSE BlockStat %prec ELSE
	| IF '(' Expr ')' BlockStat ELSE BlockStat %prec ELSE
	| IF '(' Expr ')' BlockStat ELSE SingleStat %prec ELSE
	| IF '(' Expr ')' SingleStat ELSE SingleStat %prec ELSE 

ForStat
	: FOR '(' VarDec ';' Expr ';' Expr ')' BlockStat
	| FOR '(' Expr ';' Expr ';' Expr ')' BlockStat

WhileStat
	: WHILE '(' Expr ')' BlockStat
	


%%

void yyerror(const char* s) {
	printf("Line %3d: %s", yylineno, s);
	exit(1);
}

int main() {

	yyparse();
	printf("PARSING COMPLETE\n");
	displayTable();
}
