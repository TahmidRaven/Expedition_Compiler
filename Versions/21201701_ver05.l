%{
#include<bits/stdc++.h>
#include "symbol_info.h"
using namespace std;

int lines = 1;
string loglist;
ofstream outlog;
#define YYSTYPE symbol_info*
%}

%%
[\t\r ]+                 ; // Skip whitespace
"//".*                  ; // Skip single-line comments
"\n"                    { lines++; }

"=="|"<"|">"|"<="|">="|"!=" {
    loglist = "Line no " + to_string(lines) + ": Token <RELOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return RELOP;
}

"=" {
    loglist = "Line no " + to_string(lines) + ": Token <ASSIGNOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return ASSIGNOP;
}

"++" {
    loglist = "Line no " + to_string(lines) + ": Token <INCOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return INCOP;
}

"--" {
    loglist = "Line no " + to_string(lines) + ": Token <DECOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return DECOP;
}

"&&"|"||" {
    loglist = "Line no " + to_string(lines) + ": Token <LOGICOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return LOGICOP;
}

"!" {
    loglist = "Line no " + to_string(lines) + ": Token <NOT> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return NOT;
}

"+"|"-" {
    loglist = "Line no " + to_string(lines) + ": Token <ADDOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return ADDOP;
}

"*"|"/"|"%" {
    loglist = "Line no " + to_string(lines) + ": Token <MULOP> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return MULOP;
}

"(" {
    loglist = "Line no " + to_string(lines) + ": Token <LPAREN> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return LPAREN;
}
")" {
    loglist = "Line no " + to_string(lines) + ": Token <RPAREN> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return RPAREN;
}
"{" {
    loglist = "Line no " + to_string(lines) + ": Token <LCURL> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return LCURL;
}
"}" {
    loglist = "Line no " + to_string(lines) + ": Token <RCURL> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return RCURL;
}
"[" {
    loglist = "Line no " + to_string(lines) + ": Token <LTHIRD> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return LTHIRD;
}
"]" {
    loglist = "Line no " + to_string(lines) + ": Token <RTHIRD> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return RTHIRD;
}
";" {
    loglist = "Line no " + to_string(lines) + ": Token <SEMICOLON> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return SEMICOLON;
}
"," {
    loglist = "Line no " + to_string(lines) + ": Token <COMMA> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return COMMA;
}
":" {
    loglist = "Line no " + to_string(lines) + ": Token <COLON> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    return COLON;
}

[0-9]+"."[0-9]*([eE][-+]?[0-9]+)? | [0-9]+([eE][-+]?[0-9]+) {
    loglist = "Line no " + to_string(lines) + ": Token <CONST_FLOAT> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    yylval = new symbol_info(yytext, "CONST_FLOAT");
    return CONST_FLOAT;
}

[0-9]+ {
    loglist = "Line no " + to_string(lines) + ": Token <CONST_INT> Lexeme " + yytext + " found\n\n";
    outlog << loglist;
    yylval = new symbol_info(yytext, "CONST_INT");
    return CONST_INT;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    string str = yytext;
    if(str == "if")          { loglist = "Line no " + to_string(lines) + ": Token <IF> Lexeme " + str + " found\n\n"; outlog << loglist; return IF; }
    else if(str == "else")   { loglist = "Line no " + to_string(lines) + ": Token <ELSE> Lexeme " + str + " found\n\n"; outlog << loglist; return ELSE; }
    else if(str == "for")    { loglist = "Line no " + to_string(lines) + ": Token <FOR> Lexeme " + str + " found\n\n"; outlog << loglist; return FOR; }
    else if(str == "while")  { loglist = "Line no " + to_string(lines) + ": Token <WHILE> Lexeme " + str + " found\n\n"; outlog << loglist; return WHILE; }
    else if(str == "do")     { loglist = "Line no " + to_string(lines) + ": Token <DO> Lexeme " + str + " found\n\n"; outlog << loglist; return DO; }
    else if(str == "break")  { loglist = "Line no " + to_string(lines) + ": Token <BREAK> Lexeme " + str + " found\n\n"; outlog << loglist; return BREAK; }
    else if(str == "int")    { loglist = "Line no " + to_string(lines) + ": Token <INT> Lexeme " + str + " found\n\n"; outlog << loglist; return INT; }
    else if(str == "char")   { loglist = "Line no " + to_string(lines) + ": Token <CHAR> Lexeme " + str + " found\n\n"; outlog << loglist; return CHAR; }
    else if(str == "float")  { loglist = "Line no " + to_string(lines) + ": Token <FLOAT> Lexeme " + str + " found\n\n"; outlog << loglist; return FLOAT; }
    else if(str == "double") { loglist = "Line no " + to_string(lines) + ": Token <DOUBLE> Lexeme " + str + " found\n\n"; outlog << loglist; return DOUBLE; }
    else if(str == "void")   { loglist = "Line no " + to_string(lines) + ": Token <VOID> Lexeme " + str + " found\n\n"; outlog << loglist; return VOID; }
    else if(str == "return") { loglist = "Line no " + to_string(lines) + ": Token <RETURN> Lexeme " + str + " found\n\n"; outlog << loglist; return RETURN; }
    else if(str == "switch") { loglist = "Line no " + to_string(lines) + ": Token <SWITCH> Lexeme " + str + " found\n\n"; outlog << loglist; return SWITCH; }
    else if(str == "case")   { loglist = "Line no " + to_string(lines) + ": Token <CASE> Lexeme " + str + " found\n\n"; outlog << loglist; return CASE; }
    else if(str == "default"){ loglist = "Line no " + to_string(lines) + ": Token <DEFAULT> Lexeme " + str + " found\n\n"; outlog << loglist; return DEFAULT; }
    else if(str == "continue"){loglist = "Line no " + to_string(lines) + ": Token <CONTINUE> Lexeme " + str + " found\n\n"; outlog << loglist; return CONTINUE; }
    else if(str == "goto")   { loglist = "Line no " + to_string(lines) + ": Token <GOTO> Lexeme " + str + " found\n\n"; outlog << loglist; return GOTO; }
    else if(str == "printf") { loglist = "Line no " + to_string(lines) + ": Token <PRINTF> Lexeme " + str + " found\n\n"; outlog << loglist; return PRINTF; }
    else if(str == "println"){ loglist = "Line no " + to_string(lines) + ": Token <PRINTLN> Lexeme " + str + " found\n\n"; outlog << loglist; return PRINTLN; }
    else {
        loglist = "Line no " + to_string(lines) + ": Token <ID> Lexeme " + str + " found\n\n";
        outlog << loglist;
        yylval = new symbol_info(str, "ID");
        return ID;
    }
}

. {
    loglist = "Line no " + to_string(lines) + ": Unknown character: " + yytext + "\n\n";
    outlog << loglist;
}
%%

int yywrap() {
    return 1;
}
