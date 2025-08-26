%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

int lines = 1;

ofstream outlog;
ofstream errorlog;

// Global symbol table
symbol_table* st;

// Error counter
int error_count = 0;

// Semantic attributes structure
struct Attr {
    string type;      // "int", "float", "void", "error"  
    bool isArray;
    bool isLValue;
    bool isConst;
    int ival;
    float fval;
    
    Attr() {
        type = "error";
        isArray = false;
        isLValue = false;
        isConst = false;
        ival = 0;
        fval = 0.0;
    }
    
    Attr(string t) {
        type = t;
        isArray = false;
        isLValue = false;
        isConst = false;
        ival = 0;
        fval = 0.0;
    }
};

// Variables to store current context information
string current_var_type = "";
vector<string> var_names;
vector<int> array_sizes;

// Function context variables
string current_func_name = "";
string current_return_type = "";
string processing_func_name = "";  // For parameter processing
vector<string> param_types;
vector<string> param_names;

void yyerror(char *s)
{
	outlog<<"At line "<<lines<<" "<<s<<endl<<endl;
}

void log_error(string msg) {
    errorlog << "At line no: " << lines << " " << msg << endl << endl;
    error_count++;
}

string extract_type(string name_with_type) {
    size_t colon_pos = name_with_type.find_last_of(':');
    if(colon_pos != string::npos && colon_pos < name_with_type.length() - 1) {
        return name_with_type.substr(colon_pos + 1);
    }
    return "error";
}

string extract_name(string name_with_type) {
    size_t colon_pos = name_with_type.find_last_of(':');
    if(colon_pos != string::npos) {
        return name_with_type.substr(0, colon_pos);
    }
    return name_with_type;
}

bool is_void_type(string name_with_type) {
    return extract_type(name_with_type) == "void";
}

// Helper function to lookup symbol by name
symbol_info* lookup_symbol(string name) {
    symbol_info temp_symbol(name, "ID");
    return st->lookup(&temp_symbol);
}
bool has_duplicate_param(string param_name) {
    int count = 0;
    for(const string& name : param_names) {
        if(name == param_name) {
            count++;
            if(count > 1) return true;
        }
    }
    return false;
}

