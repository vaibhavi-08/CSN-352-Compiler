/* grammar.y */
%{
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <iomanip>
#include <sstream>
#include <fstream>

using namespace std;

// Existing symbol table and other declarations
extern unordered_map<string, string> symtab;
extern vector<string> program;
extern vector<pair<string, int>> error;
extern int line;
extern bool iserror;



extern unordered_map<string, string> new_symtab;

// current Type declaration
string currentType = "";

int yylex();
void yyerror(const char *s);

void add_to_token_table(string token, string type);

%}

%union { // Define the union for token values. Add necessary types.
    int ival;       // Integer value
    char *sval;    // String value (e.g., for identifiers)
    // You might need other types depending on your grammar (e.g., float, double)
}

%token <sval> IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID BOOL
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%type <sval> primary_expression postfix_expression argument_expression_list unary_expression
%type <sval> cast_expression multiplicative_expression additive_expression shift_expression
%type <sval> relational_expression equality_expression and_expression exclusive_or_expression
%type <sval> inclusive_or_expression logical_and_expression logical_or_expression conditional_expression
%type <sval> assignment_expression constant_expression expression declaration
%type <sval> declaration_specifiers init_declarator_list init_declarator storage_class_specifier
%type <sval> type_specifier struct_or_union_specifier struct_or_union struct_declaration_list
%type <sval> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator
%type <sval> enum_specifier enumerator_list enumerator type_qualifier declarator direct_declarator
%type <sval> pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration
%type <sval> identifier_list type_name abstract_declarator direct_abstract_declarator initializer
%type <sval> initializer_list statement labeled_statement compound_statement declaration_list
%type <sval> statement_list expression_statement selection_statement iteration_statement
%type <sval> jump_statement translation_unit external_declaration function_definition assignment_operator

%start translation_unit

%%

primary_expression
    : IDENTIFIER
        { $$ = $1; }
    | CONSTANT
        { $$ = $1; }
    | STRING_LITERAL
        { $$ = $1; }
    | '(' expression ')'
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "(%s)", $2);
            $$ = temp;
        }
    ;

postfix_expression
    : primary_expression
        { $$ = $1; }
    | postfix_expression '[' expression ']'
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s[%s]", $1, $3);
            $$ = temp;
        }
    | postfix_expression '(' ')'
        {
            char *temp = malloc(strlen($1) + 3);
            sprintf(temp, "%s()", $1);
            $$ = temp;
        }
    | postfix_expression '(' argument_expression_list ')'
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s(%s)", $1, $3);
            $$ = temp;
        }
    | postfix_expression '.' IDENTIFIER
        {
            char *temp = malloc(strlen($1) + strlen($3) + 2);
            sprintf(temp, "%s.%s", $1, $3);
            $$ = temp;
        }
    | postfix_expression PTR_OP IDENTIFIER
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s->%s", $1, $3);
            $$ = temp;
        }
    | postfix_expression INC_OP
        {
            char *temp = malloc(strlen($1) + 3);
            sprintf(temp, "%s++", $1);
            $$ = temp;
        }
    | postfix_expression DEC_OP
        {
            char *temp = malloc(strlen($1) + 3);
            sprintf(temp, "%s--", $1);
            $$ = temp;
        }
    ;

argument_expression_list
    : assignment_expression
        { $$ = $1; }
    | argument_expression_list ',' assignment_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s, %s", $1, $3);
            $$ = temp;
        }
    ;

unary_expression
    : postfix_expression
        { $$ = $1; }
    | INC_OP unary_expression
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "++%s", $2);
            $$ = temp;
        }
    | DEC_OP unary_expression
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "--%s", $2);
            $$ = temp;
        }
    | unary_operator cast_expression
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s%s", $1, $2);
            $$ = temp;
        }
    | SIZEOF unary_expression
        {
            char *temp = malloc(strlen($2) + 8);
            sprintf(temp, "sizeof %s", $2);
            $$ = temp;
        }
    | SIZEOF '(' type_name ')'
        {
            char *temp = malloc(strlen($3) + 9);
            sprintf(temp, "sizeof(%s)", $3);
            $$ = temp;
        }
    ;

