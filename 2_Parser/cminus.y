/****************************************************/
/* File: cminus.y                                   */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static TreeNode * savedTree; /* stores syntax tree for later return, AST Root */
static int yyerror(char * message);
static int yylex(void); // added 11/2/11 to ensure no conflict with lex
%}

%token IF WHILE RETURN INT VOID
%nonassoc RPAREN
%nonassoc ELSE 
%token ID NUM
%token EQ NE LT LE GT GE LPAREN LBRACE RBRACE LCURLY RCURLY COMMA SEMI
%token ERROR 
%left PLUS MINUS 
%left TIMES OVER 
%right ASSIGN

%% /* Grammar for C- */

program             : declaration_list { savedTree = $1; } 
                    ;
declaration_list    : declaration_list declaration
                         {
                              YYSTYPE t = $1; 
                              if (t != NULL)
                              {
                                   while (t->sibling != NULL) t = t->sibling;
                                   t->sibling = $2; 
                                   $$ = $1; 
                              } 
                              else $$ = $2;
                         }
                    | declaration { $$ = $1; }
                    ;
declaration         : var_declaration { $$ = $1; }
                    | fun_declaration { $$ = $1; }
                    ;
var_declaration     : type_specifier identifier SEMI
                         { 
                              $$ = newTreeNode(VariableDecl);
                              $$->lineno = $2->lineno;
                              $$->type = $1->type;
                              $$->name = $2->name;
                              free($1); free($2);
                         }
                    | type_specifier identifier LBRACE number RBRACE SEMI
                         { 
                              $$ = newTreeNode(VariableDecl);
                              $$->lineno = $2->lineno;
                              if ($1->type == Integer) $$->type = IntegerArray;
                              else if ($1->type == Void) $$->type = VoidArray;
                              else $$->type = None;
                              $$->name = $2->name;
                              $$->child[0] = $4; /* array size */
                              free($1); free($2);
                         }
                    ;
type_specifier      : INT  { $$ = newTreeNode(TypeSpecifier); $$->lineno = lineno; $$->type = Integer; }
                    | VOID { $$ = newTreeNode(TypeSpecifier); $$->lineno = lineno; $$->type = Void; }
                    | INT LBRACE RBRACE
                         {
                              $$ = newTreeNode(TypeSpecifier);
                              $$->lineno = lineno;
                              $$->type = IntegerArray;
                         }
                    | VOID LBRACE RBRACE
                         {
                              $$ = newTreeNode(TypeSpecifier);
                              $$->lineno = lineno;
                              $$->type = VoidArray;
                         }
                    ;
fun_declaration     : type_specifier identifier LPAREN params RPAREN compound_stmt
                         { 

                              $$ = newTreeNode(FunctionDecl);
                              $$->lineno = $2->lineno;
                              $$->type = $1->type;
                              $$->name = $2->name;
                              $$->child[0] = $4; /* params */
                              $$->child[1] = $6; /* compound_stmt */
                              free($1); free($2);
                         }
                    ;
params              : param_list { $$ = $1; }
                    | VOID
                         {
                              $$ = newTreeNode(Params);
                              $$->lineno = lineno;
                              $$->flag = TRUE;
                         }
                    ;
param_list          : param_list COMMA param
                         {
						/* declaration_list 참고 */	
                              YYSTYPE t = $1;
                              if (t != NULL){
                                   while (t->sibling != NULL) t = t->sibling;
                                   t->sibling = $3;
                                   $$ = $1;
                              }
                              else $$ = $3;
                         }
                    | param { $$ = $1; }
                    ;
param               : type_specifier identifier
                         {
						$$ = newTreeNode(Params);
                              $$->lineno = $2->lineno;
                              $$->type = $1->type;
                              $$->name = $2->name;
                              free($1); free($2);
                         }
                    | type_specifier identifier LBRACE RBRACE
                         { 
                              $$ = newTreeNode(Params);
                              $$->lineno = $2->lineno;
                              if ($1->type == Integer) $$->type = IntegerArray;
                              else if ($1->type == Void) $$->type = VoidArray;
                              else $$->type = None;
                              $$->name = $2->name;
                              free($1); free($2);
                         }
                    ;
compound_stmt       : LCURLY local_declarations statement_list RCURLY
                         { 
                              $$ = newTreeNode(CompoundStmt);
                              $$->lineno = lineno;
                              $$->child[0] = $2;
                              $$->child[1] = $3;
                         }
                    ;
