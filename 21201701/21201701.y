%{
#include "symbol_info.h"
#define YYSTYPE symbol_info*

int yyparse(void);
int yylex(void);

extern FILE *yyin;
ofstream outlog;
int lines = 1;

void yyerror(char *s) {
    outlog << "Syntax Error at line " << lines << ": " << s << endl << endl;
}
%}

%token IF ELSE FOR WHILE INT FLOAT VOID RETURN PRINTLN

%token IF ELSE FOR WHILE RETURN
%token INT FLOAT VOID
%token ID CONST_INT CONST_FLOAT
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token ID CONST_INT CONST_FLOAT
%token ADDOP MULOP INCOP ASSIGNOP RELOP LOGICOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA


%left LOGICOP
%left RELOP
%left ADDOP
%left MULOP
%right NOT
%left INCOP DECOP
%right ASSIGNOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
    {
        outlog << "At line no: " << lines << " start : program" << endl << endl;
    }
    ;

program : program unit
    {
        outlog << "At line no: " << lines << " program : program unit" << endl << endl;
        $$ = new symbol_info($1->getname() + "\n" + $2->getname(), "program");
    }
    | unit
    {
        outlog << "At line no: " << lines << " program : unit" << endl << endl;
        $$ = $1;
    }
    ;

unit : var_declaration
    {
        outlog << "At line no: " << lines << " unit : var_declaration" << endl << endl;
        $$ = $1;
    }
    | func_definition
    {
        outlog << "At line no: " << lines << " unit : func_definition" << endl << endl;
        $$ = $1;
    }
    ;

var_declaration : type_specifier ID SEMICOLON
    {
        outlog << "At line no: " << lines << " var_declaration : type_specifier ID SEMICOLON" << endl << endl;
        $$ = new symbol_info($1->getname() + " " + $2->getname() + ";", "var_decl");
    }
;

func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
    {
        outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement" << endl << endl;
        $$ = new symbol_info($1->getname() + " " + $2->getname() + " (" + $4->getname() + ")\n" + $6->getname(), "func_def");
    }
    | type_specifier ID LPAREN RPAREN compound_statement
    {
        outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN RPAREN compound_statement" << endl << endl;
        $$ = new symbol_info($1->getname() + " " + $2->getname() + "()\n" + $5->getname(), "func_def");
    }
    ;

parameter_list : parameter_list COMMA type_specifier ID
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname() + " " + $4->getname(), "param_list");
    }
    | parameter_list COMMA type_specifier
    {
        $$ = new symbol_info($1->getname() + ", " + $3->getname(), "param_list");
    }
    | type_specifier ID
    {
        $$ = new symbol_info($1->getname() + " " + $2->getname(), "param");
    }
    | type_specifier
    {
        $$ = new symbol_info($1->getname(), "param");
    }
    ;

compound_statement : LCURL statements RCURL
    {
        $$ = new symbol_info("{\n" + $2->getname() + "\n}", "compound");
    }
    | LCURL RCURL
    {
        $$ = new symbol_info("{}", "compound");
    }
    ;

statements : statement
    {
        $$ = $1;
    }
    | statements statement
    {
        $$ = new symbol_info($1->getname() + "\n" + $2->getname(), "statements");
    }
    ;

statement : expression_statement
    {
        $$ = $1;
    }
    | compound_statement
    {
        $$ = $1;
    }
    | FOR LPAREN expression_statement expression_statement expression RPAREN statement
    {
        outlog << "At line no: " << lines << " statement : FOR ( expr_stmt expr_stmt expr ) statement" << endl << endl;
        $$ = new symbol_info("for(" + $3->getname() + $4->getname() + $5->getname() + ")\n" + $7->getname(), "for_stmt");
    }
    | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
    {
        $$ = new symbol_info("if(" + $3->getname() + ")\n" + $5->getname(), "if_stmt");
    }
    | IF LPAREN expression RPAREN statement ELSE statement
    {
        $$ = new symbol_info("if(" + $3->getname() + ")\n" + $5->getname() + "\nelse\n" + $7->getname(), "if_else_stmt");
    }
    | WHILE LPAREN expression RPAREN statement
    {
        $$ = new symbol_info("while(" + $3->getname() + ")\n" + $5->getname(), "while_stmt");
    }
    | RETURN expression SEMICOLON
    {
        $$ = new symbol_info("return " + $2->getname() + ";", "return_stmt");
    }
    ;

expression_statement : SEMICOLON
    {
        $$ = new symbol_info(";", "empty_stmt");
    }
    | expression SEMICOLON
    {
        $$ = new symbol_info($1->getname() + ";", "expr_stmt");
    }
    ;

expression : ID ASSIGNOP expression
    {
        $$ = new symbol_info($1->getname() + " = " + $3->getname(), "assign_expr");
    }
    | expression ADDOP expression
    {
        $$ = new symbol_info($1->getname() + " + " + $3->getname(), "add_expr");
    }
    | expression MULOP expression
    {
        $$ = new symbol_info($1->getname() + " * " + $3->getname(), "mul_expr");
    }
    | expression RELOP expression
    {
        $$ = new symbol_info($1->getname() + " < " + $3->getname(), "rel_expr");
    }
    | expression LOGICOP expression
    {
        $$ = new symbol_info($1->getname() + " && " + $3->getname(), "logic_expr");
    }
    | NOT expression
    {
        $$ = new symbol_info("!" + $2->getname(), "not_expr");
    }
    | LPAREN expression RPAREN
    {
        $$ = new symbol_info("(" + $2->getname() + ")", "group_expr");
    }
    | ID
    {
        $$ = new symbol_info($1->getname(), "id");
    }
    | CONST_INT
    {
        $$ = new symbol_info($1->getname(), "int");
    }
    | CONST_FLOAT
    {
        $$ = new symbol_info($1->getname(), "float");
    }
    ;

type_specifier : INT
    {
        $$ = new symbol_info("int", "type");
    }
    | FLOAT
    {
        $$ = new symbol_info("float", "type");
    }
    | VOID
    {
        $$ = new symbol_info("void", "type");
    }
    ;

%%

int main(int argc, char *argv[])
{
    if(argc != 2) {
        cerr << "Usage: ./a.out <input_file>" << endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");
    outlog.open("my_log.txt", ios::trunc);

    if(yyin == NULL) {
        cerr << "Couldn't open file" << endl;
        return 1;
    }

    yyparse();
    outlog << "Total lines: " << lines << endl;

    outlog.close();
    fclose(yyin);
    return 0;
}