unary_operator
    : '&' { $$ = "&"; currentType = "POINTER_TO_" + currentType; }
    | '*' { $$ = "*"; 
            if (currentType.substr(0, 11) == "POINTER_TO_") 
                currentType = currentType.substr(11);
            else
                currentType = "POINTER_TO_" + currentType; 
          }
    | '+' { $$ = "+"; /* No change to currentType */ }
    | '-' { $$ = "-"; /* No change to currentType */ }
    | '~' { $$ = "~"; currentType = "INT"; } // Bitwise NOT is typically used with integral types
    | '!' { $$ = "!"; currentType = "INT"; } // Logical NOT typically results in a boolean (int in C)
    ;


cast_expression
    : unary_expression
        { $$ = $1; }
    | '(' type_name ')' cast_expression
        {
            char *temp = malloc(strlen($2) + strlen($4) + 4);
            sprintf(temp, "(%s)%s", $2, $4);
            $$ = temp;
        }
    ;

multiplicative_expression
    : cast_expression
        { $$ = $1; }
    | multiplicative_expression '*' cast_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 4);
            sprintf(temp, "%s * %s", $1, $3);
            $$ = temp;
        }
    | multiplicative_expression '/' cast_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 4);
            sprintf(temp, "%s / %s", $1, $3);
            $$ = temp;
        }
    | multiplicative_expression '%' cast_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 4);
            sprintf(temp, "%s %% %s", $1, $3);
            $$ = temp;
        }
    ;

additive_expression
    : multiplicative_expression
        { $$ = $1; }
    | additive_expression '+' multiplicative_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 4);
            sprintf(temp, "%s + %s", $1, $3);
            $$ = temp;
        }
    | additive_expression '-' multiplicative_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 4);
            sprintf(temp, "%s - %s", $1, $3);
            $$ = temp;
        }
    ;

shift_expression
    : additive_expression
        { $$ = $1; }
    | shift_expression LEFT_OP additive_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 5);
            sprintf(temp, "%s << %s", $1, $3);
            $$ = temp;
        }
    | shift_expression RIGHT_OP additive_expression
        {
            char *temp = malloc(strlen($1) + strlen($3) + 5);
            sprintf(temp, "%s >> %s", $1, $3);
            $$ = temp;
        }
    ;

relational_expression
    : shift_expression
        { $$ = $1; /* Type remains unchanged */ }
    | relational_expression '<' shift_expression
        { $$ = "INT"; currentType = "INT"; /* Relational operations result in a boolean (int in C) */ }
    | relational_expression '>' shift_expression
        { $$ = "INT"; currentType = "INT"; /* Relational operations result in a boolean (int in C) */ }
    | relational_expression LE_OP shift_expression
        { $$ = "INT"; currentType = "INT"; /* Relational operations result in a boolean (int in C) */ }
    | relational_expression GE_OP shift_expression
        { $$ = "INT"; currentType = "INT"; /* Relational operations result in a boolean (int in C) */ }
    ;


equality_expression
    : relational_expression
        { $$ = $1; /* Type remains unchanged */ }
    | equality_expression EQ_OP relational_expression
        { $$ = "INT"; currentType = "INT"; /* Equality operations result in a boolean (int in C) */ }
    | equality_expression NE_OP relational_expression
        { $$ = "INT"; currentType = "INT"; /* Equality operations result in a boolean (int in C) */ }
    ;

and_expression
    : equality_expression
        { $$ = $1; /* Type remains unchanged */ }
    | and_expression '&' equality_expression
        { 
            $$ = "INT"; 
            currentType = "INT"; 
            /* Bitwise AND typically results in an integer type */
        }
    ;

exclusive_or_expression
    : and_expression
        { $$ = $1; /* Type remains unchanged */ }
    | exclusive_or_expression '^' and_expression
        { 
            $$ = "INT"; 
            currentType = "INT"; 
            /* Bitwise XOR typically results in an integer type */
        }
    ;

inclusive_or_expression
    : exclusive_or_expression
        { $$ = $1; /* Type remains unchanged */ }
    | inclusive_or_expression '|' exclusive_or_expression
        { 
            $$ = "INT"; 
            currentType = "INT"; 
            /* Bitwise OR typically results in an integer type */
        }
    ;


logical_and_expression
    : inclusive_or_expression
        { $$ = $1; /* Type remains unchanged */ }
    | logical_and_expression AND_OP inclusive_or_expression
        { 
            $$ = "INT"; 
            currentType = "INT"; 
            /* Logical AND results in a boolean (int in C) */
        }
    ;