local_declarations  : local_declarations var_declaration
                         {
                              YYSTYPE t = $1;
                              if (t != NULL)
                              {
                                   while (t->sibling != NULL) t = t->sibling;
                                   t->sibling = $2; 
                                   $$ = $1; 
                              }
                              else $$ = $2;
                         }
                    | empty { }
                    ;
statement_list      : statement_list statement
                         { 
						YYSTYPE t = $1;
                              if (t != NULL)
                              {
                                   while (t->sibling != NULL) t = t->sibling;
                                   t->sibling = $2;
                                   $$ = $1;
                              }
                              else $$ = $2;
                         }
                    | empty {  }
                    ;
statement			: selection_stmt { $$ = $1; } /* TODO: dangling else problem */
                    | expression_stmt { $$ = $1; }
                    | compound_stmt { $$ = $1; }
                    | iteration_stmt { $$ = $1; }
                    | return_stmt { $$ = $1; }
					;
selection_stmt		: IF LPAREN expression RPAREN statement ELSE statement /* TODO: dangling else problem */
					{
						/* TODO: child[0] = conditional_expression(maybe simple) , child[1] = statement, child[2] = statement */	
					}
                    | IF LPAREN expression RPAREN statement 
					{
						/* TODO: child[0] = conditional_expression(maybe simple), child[1] = statement */
					}
                    ;
expression_stmt     : expression SEMI { }
                    | SEMI {  }
                    ;
iteration_stmt      : WHILE LPAREN expression RPAREN statement
                         { 
						/* TODO: child[0] = conditional_expression(maybe simple), child[1] = statement */	
                         }
                    ;
return_stmt         : RETURN SEMI 
					{ 
							
					}
                    | RETURN expression SEMI
                         { 
                              /* TODO: child[0] = return_expression */
                         }
                    ;
expression          : var ASSIGN expression
                         { 
                              /* TODO: child[0] = var, child[1] = expression */
                         }
                    | simple_expression { $$ = $1; }
                    ;
var                 : identifier
                         { 
							
                         }
                    | identifier LBRACE expression RBRACE
                         {
						/* variable accessing & array indexing */
                              /* TODO: child[0] = expression(maybe simple??) */
                         }
                    ;
simple_expression   : additive_expression relop additive_expression
                         { 
						/* add left-hand-side(lhs), right-hand-side(rhs) as children */
                              /* TODO: child[0] = lhs, child[1] = rhs */
                         }
                    | additive_expression { $$ = $1; }
                    ;
relop               : LE { $$ = newTreeNode(Opcode); $$->lineno = lineno; $$->opcode = LE; }
                    | LT { $$ = newTreeNode(Opcode); $$->lineno = lineno; $$->opcode = LT; }
                    | GT {  }
                    | GE {  }
                    | EQ {  }
                    | NE {  }
                    ;
additive_expression : additive_expression addop term
                         { 
							
                         }
				| term {  }
addop			: PLUS  {  }
				| MINUS {  }
					;
term                : term mulop factor
					{
							
					}
				| factor {  }
				;
mulop               : TIMES {  }
				| OVER  {  }
				;
factor              : LPAREN expression RPAREN {  }
                    | var {  }
                    | call {  }
                    | number {  }
                    ;
call                : identifier LPAREN args RPAREN
                         { 
						/* TODO: $$->name = $1->name, child[0] = args */
                         }
                    ;
args                : arg_list {  }
                    | empty {  }
                    ;
arg_list            : arg_list COMMA expression
                         {
                              YYSTYPE t = $1; 
                              if (t != NULL)
                              { 
                                   while (t->sibling != NULL) t = t->sibling;
                                   t->sibling = $3; 
                                   $$ = $1; 
                              } 
                              else $$ = $3;
                         }
                    | expression { $$ = $1; }
                    ;
identifier		: ID
                         {
                              $$ = newTreeNode(Indentifier);
                              $$->lineno = lineno;
                              $$->name = copyString(tokenString);
                         }
				;
number			: NUM
                         {
                              $$ = newTreeNode(ConstExpr);
                              $$->lineno = lineno;
                              $$->val = atoi(tokenString);
                         }
				;
empty               : { $$ = NULL;}
                    ;

%%

int yyerror(char * message)
{
	fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
	fprintf(listing,"Current token: ");
	printToken(yychar,tokenString);
	Error = TRUE;
	return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ 
	yyparse();
	return savedTree;
}
