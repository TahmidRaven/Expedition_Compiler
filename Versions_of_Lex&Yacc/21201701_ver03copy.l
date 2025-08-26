%option noyywrap

%{
#include<bits/stdc++.h>
#include"symbol_info.h"
#define YYSTYPE symbol_info*
#include "y.tab.h"

extern YYSTYPE yylval;
using namespace std;

void yyerror(char *);

string loglist;
extern int lines;
extern ofstream outlog;
%}

delim      [ \t\v\r]
ws         {delim}+
newline    \n
letter_    [A-Za-z_]
digit      [0-9]
id         {letter_}({letter_}|{digit})*
intconst   {digit}+
floatconst ({digit}+\.{digit}*)|({digit}*\.{digit}+)

%%

{ws}          { /* ignore whitespace */ }
{newline}     { lines++; }

"if" {
    loglist = "Line no " + to_string(lines) + ": Token <IF> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return IF;
}

"else" {
    loglist = "Line no " + to_string(lines) + ": Token <ELSE> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return ELSE;
}

"for" {
    loglist = "Line no " + to_string(lines) + ": Token <FOR> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return FOR;
}

"while" {
    loglist = "Line no " + to_string(lines) + ": Token <WHILE> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return WHILE;
}

"return" {
    loglist = "Line no " + to_string(lines) + ": Token <RETURN> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return RETURN;
}

{intconst} {
    symbol_info *s = new symbol_info(yytext, "CONST_INT");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <CONST_INT> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return CONST_INT;
}

{floatconst} {
    symbol_info *s = new symbol_info(yytext, "CONST_FLOAT");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <CONST_FLOAT> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return CONST_FLOAT;
}

{id} {
    symbol_info *s = new symbol_info(yytext, "ID");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <ID> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return ID;
}

"++" {
    symbol_info *s = new symbol_info(yytext, "INCOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <INCOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return INCOP;
}

"--" {
    symbol_info *s = new symbol_info(yytext, "DECOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <DECOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return DECOP;
}

"+"|"-" {
    symbol_info *s = new symbol_info(yytext, "ADDOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <ADDOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return ADDOP;
}

"*"|"/"|"%" {
    symbol_info *s = new symbol_info(yytext, "MULOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <MULOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return MULOP;
}

"<="|">="|"=="|"!="|"<"|">" {
    symbol_info *s = new symbol_info(yytext, "RELOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <RELOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return RELOP;
}

"&&"|"||" {
    symbol_info *s = new symbol_info(yytext, "LOGICOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <LOGICOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return LOGICOP;
}

"=" {
    symbol_info *s = new symbol_info(yytext, "ASSIGNOP");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <ASSIGNOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return ASSIGNOP;
}

"!" {
    symbol_info *s = new symbol_info(yytext, "NOT");
    yylval = s;
    loglist = "Line no " + to_string(lines) + ": Token <NOT> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return NOT;
}

"("     { loglist = "Line no " + to_string(lines) + ": Token <LPAREN> Lexeme " + yytext + " found\n\n"; outlog << loglist; return LPAREN; }
")"     { loglist = "Line no " + to_string(lines) + ": Token <RPAREN> Lexeme " + yytext + " found\n\n"; outlog << loglist; return RPAREN; }
"{"     { loglist = "Line no " + to_string(lines) + ": Token <LCURL> Lexeme " + yytext + " found\n\n"; outlog << loglist; return LCURL; }
"}"     { loglist = "Line no " + to_string(lines) + ": Token <RCURL> Lexeme " + yytext + " found\n\n"; outlog << loglist; return RCURL; }
"["     { loglist = "Line no " + to_string(lines) + ": Token <LTHIRD> Lexeme " + yytext + " found\n\n"; outlog << loglist; return LTHIRD; }
"]"     { loglist = "Line no " + to_string(lines) + ": Token <RTHIRD> Lexeme " + yytext + " found\n\n"; outlog << loglist; return RTHIRD; }
","     { loglist = "Line no " + to_string(lines) + ": Token <COMMA> Lexeme " + yytext + " found\n\n"; outlog << loglist; return COMMA; }
";"     { loglist = "Line no " + to_string(lines) + ": Token <SEMICOLON> Lexeme " + yytext + " found\n\n"; outlog << loglist; return SEMICOLON; }

. {
    loglist = "Line no " + to_string(lines) + ": Unknown character " + yytext + "\n\n";
    outlog << loglist;
}

%%
 