logical_or_expression
    : logical_and_expression
        { $$ = $1; /* Type remains unchanged */ }
    | logical_or_expression OR_OP logical_and_expression
        { 
            $$ = "INT"; 
            currentType = "INT"; 
            /* Logical OR results in a boolean (int in C) */
        }
    ;

conditional_expression
    : logical_or_expression
        { $$ = $1; /* Type remains unchanged */ }
    | logical_or_expression '?' expression ':' conditional_expression
        { 
            /* The type of a conditional expression is the common type of its true and false expressions */
            /* For simplicity, we'll just use the type of the true expression */
            $$ = $3; 
            currentType = $3;
        }
    ;

assignment_expression
    : conditional_expression
        { $$ = $1; /* Type remains unchanged */ }
    | unary_expression assignment_operator assignment_expression
        { 
            /* The type of an assignment expression is the type of the left-hand side (unary_expression) */
            $$ = $1; 
            currentType = $1;
        }
    ;


assignment_operator
    : '='           { $$ = "="; /* No change to currentType */ }
    | MUL_ASSIGN    { $$ = "*="; /* No change to currentType */ }
    | DIV_ASSIGN    { $$ = "/="; /* No change to currentType */ }
    | MOD_ASSIGN    { $$ = "%="; currentType = "INT"; } // Modulo typically results in an integer
    | ADD_ASSIGN    { $$ = "+="; /* No change to currentType */ }
    | SUB_ASSIGN    { $$ = "-="; /* No change to currentType */ }
    | LEFT_ASSIGN   { $$ = "<<="; currentType = "INT"; } // Bit shifting typically results in an integer
    | RIGHT_ASSIGN  { $$ = ">>="; currentType = "INT"; } // Bit shifting typically results in an integer
    | AND_ASSIGN    { $$ = "&="; currentType = "INT"; } // Bitwise AND typically results in an integer
    | XOR_ASSIGN    { $$ = "^="; currentType = "INT"; } // Bitwise XOR typically results in an integer
    | OR_ASSIGN     { $$ = "|="; currentType = "INT"; } // Bitwise OR typically results in an integer
    ;

expression
    : assignment_expression
        { $$ = $1; }
    | expression ',' assignment_expression
        { $$ = $3; /* The type of the expression is the type of the last assignment */ }
    ;

constant_expression
    : conditional_expression
        { $$ = $1; }
    ;

declaration
    : declaration_specifiers ';'
        { $$ = $1; }
    | declaration_specifiers init_declarator_list ';'
        { $$ = $1; /* The type of the declaration is determined by its specifiers */ }
    ;

declaration_specifiers
    : storage_class_specifier
        { $$ = $1; currentType = $1; }
    | storage_class_specifier declaration_specifiers
        { $$ = $2; currentType = $2; /* The type is determined by the last specifier */ }
    | type_specifier
        { $$ = $1; currentType = $1; }
    | type_specifier declaration_specifiers
        { $$ = $1; currentType = $1; /* The type is determined by the first type specifier */ }
    | type_qualifier
        { $$ = $1; /* Type qualifiers don't change the base type */ }
    | type_qualifier declaration_specifiers
        { $$ = $2; /* The type is determined by the declaration specifiers */ }
    ;

init_declarator_list
    : init_declarator
        { $$ = $1; }
    | init_declarator_list ',' init_declarator
        { $$ = $3; /* The type of the list is the type of the last declarator */ }
    ;

init_declarator
    : declarator
        { $$ = $1; }
    | declarator '=' initializer
        { 
            $$ = $1; 
            /* Here you might want to check if the declarator type matches the initializer type */
        }
    ;

storage_class_specifier
    : TYPEDEF   { $$ = strdup("TYPEDEF"); }
    | EXTERN    { $$ = strdup("EXTERN"); }
    | STATIC    { $$ = strdup("STATIC"); }
    | AUTO      { $$ = strdup("AUTO"); }
    | REGISTER  { $$ = strdup("REGISTER"); }
    ;