// Helper function to parse declaration list and insert variables
void insert_variables_from_declaration(string type_name, string declaration_list) {
    // Check for void variable declarations
    if(type_name == "void") {
        log_error("variable type can not be void");
        return;
    }
    
    // Split declaration_list by commas and process each variable
    stringstream ss(declaration_list);
    string item;
    
    while(getline(ss, item, ',')) {
        // Remove leading/trailing whitespace
        size_t start = item.find_first_not_of(" \t");
        size_t end = item.find_last_not_of(" \t");
        if(start == string::npos) continue;
        item = item.substr(start, end - start + 1);
        
        // Check if it's an array
        size_t bracket_pos = item.find('[');
        if(bracket_pos != string::npos) {
            // Array variable
            string var_name = item.substr(0, bracket_pos);
            size_t close_bracket = item.find(']');
            string size_str = item.substr(bracket_pos + 1, close_bracket - bracket_pos - 1);
            int array_size = stoi(size_str);
            
            symbol_info* var_symbol = new symbol_info(var_name, "ID");
            var_symbol->set_data_type(type_name);
            var_symbol->set_array_size(array_size);
            
            if(!st->insert(var_symbol)) {
                log_error("Multiple declaration of variable " + var_name);
            }
        } else {
            // Regular variable
            symbol_info* var_symbol = new symbol_info(item, "ID");
            var_symbol->set_data_type(type_name);
            var_symbol->set_symbol_type("variable");
            
            if(!st->insert(var_symbol)) {
                log_error("Multiple declaration of variable " + item);
            }
        }
    }
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		// Print the final symbol table
		st->print_all_scopes(outlog);
		
		$$= new symbol_info("","start");
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->getname()+"\n"+$2->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     ;

func_definition : type_specifier ID LPAREN { 
		processing_func_name = $2->getname();
		param_types.clear();
		param_names.clear();
	} parameter_list RPAREN {
		// Set current function context
		current_func_name = $2->getname();
		current_return_type = $1->getname();
		
		// Insert function in symbol table first
		symbol_info* func_symbol = new symbol_info($2->getname(), "ID");
		func_symbol->set_return_type($1->getname());
		
		// Add parameters to function symbol
		for(int i = 0; i < param_types.size(); i++) {
			func_symbol->add_parameter(param_types[i], param_names[i]);
		}
		
		// Check if there's already a symbol with this name (could be variable or function)
		symbol_info* temp_symbol = new symbol_info($2->getname(), "ID");
		symbol_info* existing = st->lookup(temp_symbol);
		if(existing != nullptr) {
			log_error("Multiple declaration of function " + $2->getname());
		} else if(!st->insert(func_symbol)) {
			log_error("Multiple declaration of function " + $2->getname());
		}
		delete temp_symbol;
		
		// Enter new scope for function body
		st->enter_scope(outlog);
		
		// Insert parameters into the new scope
		for(int i = 0; i < param_types.size(); i++) {
			if(!param_names[i].empty()) {
				symbol_info* param_symbol = new symbol_info(param_names[i], "ID");
				param_symbol->set_data_type(param_types[i]);
				st->insert(param_symbol);
			}
		}
	} compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"("+$5->getname()+")\n"<<$8->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$5->getname()+")\n"+$8->getname(),"func_def");	
			
			// Clear function context
			current_func_name = "";
			current_return_type = "";
			processing_func_name = "";
			param_types.clear();
			param_names.clear();
		}
		| type_specifier ID LPAREN { 
			processing_func_name = $2->getname();
		} RPAREN {
			// Set current function context
			current_func_name = $2->getname();
			current_return_type = $1->getname();
			
			// Insert function in symbol table
			symbol_info* func_symbol = new symbol_info($2->getname(), "ID");
			func_symbol->set_return_type($1->getname());
			func_symbol->set_param_count(0);
			
			// Check if there's already a symbol with this name (could be variable or function)
			symbol_info* temp_symbol = new symbol_info($2->getname(), "ID");
			symbol_info* existing = st->lookup(temp_symbol);
			if(existing != nullptr) {
				log_error("Multiple declaration of function " + $2->getname());
			} else if(!st->insert(func_symbol)) {
				log_error("Multiple declaration of function " + $2->getname());
			}
			delete temp_symbol;
			
			// Enter new scope for function body
			st->enter_scope(outlog);
		} compound_statement
		{
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$7->getname(),"func_def");	
			
			// Clear function context
			current_func_name = "";
			current_return_type = "";
			processing_func_name = "";
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<" "<<$4->getname()<<endl<<endl;
					
			$$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param_list");
			
			// Check for duplicate parameter names
			for(const string& name : param_names) {
				if(name == $4->getname()) {
					log_error("Multiple declaration of variable " + $4->getname() + " in parameter of " + processing_func_name);
					break;
				}
			}
			
			// Store parameter information
			param_types.push_back($3->getname());
			param_names.push_back($4->getname());
		}
		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+","+$3->getname(),"param_list");
			
			// Store parameter information (unnamed parameter)
			param_types.push_back($3->getname());
			param_names.push_back("");
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname(),"param_list");
			
			// Store parameter information
			param_types.push_back($1->getname());
			param_names.push_back($2->getname());
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"param_list");
			
			// Store parameter information (unnamed parameter)
			param_types.push_back($1->getname());
			param_names.push_back("");
		}
 		;

compound_statement : LCURL {
			// Enter new scope for every compound statement
			st->enter_scope(outlog);
		} statements RCURL
			{ 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				outlog<<"{\n"+$3->getname()+"\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n"+$3->getname()+"\n}","comp_stmnt");
				
				// Exit scope and print symbol table
				st->exit_scope(outlog);
 		    }
 		    | LCURL {
			// Enter new scope for every compound statement
			st->enter_scope(outlog);
		} RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");
				
				// Exit scope and print symbol table
				st->exit_scope(outlog);
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		 {
			outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+";","var_dec");
			
			// Insert variables into symbol table
			insert_variables_from_declaration($1->getname(), $2->getname());
		 }
 		 ;

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;
			
			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;
			
			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;
			
			$$ = new symbol_info("void","type");
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+","+$3->getname(),"decl_list");
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<"["<<$5->getname()<<"]"<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]","decl_list");
 		  }
 		  |ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"decl_list");
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+"["+$3->getname()+"]","decl_list");
 		  }
 		  ;
 		  

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"stmnts");
	   }
	   ;
	   
statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<"\nelse\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname()+"\nelse\n"+$7->getname(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->getname()<<");"<<endl<<endl; 
			
			// Check if variable is declared
			symbol_info* found = lookup_symbol($3->getname());
			if(found == NULL) {
				log_error("Undeclared variable " + $3->getname());
			}
			
			$$ = new symbol_info("printf("+$3->getname()+");","stmnt");
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->getname()+";","stmnt");
	  }
	  ;
	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->getname()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->getname()+";","expr_stmt");
	        }
			;
	  
variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		// Semantic check: Look up the identifier
		symbol_info* found = lookup_symbol($1->getname());
		if(found == NULL) {
			log_error("Undeclared variable " + $1->getname());
			$$ = new symbol_info($1->getname() + ":error","varbl");
		} else {
			if(found->is_array()) {
				log_error("variable is of array type : " + $1->getname());
				$$ = new symbol_info($1->getname() + ":array_error","varbl");
			} else {
				$$ = new symbol_info($1->getname() + ":" + found->get_data_type(),"varbl");
			}
		}
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
		
		// Semantic check: Look up the identifier
		symbol_info* found = lookup_symbol($1->getname());
		if(found == NULL) {
			log_error("Undeclared variable " + $1->getname());
		} else {
			if(!found->is_array()) {
				log_error("variable is not of array type : " + $1->getname());
			}
			
			// Check if index is integer type
			string index_type = "";
			if($3->getname().find(":int") != string::npos) {
				index_type = "int";
			} else if($3->getname().find(":float") != string::npos) {
				index_type = "float";
				log_error("array index is not of integer type : " + $1->getname());
			} else {
				// Try to determine from the expression content
				if($3->getname().find(".") != string::npos) {
					log_error("array index is not of integer type : " + $1->getname());
				}
			}
		}
		
		string result_type = found ? found->get_data_type() : "error";
		$$ = new symbol_info($1->getname()+"["+$3->getname()+"]:" + result_type,"varbl");
	 }
	 ;
	 
expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"expr");
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;

			// Semantic checks for assignment
			string lhs_type = extract_type($1->getname());
			string rhs_type = extract_type($3->getname());
			
			if(is_void_type($3->getname())) {
				log_error("operation on void type");
			} else if(rhs_type != "error" && rhs_type != "array_error" && lhs_type == "int" && rhs_type == "float") {
				log_error("Warning: Assignment of float value into variable of integer type");
			}
			
			string result_type = (lhs_type != "error" && lhs_type != "array_error") ? lhs_type : "error";
			$$ = new symbol_info(extract_name($1->getname())+"="+extract_name($3->getname()) + ":" + result_type,"expr");
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"lgc_expr");
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			// Check for void operands
			if(is_void_type($1->getname()) || is_void_type($3->getname())) {
				log_error("operation on void type");
			}
			
			// Logical operations result in int
			$$ = new symbol_info(extract_name($1->getname())+$2->getname()+extract_name($3->getname())+":int","lgc_expr");
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"rel_expr");
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			// Check for void operands
			if(is_void_type($1->getname()) || is_void_type($3->getname())) {
				log_error("operation on void type");
			}
			
			// Relational operations result in int
			$$ = new symbol_info(extract_name($1->getname())+$2->getname()+extract_name($3->getname())+":int","rel_expr");
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"simp_expr");
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			// Check for void operands
			if(is_void_type($1->getname()) || is_void_type($3->getname())) {
				log_error("operation on void type");
			}
			
			// Determine result type
			string left_type = extract_type($1->getname());
			string right_type = extract_type($3->getname());
			string result_type = "int";
			if(left_type == "float" || right_type == "float") {
				result_type = "float";
			}
			if(left_type == "error" || right_type == "error") {
				result_type = "error";
			}
			
			$$ = new symbol_info(extract_name($1->getname())+$2->getname()+extract_name($3->getname())+":"+result_type,"simp_expr");
	      }
		  ;
					
term :	unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"term");
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			// Semantic checks for arithmetic operations
			string left_type = extract_type($1->getname());
			string right_type = extract_type($3->getname());
			string op = $2->getname();
			
			// Check for void operands
			if(is_void_type($1->getname()) || is_void_type($3->getname())) {
				log_error("operation on void type");
			}
			
			// Check for modulus operator
			if(op == "%") {
				if(left_type != "int" || right_type != "int") {
					log_error("Modulus operator on non integer type");
				}
				
				// Check for modulus by zero (if right operand is a constant)
				string right_name = extract_name($3->getname());
				if(right_name == "0") {
					log_error("Modulus by 0");
				}
			}
			
			// Determine result type
			string result_type = "int";
			if(left_type == "float" || right_type == "float") {
				result_type = "float";
			}
			if(left_type == "error" || right_type == "error") {
				result_type = "error";
			}
			
			// If there was a modulus error, mark the result as error to prevent further assignment warnings  
			if(op == "%" && (left_type != "int" || right_type != "int" || $3->get_name() == "0")) {
				result_type = "error";
			}
			
			$$ = new symbol_info(extract_name($1->getname())+$2->getname()+extract_name($3->getname())+":"+result_type,"term");
	 }
     ;

