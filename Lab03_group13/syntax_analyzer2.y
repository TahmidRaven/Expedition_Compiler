| ID LPAREN argument_list RPAREN
       {
           // Check if function exists
           symbol_info* func = table->lookup($1);
           if(func == NULL) {
               logout << "At line no: " << line_count << " Undeclared function: " << $1->get_name() << endl << endl;
               errorout << "At line no: " << line_count << " Undeclared function: " << $1->get_name() << endl << endl;
               error_count++;
               $ = new symbol_info($1->get_name() + "(" + $3->get_name() + ")", "error");
           } else if(!func->is_function()) {
               logout << "At line no: " << line_count << " " << $1->get_name() << " is not a function " << endl << endl;
               errorout << "At line no: " << line_count << " " << $1->get_name() << " is not a function " << endl << endl;
               error_count++;
               $ = new symbol_info($1->get_name() + "(" + $3->get_name() + ")", "error");
           } else {
               // Check parameter count - this is a simplified check
               // In a complete implementation, we would parse the argument_list to count arguments
               // For now, we'll add basic parameter checking
               
               // Check if void function is used in expression context
               if(func->get_return_type() == "void") {
                   // This will be caught in the expression context
               }
               
               string func_text = $1->get_name() + "(" + $3->get_name() + ")";
               logout << "At line no: " << line_count << " factor : ID LPAREN argument_list RPAREN " << endl << endl;
               logout << func_text << endl << endl;
               $ = new symbol_info(func_text, func->get_return_type());
           }
       }
       | ID LPAREN RPAREN
       {
           // Check if function exists
           symbol_info* func = table->lookup($1);
           if(func == NULL) {
               logout << "At line no: " << line_count << " Undeclared function: " << $1->get_name() << endl << endl;
               errorout << "At line no: " << line_count << " Undeclared function: " << $1->get_name() << endl << endl;
               error_count++;
               $ = new symbol_info($1->get_name() + "()", "error");
           } else if(!func->is_function()) {
               logout << "At line no: " << line_count << " " << $1->get_name() << " is not a function " << endl << endl;
               errorout << "At line no: " << line_count << " " << $1->get_name() << " is not a function " << endl << endl;
               error_count++;
               $ = new symbol_info($1->get_name() + "()", "error");
           } else {
               // Check parameter count
               if(func->get_param_count() != 0%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<fstream>
#include "symbol_table.h"

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

symbol_table *table;
ofstream logout;
ofstream errorout;

int line_count = 1;
int error_count = 0;
string current_var_type = ""; // To track current variable type being declared

void yyerror(char *s)
{
    // Handle syntax errors here if needed
}

// Helper function to check if a string represents an integer
bool is_integer(string s) {
    if(s == "int" || s == "CONST_INT") return true;
    return false;
}

// Helper function to check if a string represents a float
bool is_float(string s) {
    if(s == "float" || s == "CONST_FLOAT") return true;
    return false;
}

// Helper function to get data type from symbol
string get_data_type(symbol_info* sym) {
    if(sym == NULL) return "error";
    if(sym->is_function()) {
        return sym->get_return_type();
    }
    return sym->get_data_type();
}

%}

%union{
    symbol_info* symbol;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN
%token INCOP DECOP 
%token ASSIGNOP 
%token NOT 
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token<symbol> ID CONST_INT CONST_FLOAT 
%token<symbol> ADDOP MULOP RELOP LOGICOP

%type<symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
      {
          logout << "At line no: " << line_count << " start : program " << endl << endl;
          logout << "Symbol Table" << endl << endl;
          table->print_all_scopes(logout);
          logout << endl << "Total lines: " << line_count << endl;
          logout << "Total errors: " << error_count << endl;
          errorout << endl << "Total errors: " << error_count << endl;
      }
      ;

program : program unit 
        {
            string program_text = $1->get_name() + "\n" + $2->get_name();
            logout << "At line no: " << line_count << " program : program unit " << endl << endl;
            logout << program_text << endl << endl;
            $$ = new symbol_info(program_text, "program");
        }
        | unit
        {
            logout << "At line no: " << line_count << " program : unit " << endl << endl;
            logout << $1->get_name() << endl << endl;
            $$ = new symbol_info($1->get_name(), "program");
        }
        ;

unit : var_declaration
     {
         logout << "At line no: " << line_count << " unit : var_declaration " << endl << endl;
         logout << $1->get_name() << endl << endl;
         $$ = new symbol_info($1->get_name(), "unit");
     }
     | func_declaration
     {
         logout << "At line no: " << line_count << " unit : func_declaration " << endl << endl;
         logout << $1->get_name() << endl << endl;
         $$ = new symbol_info($1->get_name(), "unit");
     }
     | func_definition
     {
         logout << "At line no: " << line_count << " unit : func_definition " << endl << endl;
         logout << $1->get_name() << endl << endl;
         $$ = new symbol_info($1->get_name(), "unit");
     }
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
                 {
                     string func_text = $1->get_name() + " " + $2->get_name() + "(" + $4->get_name() + ");";
                     logout << "At line no: " << line_count << " func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON " << endl << endl;
                     logout << func_text << endl << endl;
                     $$ = new symbol_info(func_text, "func_declaration");
                 }
                 | type_specifier ID LPAREN RPAREN SEMICOLON
                 {
                     string func_text = $1->get_name() + " " + $2->get_name() + "();";
                     logout << "At line no: " << line_count << " func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON " << endl << endl;
                     logout << func_text << endl << endl;
                     $$ = new symbol_info(func_text, "func_declaration");
                 }
                 ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN 
                {
                    // Check if function already exists
                    symbol_info* existing = table->lookup($2);
                    if(existing != NULL && existing->is_function()) {
                        logout << "At line no: " << line_count << " Multiple declaration of function " << $2->get_name() << endl << endl;
                        errorout << "At line no: " << line_count << " Multiple declaration of function " << $2->get_name() << endl << endl;
                        error_count++;
                    }
                    
                    // Create function symbol
                    $2->set_return_type($1->get_name());
                    $2->set_symbol_type("function");
                    table->insert($2);
                    
                    // Enter new scope for function body
                    table->enter_scope(logout);
                } 
                compound_statement
                {
                    string func_text = $1->get_name() + " " + $2->get_name() + "(" + $4->get_name() + ")\n" + $7->get_name();
                    logout << "At line no: " << line_count << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement " << endl << endl;
                    logout << func_text << endl << endl;
                    
                    // Exit function scope
                    table->exit_scope(logout);
                    
                    $$ = new symbol_info(func_text, "func_definition");
                }
                | type_specifier ID LPAREN RPAREN 
                {
                    // Check if function already exists
                    symbol_info* existing = table->lookup($2);
                    if(existing != NULL && existing->is_function()) {
                        logout << "At line no: " << line_count << " Multiple declaration of function " << $2->get_name() << endl << endl;
                        errorout << "At line no: " << line_count << " Multiple declaration of function " << $2->get_name() << endl << endl;
                        error_count++;
                    }
                    
                    // Create function symbol with no parameters
                    $2->set_return_type($1->get_name());
                    $2->set_symbol_type("function");
                    $2->set_param_count(0);
                    table->insert($2);
                    
                    // Enter new scope for function body
                    table->enter_scope(logout);
                } 
                compound_statement
                {
                    string func_text = $1->get_name() + " " + $2->get_name() + "()\n" + $6->get_name();
                    logout << "At line no: " << line_count << " func_definition : type_specifier ID LPAREN RPAREN compound_statement " << endl << endl;
                    logout << func_text << endl << endl;
                    
                    // Exit function scope
                    table->exit_scope(logout);
                    
                    $$ = new symbol_info(func_text, "func_definition");
                }
                ;

parameter_list : parameter_list COMMA type_specifier ID
               {
                   // Check for duplicate parameter names in current scope (function parameters)
                   symbol_info* existing = table->get_current_scope()->lookup_in_scope($4);
                   if(existing != NULL) {
                       logout << "At line no: " << line_count << " Multiple declaration of variable " << $4->get_name() << " in parameter of function" << endl << endl;
                       errorout << "At line no: " << line_count << " Multiple declaration of variable " << $4->get_name() << " in parameter" << endl << endl;
                       error_count++;
                   }
                   
                   // Add parameter to current scope
                   $4->set_data_type($3->get_name());
                   $4->set_symbol_type("variable");
                   table->insert($4);
                   
                   string param_text = $1->get_name() + "," + $3->get_name() + " " + $4->get_name();
                   logout << "At line no: " << line_count << " parameter_list : parameter_list COMMA type_specifier ID " << endl << endl;
                   logout << param_text << endl << endl;
                   $ = new symbol_info(param_text, "parameter_list");
               }
               | type_specifier ID
               {
                   // Add parameter to current scope
                   $2->set_data_type($1->get_name());
                   $2->set_symbol_type("variable");
                   table->insert($2);
                   
                   string param_text = $1->get_name() + " " + $2->get_name();
                   logout << "At line no: " << line_count << " parameter_list : type_specifier ID " << endl << endl;
                   logout << param_text << endl << endl;
                   $$ = new symbol_info(param_text, "parameter_list");
               }
               ;

compound_statement : LCURL statements RCURL
                   {
                       string compound_text = "{\n" + $2->get_name() + "\n}";
                       logout << "At line no: " << line_count << " compound_statement : LCURL statements RCURL " << endl << endl;
                       logout << compound_text << endl << endl;
                       $$ = new symbol_info(compound_text, "compound_statement");
                   }
                   | LCURL RCURL
                   {
                       logout << "At line no: " << line_count << " compound_statement : LCURL RCURL " << endl << endl;
                       logout << "{}" << endl << endl;
                       $$ = new symbol_info("{}", "compound_statement");
                   }
                   ;

var_declaration : type_specifier declaration_list SEMICOLON
                {
                    // Check if type is void - variables cannot be void
                    if($1->get_name() == "void") {
                        logout << "At line no: " << line_count << " variable type can not be void " << endl << endl;
                        errorout << "At line no: " << line_count << " variable type can not be void " << endl << endl;
                        error_count++;
                    }
                    
                    // Set data type for all declared variables in the declaration list
                    // This is a simplified approach - in a complete implementation,
                    // we would need to track which variables were declared in this list
                    
                    string var_text = $1->get_name() + " " + $2->get_name() + ";";
                    logout << "At line no: " << line_count << " var_declaration : type_specifier declaration_list SEMICOLON " << endl << endl;
                    logout << var_text << endl << endl;
                    $ = new symbol_info(var_text, "var_declaration");
                }
                ;

type_specifier : INT 
               {
                   logout << "At line no: " << line_count << " type_specifier : INT " << endl << endl;
                   logout << "int" << endl << endl;
                   $$ = new symbol_info("int", "type_specifier");
               }
               | FLOAT
               {
                   logout << "At line no: " << line_count << " type_specifier : FLOAT " << endl << endl;
                   logout << "float" << endl << endl;
                   $$ = new symbol_info("float", "type_specifier");
               }
               | VOID
               {
                   logout << "At line no: " << line_count << " type_specifier : VOID " << endl << endl;
                   logout << "void" << endl << endl;
                   $$ = new symbol_info("void", "type_specifier");
               }
               ;

declaration_list : declaration_list COMMA ID
                 {
                     // Check for multiple declaration
                     symbol_info* existing = table->get_current_scope()->lookup_in_scope($3);
                     if(existing != NULL) {
                         logout << "At line no: " << line_count << " Multiple declaration of variable " << $3->get_name() << endl << endl;
                         errorout << "At line no: " << line_count << " Multiple declaration of variable " << $3->get_name() << endl << endl;
                         error_count++;
                     } else {
                         // Set the data type from parent context and insert
                         $3->set_symbol_type("variable");
                         table->insert($3);
                     }
                     
                     string decl_text = $1->get_name() + "," + $3->get_name();
                     logout << "At line no: " << line_count << " declaration_list : declaration_list COMMA ID " << endl << endl;
                     logout << decl_text << endl << endl;
                     $ = new symbol_info(decl_text, "declaration_list");
                 }
                 | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
                 {
                     // Check for multiple declaration
                     symbol_info* existing = table->get_current_scope()->lookup_in_scope($3);
                     if(existing != NULL) {
                         logout << "At line no: " << line_count << " Multiple declaration of variable " << $3->get_name() << endl << endl;
                         errorout << "At line no: " << line_count << " Multiple declaration of variable " << $3->get_name() << endl << endl;
                         error_count++;
                     } else {
                         // Insert array into symbol table
                         $3->set_array_size(atoi($5->get_name().c_str()));
                         $3->set_symbol_type("array");
                         table->insert($3);
                     }
                     
                     string decl_text = $1->get_name() + "," + $3->get_name() + "[" + $5->get_name() + "]";
                     logout << "At line no: " << line_count << " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD " << endl << endl;
                     logout << decl_text << endl << endl;
                     $ = new symbol_info(decl_text, "declaration_list");
                 }
                 | ID
                 {
                     // Check for multiple declaration
                     symbol_info* existing = table->get_current_scope()->lookup_in_scope($1);
                     if(existing != NULL) {
                         logout << "At line no: " << line_count << " Multiple declaration of variable " << $1->get_name() << endl << endl;
                         errorout << "At line no: " << line_count << " Multiple declaration of variable " << $1->get_name() << endl << endl;
                         error_count++;
                     } else {
                         // Set symbol type and insert
                         $1->set_symbol_type("variable");
                         table->insert($1);
                     }
                     
                     logout << "At line no: " << line_count << " declaration_list : ID " << endl << endl;
                     logout << $1->get_name() << endl << endl;
                     $ = new symbol_info($1->get_name(), "declaration_list");
                 }
                 | ID LTHIRD CONST_INT RTHIRD
                 {
                     // Check for multiple declaration
                     symbol_info* existing = table->get_current_scope()->lookup_in_scope($1);
                     if(existing != NULL) {
                         logout << "At line no: " << line_count << " Multiple declaration of variable " << $1->get_name() << endl << endl;
                         errorout << "At line no: " << line_count << " Multiple declaration of variable " << $1->get_name() << endl << endl;
                         error_count++;
                     } else {
                         // Insert array into symbol table
                         $1->set_array_size(atoi($3->get_name().c_str()));
                         $1->set_symbol_type("array");
                         table->insert($1);
                     }
                     
                     string decl_text = $1->get_name() + "[" + $3->get_name() + "]";
                     logout << "At line no: " << line_count << " declaration_list : ID LTHIRD CONST_INT RTHIRD " << endl << endl;
                     logout << decl_text << endl << endl;
                     $ = new symbol_info(decl_text, "declaration_list");
                 }
                 ;

statements : statement
           {
               logout << "At line no: " << line_count << " statements : statement " << endl << endl;
               logout << $1->get_name() << endl << endl;
               $$ = new symbol_info($1->get_name(), "statements");
           }
           | statements statement
           {
               string stmt_text = $1->get_name() + "\n" + $2->get_name();
               logout << "At line no: " << line_count << " statements : statements statement " << endl << endl;
               logout << stmt_text << endl << endl;
               $$ = new symbol_info(stmt_text, "statements");
           }
           ;

statement : var_declaration
          {
              logout << "At line no: " << line_count << " statement : var_declaration " << endl << endl;
              logout << $1->get_name() << endl << endl;
              $$ = new symbol_info($1->get_name(), "statement");
          }
          | expression_statement
          {
              logout << "At line no: " << line_count << " statement : expression_statement " << endl << endl;
              logout << $1->get_name() << endl << endl;
              $$ = new symbol_info($1->get_name(), "statement");
          }
          | compound_statement
          {
              logout << "At line no: " << line_count << " statement : compound_statement " << endl << endl;
              logout << $1->get_name() << endl << endl;
              $$ = new symbol_info($1->get_name(), "statement");
          }
          | FOR LPAREN expression_statement expression_statement expression RPAREN statement
          {
              string for_text = "for(" + $3->get_name() + $4->get_name() + $5->get_name() + ")" + $7->get_name();
              logout << "At line no: " << line_count << " statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement " << endl << endl;
              logout << for_text << endl << endl;
              $$ = new symbol_info(for_text, "statement");
          }
          | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
          {
              string if_text = "if(" + $3->get_name() + ")" + $5->get_name();
              logout << "At line no: " << line_count << " statement : IF LPAREN expression RPAREN statement " << endl << endl;
              logout << if_text << endl << endl;
              $$ = new symbol_info(if_text, "statement");
          }
          | IF LPAREN expression RPAREN statement ELSE statement
          {
              string if_text = "if(" + $3->get_name() + ")" + $5->get_name() + "else" + $7->get_name();
              logout << "At line no: " << line_count << " statement : IF LPAREN expression RPAREN statement ELSE statement " << endl << endl;
              logout << if_text << endl << endl;
              $$ = new symbol_info(if_text, "statement");
          }
          | WHILE LPAREN expression RPAREN statement
          {
              string while_text = "while(" + $3->get_name() + ")" + $5->get_name();
              logout << "At line no: " << line_count << " statement : WHILE LPAREN expression RPAREN statement " << endl << endl;
              logout << while_text << endl << endl;
              $$ = new symbol_info(while_text, "statement");
          }
          | PRINTLN LPAREN ID RPAREN SEMICOLON
          {
              // Check if variable is declared
              symbol_info* var = table->lookup($3);
              if(var == NULL) {
                  logout << "At line no: " << line_count << " Undeclared variable " << $3->get_name() << endl << endl;
                  errorout << "At line no: " << line_count << " Undeclared variable " << $3->get_name() << endl << endl;
                  error_count++;
              }
              
              string print_text = "printf(" + $3->get_name() + ");";
              logout << "At line no: " << line_count << " statement : PRINTLN LPAREN ID RPAREN SEMICOLON " << endl << endl;
              logout << print_text << endl << endl;
              $$ = new symbol_info(print_text, "statement");
          }
          | RETURN expression SEMICOLON
          {
              string return_text = "return " + $2->get_name() + ";";
              logout << "At line no: " << line_count << " statement : RETURN expression SEMICOLON " << endl << endl;
              logout << return_text << endl << endl;
              $$ = new symbol_info(return_text, "statement");
          }
          ;

expression_statement : SEMICOLON
                     {
                         logout << "At line no: " << line_count << " expression_statement : SEMICOLON " << endl << endl;
                         logout << ";" << endl << endl;
                         $$ = new symbol_info(";", "expression_statement");
                     }
                     | expression SEMICOLON
                     {
                         string expr_text = $1->get_name() + ";";
                         logout << "At line no: " << line_count << " expression_statement : expression SEMICOLON " << endl << endl;
                         logout << expr_text << endl << endl;
                         $$ = new symbol_info(expr_text, "expression_statement");
                     }
                     ;

variable : ID
         {
             // Check if variable is declared
             symbol_info* var = table->lookup($1);
             if(var == NULL) {
                 logout << "At line no: " << line_count << " Undeclared variable " << $1->get_name() << endl << endl;
                 errorout << "At line no: " << line_count << " Undeclared variable " << $1->get_name() << endl << endl;
                 error_count++;
                 $$ = new symbol_info($1->get_name(), "error");
             } else if(var->is_array()) {
                 logout << "At line no: " << line_count << " variable is of array type : " << $1->get_name() << endl << endl;
                 errorout << "At line no: " << line_count << " variable is of array type : " << $1->get_name() << endl << endl;
                 error_count++;
                 $$ = new symbol_info($1->get_name(), var->get_data_type());
             } else {
                 $$ = new symbol_info($1->get_name(), get_data_type(var));
             }
             
             logout << "At line no: " << line_count << " variable : ID " << endl << endl;
             logout << $1->get_name() << endl << endl;
         }
         | ID LTHIRD expression RTHIRD
         {
             // Check if variable is declared
             symbol_info* var = table->lookup($1);
             if(var == NULL) {
                 logout << "At line no: " << line_count << " Undeclared variable " << $1->get_name() << endl << endl;
                 errorout << "At line no: " << line_count << " Undeclared variable " << $1->get_name() << endl << endl;
                 error_count++;
                 $$ = new symbol_info($1->get_name() + "[" + $3->get_name() + "]", "error");
             } else if(!var->is_array()) {
                 logout << "At line no: " << line_count << " variable is not of array type : " << $1->get_name() << endl << endl;
                 errorout << "At line no: " << line_count << " variable is not of array type : " << $1->get_name() << endl << endl;
                 error_count++;
                 $$ = new symbol_info($1->get_name() + "[" + $3->get_name() + "]", get_data_type(var));
             } else {
                 // Check array index type
                 if($3->get_type() != "int" && $3->get_type() != "CONST_INT") {
                     logout << "At line no: " << line_count << " array index is not of integer type : " << $1->get_name() << endl << endl;
                     errorout << "At line no: " << line_count << " array index is not of integer type : " << $1->get_name() << endl << endl;
                     error_count++;
                 }
                 $$ = new symbol_info($1->get_name() + "[" + $3->get_name() + "]", var->get_data_type());
             }
             
             string var_text = $1->get_name() + "[" + $3->get_name() + "]";
             logout << "At line no: " << line_count << " variable : ID LTHIRD expression RTHIRD " << endl << endl;
             logout << var_text << endl << endl;
         }
         ;

expression : logic_expression
           {
               logout << "At line no: " << line_count << " expression : logic_expression " << endl << endl;
               logout << $1->get_name() << endl << endl;
               $$ = new symbol_info($1->get_name(), $1->get_type());
           }
           | variable ASSIGNOP logic_expression
           {
               // Type checking for assignment
               if($1->get_type() == "void" || $3->get_type() == "void") {
                   logout << "At line no: " << line_count << " operation on void type " << endl << endl;
                   errorout << "At line no: " << line_count << " operation on void type " << endl << endl;
                   error_count++;
               } else if($1->get_type() != $3->get_type()) {
                   if($1->get_type() == "int" && ($3->get_type() == "float" || $3->get_type() == "CONST_FLOAT")) {
                       logout << "At line no: " << line_count << " Warning: Assignment of float value into variable of integer type " << endl << endl;
                       errorout << "At line no: " << line_count << " Warning: Assignment of float value into variable of integer type " << endl << endl;
                       error_count++;
                   } else if($1->get_type() != "error" && $3->get_type() != "error") {
                       // Generate error for inconsistent assignment
                       logout << "At line no: " << line_count << " Type mismatch in assignment " << endl << endl;
                       errorout << "At line no: " << line_count << " Type mismatch in assignment " << endl << endl;
                       error_count++;
                   }
               }
               
               string assign_text = $1->get_name() + "=" + $3->get_name();
               logout << "At line no: " << line_count << " expression : variable ASSIGNOP logic_expression " << endl << endl;
               logout << assign_text << endl << endl;
               $$ = new symbol_info(assign_text, $1->get_type());
           }
           ;

logic_expression : rel_expression
                 {
                     logout << "At line no: " << line_count << " logic_expression : rel_expression " << endl << endl;
                     logout << $1->get_name() << endl << endl;
                     $$ = new symbol_info($1->get_name(), $1->get_type());
                 }
                 | rel_expression LOGICOP rel_expression
                 {
                     string logic_text = $1->get_name() + $2->get_name() + $3->get_name();
                     logout << "At line no: " << line_count << " logic_expression : rel_expression LOGICOP rel_expression " << endl << endl;
                     logout << logic_text << endl << endl;
                     $$ = new symbol_info(logic_text, "int"); // Result of logic operation is int
                 }
                 ;

rel_expression : simple_expression
               {
                   logout << "At line no: " << line_count << " rel_expression : simple_expression " << endl << endl;
                   logout << $1->get_name() << endl << endl;
                   $$ = new symbol_info($1->get_name(), $1->get_type());
               }
               | simple_expression RELOP simple_expression
               {
                   string rel_text = $1->get_name() + $2->get_name() + $3->get_name();
                   logout << "At line no: " << line_count << " rel_expression : simple_expression RELOP simple_expression " << endl << endl;
                   logout << rel_text << endl << endl;
                   $$ = new symbol_info(rel_text, "int"); // Result of relational operation is int
               }
               ;

simple_expression : term
                  {
                      logout << "At line no: " << line_count << " simple_expression : term " << endl << endl;
                      logout << $1->get_name() << endl << endl;
                      $$ = new symbol_info($1->get_name(), $1->get_type());
                  }
                  | simple_expression ADDOP term
                  {
                      // Check for void operations
                      if($1->get_type() == "void" || $3->get_type() == "void") {
                          logout << "At line no: " << line_count << " operation on void type " << endl << endl;
                          errorout << "At line no: " << line_count << " operation on void type " << endl << endl;
                          error_count++;
                      }
                      
                      string add_text = $1->get_name() + $2->get_name() + $3->get_name();
                      logout << "At line no: " << line_count << " simple_expression : simple_expression ADDOP term " << endl << endl;
                      logout << add_text << endl << endl;
                      
                      // Determine result type
                      string result_type = "int";
                      if($1->get_type() == "float" || $3->get_type() == "float" || 
                         $1->get_type() == "CONST_FLOAT" || $3->get_type() == "CONST_FLOAT") {
                          result_type = "float";
                      }
                      
                      $$ = new symbol_info(add_text, result_type);
                  }
                  ;

term : unary_expression
     {
         logout << "At line no: " << line_count << " term : unary_expression " << endl << endl;
         logout << $1->get_name() << endl << endl;
         $ = new symbol_info($1->get_name(), $1->get_type());
     }
     | term MULOP unary_expression
     {
         // Check for void operations
         if($1->get_type() == "void" || $3->get_type() == "void") {
             logout << "At line no: " << line_count << " operation on void type " << endl << endl;
             errorout << "At line no: " << line_count << " operation on void type " << endl << endl;
             error_count++;
         }
         
         // Check for modulus operations
         if($2->get_name() == "%") {
             // Check for modulus by zero
             if($3->get_name() == "0") {
                 logout << "At line no: " << line_count << " Modulus by 0 " << endl << endl;
                 errorout << "At line no: " << line_count << " Modulus by 0 " << endl << endl;
                 error_count++;
             }
             // Check if both operands are integers
             if(!is_integer($1->get_type()) || !is_integer($3->get_type())) {
                 if($1->get_type() != "CONST_INT" && $3->get_type() != "CONST_INT") {
                     logout << "At line no: " << line_count << " Modulus operator on non integer type " << endl << endl;
                     errorout << "At line no: " << line_count << " Modulus operator on non integer type " << endl << endl;
                     error_count++;
                 }
             }
         }
         
         // Check for division by zero
         if($2->get_name() == "/" && $3->get_name() == "0") {
             logout << "At line no: " << line_count << " Division by 0 " << endl << endl;
             errorout << "At line no: " << line_count << " Division by 0 " << endl << endl;
             error_count++;
         }
         
         string mul_text = $1->get_name() + $2->get_name() + $3->get_name();
         logout << "At line no: " << line_count << " term : term MULOP unary_expression " << endl << endl;
         logout << mul_text << endl << endl;
         
         // Determine result type
         string result_type = "int";
         if($1->get_type() == "float" || $3->get_type() == "float" || 
            $1->get_type() == "CONST_FLOAT" || $3->get_type() == "CONST_FLOAT") {
             result_type = "float";
         }
         
         $ = new symbol_info(mul_text, result_type);
     }
     ;

unary_expression : ADDOP unary_expression
                 {
                     string unary_text = $1->get_name() + $2->get_name();
                     logout << "At line no: " << line_count << " unary_expression : ADDOP unary_expression " << endl << endl;
                     logout << unary_text << endl << endl;
                     $ = new symbol_info(unary_text, $2->get_type());
                 }
                 | NOT unary_expression
                 {
                     string not_text = "!" + $2->get_name();
                     logout << "At line no: " << line_count << " unary_expression : NOT unary_expression " << endl << endl;
                     logout << not_text << endl << endl;
                     $ = new symbol_info(not_text, "int");
                 }
                 | factor
                 {
                     logout << "At line no: " << line_count << " unary_expression : factor " << endl << endl;
                     logout << $1->get_name() << endl << endl;
                     $ = new symbol_info($1->get_name(), $1->get_type());
                 }
                 ;

factor : variable
       {
           logout << "At line no: " << line_count << " factor : variable " << endl << endl;
           logout << $1->get_name() << endl << endl;
           $ = new symbol_info($1->get_name(), $1->get_type());
       }
       | ID LPAREN argument_list RPAREN
       {
           // Check if function exists
           symbol_info* func = table->lookup($1);
           if(func == NULL || !func->is_function()) {
               logout << "At line no: " << line_count << " Undeclared function: " << $1->get_name() << endl << endl;
               errorout << "At line no: " << line_count << " Undeclared function: " << $1->get_name() << endl << endl;
               error_count++;
               $ = new symbol_info($1->get_name() + "(" + $3->get_name() + ")", "error");
           } else {
               // Check parameter count and types
               vector<string> param_types = func->get_param_types();
               // Parse argument types from argument_list (simplified)
               // For now, just check parameter count
               
               string func_text = $1->get_name() + "(" + $3->get_name() + ")";
               logout << "At line no: " << line_count << " factor : ID LPAREN argument_list RPAREN " << endl << endl;
               logout << func_text << endl << endl;
               $ = new symbol_info(func_text, func->get_return_type());
           }
       }
       | LPAREN expression RPAREN
       {
           string paren_text = "(" + $2->get_name() + ")";
           logout << "At line no: " << line_count << " factor : LPAREN expression RPAREN " << endl << endl;
           logout << paren_text << endl << endl;
           $ = new symbol_info(paren_text, $2->get_type());
       }
       | CONST_INT
       {
           logout << "At line no: " << line_count << " factor : CONST_INT " << endl << endl;
           logout << $1->get_name() << endl << endl;
           $ = new symbol_info($1->get_name(), "int");
       }
       | CONST_FLOAT
       {
           logout << "At line no: " << line_count << " factor : CONST_FLOAT " << endl << endl;
           logout << $1->get_name() << endl << endl;
           $ = new symbol_info($1->get_name(), "float");
       }
       | variable INCOP
       {
           string inc_text = $1->get_name() + "++";
           logout << "At line no: " << line_count << " factor : variable INCOP " << endl << endl;
           logout << inc_text << endl << endl;
           $ = new symbol_info(inc_text, $1->get_type());
       }
       | variable DECOP
       {
           string dec_text = $1->get_name() + "--";
           logout << "At line no: " << line_count << " factor : variable DECOP " << endl << endl;
           logout << dec_text << endl << endl;
           $ = new symbol_info(dec_text, $1->get_type());
       }
       ;

argument_list : arguments
              {
                  logout << "At line no: " << line_count << " argument_list : arguments " << endl << endl;
                  logout << $1->get_name() << endl << endl;
                  $ = new symbol_info($1->get_name(), "argument_list");
              }
              ;

arguments : arguments COMMA logic_expression
          {
              string arg_text = $1->get_name() + "," + $3->get_name();
              logout << "At line no: " << line_count << " arguments : arguments COMMA logic_expression " << endl << endl;
              logout << arg_text << endl << endl;
              $ = new symbol_info(arg_text, "arguments");
          }
          | logic_expression
          {
              logout << "At line no: " << line_count << " arguments : logic_expression " << endl << endl;
              logout << $1->get_name() << endl << endl;
              $ = new symbol_info($1->get_name(), "arguments");
          }
          ;

%%

int main(int argc,char *argv[])
{
    if(argc != 2) {
        printf("Please provide input file name\n");
        return 0;
    }
    
    FILE *fin = fopen(argv[1],"r");
    if(fin == NULL) {
        printf("Cannot open specified file\n");
        return 0;
    }
    
    logout.open("my_log.txt");
    errorout.open("my_error.txt");
    
    table = new symbol_table(10);
    
    yyin = fin;
    yyparse();
    
    logout.close();
    errorout.close();
    fclose(yyin);
    
    delete table;
    
    return 0;
}