type_specifier
	: VOID   { currentType = "VOID"; }
	| CHAR   { currentType = "CHAR"; }
	| SHORT  { currentType = "SHORT"; }
	| INT    { currentType = "INT"; }
	| LONG   { currentType = "LONG"; }
	| FLOAT  { currentType = "FLOAT"; }
	| DOUBLE { currentType = "DOUBLE"; }
	| SIGNED { currentType = "SIGNED"; }
	| UNSIGNED { currentType = "UNSIGNED"; }
	| struct_or_union_specifier { currentType = "STRUCT"; } // Simplified, you might want to handle this more specifically
	| enum_specifier { currentType = "ENUM"; } // Simplified, you might want to handle this more specifically
	| TYPE_NAME { currentType = "TYPE_NAME"; } // You might want to handle this differently depending on your needs
	;


struct_or_union_specifier
    : struct_or_union IDENTIFIER '{' struct_declaration_list '}'
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
            currentType = $$;
        }
    | struct_or_union '{' struct_declaration_list '}'
        {
            $$ = $1;
            currentType = $$;
        }
    | struct_or_union IDENTIFIER
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
            currentType = $$;
        }
    ;

struct_or_union
    : STRUCT { $$ = strdup("STRUCT"); }
    | UNION  { $$ = strdup("UNION"); }
    ;

struct_declaration_list
    : struct_declaration
        { $$ = $1; }
    | struct_declaration_list struct_declaration
        { $$ = $2; /* The type of the list is the type of the last declaration */ }
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list ';'
        { 
            $$ = $1; 
            /* Here you might want to associate the type ($1) with each declarator in the list */
        }
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list
        { 
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
            currentType = $$;
        }
    | type_specifier
        { 
            $$ = $1; 
            currentType = $$;
        }
    | type_qualifier specifier_qualifier_list
        { 
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
            /* Type qualifiers don't change currentType */
        }
    | type_qualifier
        { 
            $$ = $1; 
            /* Type qualifiers don't change currentType */
        }
    ;

struct_declarator_list
    : struct_declarator
        { $$ = $1; }
    | struct_declarator_list ',' struct_declarator
        { $$ = $3; /* The type of the list is the type of the last declarator */ }
    ;

struct_declarator
    : declarator
        { $$ = $1; }
    | ':' constant_expression
        { $$ = strdup("BITFIELD"); /* Bitfields have a special type */ }
    | declarator ':' constant_expression
        { 
            char *temp = malloc(strlen($1) + 9); // 9 for " BITFIELD" and null terminator
            sprintf(temp, "%s BITFIELD", $1);
            $$ = temp;
        }
    ;

enum_specifier
    : ENUM '{' enumerator_list '}'
        { 
            $$ = strdup("ENUM");
            currentType = $$;
        }
    | ENUM IDENTIFIER '{' enumerator_list '}'
        {
            char *temp = malloc(strlen("ENUM ") + strlen($2) + 1);
            sprintf(temp, "ENUM %s", $2);
            $$ = temp;
            currentType = $$;
        }
    | ENUM IDENTIFIER
        {
            char *temp = malloc(strlen("ENUM ") + strlen($2) + 1);
            sprintf(temp, "ENUM %s", $2);
            $$ = temp;
            currentType = $$;
        }
    ;

enumerator_list
    : enumerator
        { $$ = $1; }
    | enumerator_list ',' enumerator
        { $$ = $3; /* The type of the list is the type of the last enumerator */ }
    ;

enumerator
    : IDENTIFIER
        { $$ = $1; /* In a full compiler, you'd add this to an enum symbol table */ }
    | IDENTIFIER '=' constant_expression
        { $$ = $1; /* Here you might want to associate the value with the enum constant */ }
    ;

type_qualifier
    : CONST    { $$ = strdup("CONST"); }
    | VOLATILE { $$ = strdup("VOLATILE"); }
    ;

declarator
    : pointer direct_declarator
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    | direct_declarator
        { $$ = $1; }
    ;

direct_declarator
	: IDENTIFIER { 
		add_to_token_table($1, currentType);
		$$ = $1; // Propagate the identifier up the parse tree
	}
	| '(' declarator ')' { $$ = $2; }
	| direct_declarator '[' constant_expression ']' { 
		// For array types, you might want to append [] to the type
		string arrayType = currentType + "[]";
		add_to_token_table($1, arrayType);
		$$ = $1;
	}
	| direct_declarator '[' ']' {
		string arrayType = currentType + "[]";
		add_to_token_table($1, arrayType);
		$$ = $1;
	}
	| direct_declarator '(' parameter_type_list ')' {
		// For function types, you might want to handle this differently
		string funcType = currentType + " function";
		add_to_token_table($1, funcType);
		$$ = $1;
	}
	| direct_declarator '(' identifier_list ')' {
		string funcType = currentType + " function";
		add_to_token_table($1, funcType);
		$$ = $1;
	}
	| direct_declarator '(' ')' {
		string funcType = currentType + " function";
		add_to_token_table($1, funcType);
		$$ = $1;
	}
	;

	;
