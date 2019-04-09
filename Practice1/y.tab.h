/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INT = 258,
    FLOAT = 259,
    WHILE = 260,
    FOR = 261,
    IF = 262,
    ELSE = 263,
    CHAR = 264,
    VOID = 265,
    RETURN = 266,
    BREAK = 267,
    CONTINUE = 268,
    INTEGER_CONSTANT = 269,
    IDENTIFIER = 270,
    STRING_CONSTANT = 271,
    INCREMENT = 272,
    DECREMENT = 273,
    PLUSEQ = 274,
    PREPROCESS = 275,
    DEC = 276,
    DEF = 277,
    IFX = 278
  };
#endif
/* Tokens.  */
#define INT 258
#define FLOAT 259
#define WHILE 260
#define FOR 261
#define IF 262
#define ELSE 263
#define CHAR 264
#define VOID 265
#define RETURN 266
#define BREAK 267
#define CONTINUE 268
#define INTEGER_CONSTANT 269
#define IDENTIFIER 270
#define STRING_CONSTANT 271
#define INCREMENT 272
#define DECREMENT 273
#define PLUSEQ 274
#define PREPROCESS 275
#define DEC 276
#define DEF 277
#define IFX 278

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 13 "parser.y" /* yacc.c:1909  */

	char * str;
	int intval;


#line 106 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
