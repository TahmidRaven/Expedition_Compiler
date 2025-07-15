/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
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
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     CONST_INT = 259,
     CONST_FLOAT = 260,
     ADDOP = 261,
     MULOP = 262,
     INCOP = 263,
     DECOP = 264,
     ASSIGNOP = 265,
     RELOP = 266,
     LOGICOP = 267,
     NOT = 268,
     LPAREN = 269,
     RPAREN = 270,
     LCURL = 271,
     RCURL = 272,
     LTHIRD = 273,
     RTHIRD = 274,
     COMMA = 275,
     COLON = 276,
     SEMICOLON = 277,
     IF = 278,
     ELSE = 279,
     FOR = 280,
     WHILE = 281,
     DO = 282,
     BREAK = 283,
     INT = 284,
     CHAR = 285,
     FLOAT = 286,
     DOUBLE = 287,
     VOID = 288,
     RETURN = 289,
     SWITCH = 290,
     CASE = 291,
     DEFAULT = 292,
     CONTINUE = 293,
     GOTO = 294,
     PRINTF = 295,
     PRINTLN = 296,
     ELSE_LOWER = 297
   };
#endif
/* Tokens.  */
#define ID 258
#define CONST_INT 259
#define CONST_FLOAT 260
#define ADDOP 261
#define MULOP 262
#define INCOP 263
#define DECOP 264
#define ASSIGNOP 265
#define RELOP 266
#define LOGICOP 267
#define NOT 268
#define LPAREN 269
#define RPAREN 270
#define LCURL 271
#define RCURL 272
#define LTHIRD 273
#define RTHIRD 274
#define COMMA 275
#define COLON 276
#define SEMICOLON 277
#define IF 278
#define ELSE 279
#define FOR 280
#define WHILE 281
#define DO 282
#define BREAK 283
#define INT 284
#define CHAR 285
#define FLOAT 286
#define DOUBLE 287
#define VOID 288
#define RETURN 289
#define SWITCH 290
#define CASE 291
#define DEFAULT 292
#define CONTINUE 293
#define GOTO 294
#define PRINTF 295
#define PRINTLN 296
#define ELSE_LOWER 297



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