pointer
    : '*'
        { $$ = strdup("POINTER"); }
    | '*' type_qualifier_list
        { 
            char *temp = malloc(strlen("POINTER ") + strlen($2) + 1);
            sprintf(temp, "POINTER %s", $2);
            $$ = temp;
        }
    | '*' pointer
        { 
            char *temp = malloc(strlen("POINTER ") + strlen($2) + 1);
            sprintf(temp, "POINTER %s", $2);
            $$ = temp;
        }
    | '*' type_qualifier_list pointer
        { 
            char *temp = malloc(strlen("POINTER ") + strlen($2) + strlen($3) + 2);
            sprintf(temp, "POINTER %s %s", $2, $3);
            $$ = temp;
        }
    ;

type_qualifier_list
    : type_qualifier
        { $$ = $1; }
    | type_qualifier_list type_qualifier
        { 
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    ;

parameter_type_list
    : parameter_list
        { $$ = $1; }
    | parameter_list ',' ELLIPSIS
        {
            char *temp = malloc(strlen($1) + strlen(", ...") + 1);
            sprintf(temp, "%s, ...", $1);
            $$ = temp;
        }
    ;

parameter_list
    : parameter_declaration
        { $$ = $1; }
    | parameter_list ',' parameter_declaration
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s, %s", $1, $3);
            $$ = temp;
        }
    ;

parameter_declaration
    : declaration_specifiers declarator
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    | declaration_specifiers abstract_declarator
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    | declaration_specifiers
        { $$ = $1; }
    ;

identifier_list
    : IDENTIFIER
        { $$ = $1; }
    | identifier_list ',' IDENTIFIER
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s, %s", $1, $3);
            $$ = temp;
        }
    ;

type_name
    : specifier_qualifier_list
        { $$ = $1; }
    | specifier_qualifier_list abstract_declarator
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    ;

abstract_declarator
    : pointer
        { $$ = $1; }
    | direct_abstract_declarator
        { $$ = $1; }
    | pointer direct_abstract_declarator
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    ;

direct_abstract_declarator
    : '(' abstract_declarator ')'
        { 
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "(%s)", $2);
            $$ = temp;
        }
    | '[' ']'
        { $$ = strdup("[]"); }
    | '[' constant_expression ']'
        { 
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "[%s]", $2);
            $$ = temp;
        }
    | direct_abstract_declarator '[' ']'
        {
            char *temp = malloc(strlen($1) + 3);
            sprintf(temp, "%s[]", $1);
            $$ = temp;
        }
    | direct_abstract_declarator '[' constant_expression ']'
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s[%s]", $1, $3);
            $$ = temp;
        }
    | '(' ')'
        { $$ = strdup("()"); }
    | '(' parameter_type_list ')'
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "(%s)", $2);
            $$ = temp;
        }
    | direct_abstract_declarator '(' ')'
        {
            char *temp = malloc(strlen($1) + 3);
            sprintf(temp, "%s()", $1);
            $$ = temp;
        }
    | direct_abstract_declarator '(' parameter_type_list ')'
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s(%s)", $1, $3);
            $$ = temp;
        }
    ;

initializer
    : assignment_expression
        { $$ = $1; }
    | '{' initializer_list '}'
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "{%s}", $2);
            $$ = temp;
        }
    | '{' initializer_list ',' '}'
        {
            char *temp = malloc(strlen($2) + 4);
            sprintf(temp, "{%s,}", $2);
            $$ = temp;
        }
    ;

initializer_list
    : initializer
        { $$ = $1; }
    | initializer_list ',' initializer
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s, %s", $1, $3);
            $$ = temp;
        }
    ;

statement
    : labeled_statement
        { $$ = $1; }
    | compound_statement
        { $$ = $1; }
    | expression_statement
        { $$ = $1; }
    | selection_statement
        { $$ = $1; }
    | iteration_statement
        { $$ = $1; }
    | jump_statement
        { $$ = $1; }
    ;