unary_expression : ADDOP unary_expression
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<endl<<endl;
			
			// Check for void operand
			if(is_void_type($2->getname())) {
				log_error("operation on void type");
			}
			
			$$ = new symbol_info($1->getname()+$2->getname(),"un_expr");
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->getname()<<endl<<endl;
			
			// Check for void operand
			if(is_void_type($2->getname())) {
				log_error("operation on void type");
			}
			
			// NOT operation results in int
			$$ = new symbol_info("!"+extract_name($2->getname())+":int","un_expr");
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"un_expr");
	     }
		 ;
	
factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->getname()<<"("<<$3->getname()<<")"<<endl<<endl;

		// Semantic check: Look up the function
		symbol_info* found = lookup_symbol($1->getname());
		if(found == NULL) {
			log_error("Undeclared function: " + $1->getname());
			$$ = new symbol_info($1->getname()+"("+extract_name($3->getname())+"):error","fctr");
		} else {
			if(!found->is_function()) {
				log_error("Undeclared function: " + $1->getname());
				$$ = new symbol_info($1->getname()+"("+extract_name($3->getname())+"):error","fctr");
			} else {
				// Check argument count and types
				vector<string> expected_params = found->get_param_types();
				
				// Parse argument list to get actual argument types
				vector<string> actual_args;
				if($3->getname() != "") {
					stringstream ss($3->getname()); // Use full name:type format, not just extract_name
					string arg;
					while(getline(ss, arg, ',')) {
						actual_args.push_back(arg);
					}
				}
				
				// Check argument count
				if(actual_args.size() != expected_params.size()) {
					log_error("Inconsistencies in number of arguments in function call: " + $1->getname());
				} else {
					// Check each argument type
					for(int i = 0; i < actual_args.size(); i++) {
						string actual_type = extract_type(actual_args[i]);
						// Skip type mismatch if there was already an array error or other error
						if(actual_type != "array_error" && actual_type != "error" && actual_type != expected_params[i]) {
							log_error("argument " + to_string(i+1) + " type mismatch in function call: " + $1->getname());
						}
					}
				}
				
				string return_type = found->get_return_type();
				$$ = new symbol_info($1->getname()+"("+extract_name($3->getname())+")" + ":" + return_type,"fctr");
			}
		}
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->getname()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->getname()+")","fctr");
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+":int","fctr");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+":float","fctr");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->getname()<<"++"<<endl<<endl;
		
		string var_type = extract_type($1->getname());
		$$ = new symbol_info(extract_name($1->getname())+"++" + ":" + var_type,"fctr");
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->getname()<<"--"<<endl<<endl;
		
		string var_type = extract_type($1->getname());
		$$ = new symbol_info(extract_name($1->getname())+"--" + ":" + var_type,"fctr");
	}
	;
	
argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->getname()<<endl<<endl;
						
					$$ = new symbol_info($1->getname(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
				
				// Collect argument types for function call checking
				string arg_with_type = $1->getname() + "," + $3->getname();
				$$ = new symbol_info(arg_with_type,"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<endl<<endl;
				
				$$ = new symbol_info($1->getname(),"arg");
		  }
	      ;
 

%%

int main(int argc, char *argv[])
{

	cout << endl;
	cout << "===================================================" << endl;
	cout << "|Expedition Compiler  For All Those Who Come After|" << endl;
	cout << "|      Created by TahmidRaven & MehediTorno       |" << endl;
	cout << "===================================================" << endl;
	cout << endl;


	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("my_log.txt", ios::trunc);
	errorlog.open("my_error.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
	
	// Initialize symbol table with 10 buckets
	st = new symbol_table(10);
	outlog << "New ScopeTable with ID 1 created" << endl << endl;

	yyparse();
	
	outlog<<endl<<"Total lines in Expedition Compiler : " <<lines<<endl;
	outlog<< "Total errors in Expedition Compiler : " << error_count << endl << endl;

	
	// Write error summary to error log
	errorlog << "Total errors: " << error_count << endl << endl;
	
	// Cleanup
	delete st;
	
	outlog.close();
	errorlog.close();
	fclose(yyin);
	
	return 0;
}