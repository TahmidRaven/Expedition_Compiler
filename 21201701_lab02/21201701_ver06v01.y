
%{

#include "symbol_info.h"
#include "symbol_table.h"

#define YYSTYPE symbol_info*

int yyparse(void);
int yylex(void);
void yyerror(char *);

extern FILE *yyin;

ofstream outlog;

int lines = 1;
string current_type;
symbol_table symtab;

%}

%token ID CONST_INT CONST_FLOAT
%token ADDOP MULOP INCOP DECOP ASSIGNOP RELOP LOGICOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA COLON SEMICOLON
%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE GOTO PRINTF PRINTLN

%nonassoc ELSE_LOWER
%nonassoc ELSE

%%
// inject rest of rules later manually if needed...

%%

void yyerror(char *s)
{
    outlog<<"At line no: "<<lines<<" "<<s<<endl<<endl;
}

int main(int argc, char *argv[])
{
cout << endl;
cout << "===================================================" << endl;
cout << "|Expedition Compiler  For All Those Who Come After|" << endl;
cout << "|      Created by TahmidRaven & MehediTorno       |" << endl;
cout << "===================================================" << endl;

	if(argc != 2) 
	{
        cout<<"Please provide input file name"<<endl;
        return 0;
	}

	yyin = fopen(argv[1], "r");
	outlog.open("my_log.txt", ios::trunc);

	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}

	symtab.enter_scope(); // Global scope
	yyparse();
	symtab.exit_scope(outlog);

	outlog<<"Total lines: "<<lines<<endl;
	outlog.close();
	fclose(yyin);

	return 0;
}