labeled_statement
    : IDENTIFIER ':' statement
        {
            char *temp = malloc(strlen($1) + strlen($3) + 3);
            sprintf(temp, "%s: %s", $1, $3);
            $$ = temp;
        }
    | CASE constant_expression ':' statement
        {
            char *temp = malloc(strlen($2) + strlen($4) + 8);
            sprintf(temp, "case %s: %s", $2, $4);
            $$ = temp;
        }
    | DEFAULT ':' statement
        {
            char *temp = malloc(strlen($3) + 11);
            sprintf(temp, "default: %s", $3);
            $$ = temp;
        }
    ;

compound_statement
    : '{' '}'
        { $$ = strdup("{}"); }
    | '{' statement_list '}'
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "{%s}", $2);
            $$ = temp;
        }
    | '{' declaration_list '}'
        {
            char *temp = malloc(strlen($2) + 3);
            sprintf(temp, "{%s}", $2);
            $$ = temp;
        }
    | '{' declaration_list statement_list '}'
        {
            char *temp = malloc(strlen($2) + strlen($3) + 4);
            sprintf(temp, "{%s %s}", $2, $3);
            $$ = temp;
        }
    ;

declaration_list
    : declaration
        { $$ = $1; }
    | declaration_list declaration
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    ;

statement_list
    : statement
        { $$ = $1; }
    | statement_list statement
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    ;

expression_statement
    : ';'
        { $$ = strdup(";"); }
    | expression ';'
        {
            char *temp = malloc(strlen($1) + 2);
            sprintf(temp, "%s;", $1);
            $$ = temp;
        }
    ;

selection_statement
    : IF '(' expression ')' statement
        {
            char *temp = malloc(strlen($3) + strlen($5) + 8);
            sprintf(temp, "if (%s) %s", $3, $5);
            $$ = temp;
        }
    | IF '(' expression ')' statement ELSE statement
        {
            char *temp = malloc(strlen($3) + strlen($5) + strlen($7) + 14);
            sprintf(temp, "if (%s) %s else %s", $3, $5, $7);
            $$ = temp;
        }
    | SWITCH '(' expression ')' statement
        {
            char *temp = malloc(strlen($3) + strlen($5) + 11);
            sprintf(temp, "switch (%s) %s", $3, $5);
            $$ = temp;
        }
    ;

iteration_statement
    : WHILE '(' expression ')' statement
        {
            char *temp = malloc(strlen($3) + strlen($5) + 10);
            sprintf(temp, "while (%s) %s", $3, $5);
            $$ = temp;
        }
    | DO statement WHILE '(' expression ')' ';'
        {
            char *temp = malloc(strlen($2) + strlen($5) + 15);
            sprintf(temp, "do %s while (%s);", $2, $5);
            $$ = temp;
        }
    | FOR '(' expression_statement expression_statement ')' statement
        {
            char *temp = malloc(strlen($3) + strlen($4) + strlen($6) + 9);
            sprintf(temp, "for (%s%s) %s", $3, $4, $6);
            $$ = temp;
        }
    | FOR '(' expression_statement expression_statement expression ')' statement
        {
            char *temp = malloc(strlen($3) + strlen($4) + strlen($5) + strlen($7) + 9);
            sprintf(temp, "for (%s%s%s) %s", $3, $4, $5, $7);
            $$ = temp;
        }
    ;

jump_statement
    : GOTO IDENTIFIER ';'
        {
            char *temp = malloc(strlen($2) + 7);
            sprintf(temp, "goto %s;", $2);
            $$ = temp;
        }
    | CONTINUE ';'
        { $$ = strdup("continue;"); }
    | BREAK ';'
        { $$ = strdup("break;"); }
    | RETURN ';'
        { $$ = strdup("return;"); }
    | RETURN expression ';'
        {
            char *temp = malloc(strlen($2) + 9);
            sprintf(temp, "return %s;", $2);
            $$ = temp;
        }
    ;

translation_unit
    : external_declaration
        { $$ = $1; }
    | translation_unit external_declaration
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s\n%s", $1, $2);
            $$ = temp;
        }
    ;

external_declaration
    : function_definition
        { $$ = $1; }
    | declaration
        { $$ = $1; }
    ;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement
        {
            char *temp = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + 4);
            sprintf(temp, "%s %s %s %s", $1, $2, $3, $4);
            $$ = temp;
        }
    | declaration_specifiers declarator compound_statement
        {
            char *temp = malloc(strlen($1) + strlen($2) + strlen($3) + 3);
            sprintf(temp, "%s %s %s", $1, $2, $3);
            $$ = temp;
        }
    | declarator declaration_list compound_statement
        {
            char *temp = malloc(strlen($1) + strlen($2) + strlen($3) + 3);
            sprintf(temp, "%s %s %s", $1, $2, $3);
            $$ = temp;
        }
    | declarator compound_statement
        {
            char *temp = malloc(strlen($1) + strlen($2) + 2);
            sprintf(temp, "%s %s", $1, $2);
            $$ = temp;
        }
    ;
%%

#include <iostream>
#include <fstream>

extern FILE *yyin;
extern int yyparse();

void yyerror(const char *s) {
    extern int line;
    fprintf(stderr, "Error: %s at line %d\n", s, line);
}

// Define the global variables here
bool iserror = false;
int line = 1;
vector<pair<string, int>> error;
unordered_map<string, string> symtab;
vector<string> program;

// Define the new symbol table

unordered_map<string, string> new_symtab;

void add_to_token_table(string token, string type) {
    new_symtab[token] = type;
}

int main(int argc, char *argv[]) {
    string inputFileName, outputFileName;

    // Parsing command-line arguments
    for (int i = 1; i < argc; i++) {
        if (string(argv[i]) == "-i" && i + 1 < argc) {
            inputFileName = argv[i + 1];
            i++; // Skip next argument
        } else if (string(argv[i]) == "-o" && i + 1 < argc) {
            outputFileName = argv[i + 1];
            i++; // Skip next argument
        }
    }

    // Check if both input and output files are specified
    if (inputFileName.empty() || outputFileName.empty()) {
        cerr << "Usage: " << argv[0] << " -i <input_file> -o <output_file>\n";
        return 1;
    }

    FILE *inputFile = fopen(inputFileName.c_str(), "r");
    ofstream outputFile(outputFileName);

    if (!inputFile || !outputFile) {
        cerr << "Error opening files!" << endl;
        return 1;
    }

    yyin = inputFile;  // Set yyin to read from the file
    if (yyparse() == 0) {
         cout << "Parsing successful!" << endl;
    } else {
        cerr << "Parsing failed!" << endl;
    }
       // Check if there are errors
    if (!error.empty()) {
        outputFile << "Errors Found:\n";
        for (const auto &err : error) {
             if(err.first!="unterminated comment")outputFile << "invalid character : " << err.first << " at line no. " << err.second << endl;
            else outputFile  << err.first << " at line no. " << err.second << endl;
        }
    } 
	else {
        outputFile << "Original Symbol Table:\n";
        outputFile << "-------------------------------------------------------------------------------\n";
        outputFile << "| Lexeme                                | Token                                 |\n";
        outputFile << "-------------------------------------------------------------------------------\n";

        for (const auto &entry : symtab) {
            std::stringstream tokenStream(entry.first);
            std::string line;
            bool firstLine = true;
            while (std::getline(tokenStream, line, '\n')) {
                if (firstLine) {
                    outputFile << "| " << setw(36) << left << line
                               << " | " << setw(36) << left << entry.second << " |\n";
                    firstLine = false;
                } else {
                    outputFile << "| " << setw(36) << left << line
                               << " | " << setw(36) << left << "" << " |\n";
                }
            }
        }
        outputFile << "-------------------------------------------------------------------------------\n";
        outputFile << '\n';

        outputFile << "\nNew Symbol Table (Tokens and Types):\n";
        outputFile << "-------------------------------------------------------------------------------\n";
        outputFile << "| Token                 | Type                  |\n";
        outputFile << "-------------------------------------------------------------------------------\n";

        for (const auto &entry : new_symtab) {
            outputFile << "| " << setw(20) << left << entry.first
                       << " | " << setw(20) << left << entry.second << "\n";
        }

        outputFile << "-------------------------------------------------------------------------------\n";
        outputFile << '\n';
        outputFile << "whole program after separation:\n";
        for (const auto &i : program) {
            outputFile << "|" << i << "|\n";
        }

    }

    fclose(inputFile);
    outputFile.close();

    cout << "Lexical analysis completed. Check '" << outputFileName << "' for results." << endl;

    return 0;
}
