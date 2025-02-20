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

// Symbol table (you might need this from your lexer)
extern unordered_map<string, string> symtab;
extern vector<string> program;
extern vector<pair<string, int>> error;
extern int line;
extern bool iserror;

int yylex();
void yyerror(const char *s);
bool iserror = false;
int line = 1;
vector<pair<string, int>> error;
unordered_map<string, string> symtab;
vector<string> program;
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

%type <ival> primary_expression postfix_expression argument_expression_list unary_expression
%type <ival> cast_expression multiplicative_expression additive_expression shift_expression
%type <ival> relational_expression equality_expression and_expression exclusive_or_expression
%type <ival> inclusive_or_expression logical_and_expression logical_or_expression conditional_expression
%type <ival> assignment_expression constant_expression expression declaration
%type <ival> declaration_specifiers init_declarator_list init_declarator storage_class_specifier
%type <ival> type_specifier struct_or_union_specifier struct_or_union struct_declaration_list
%type <ival> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator
%type <ival> enum_specifier enumerator_list enumerator type_qualifier declarator direct_declarator
%type <ival> pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration
%type <ival> identifier_list type_name abstract_declarator direct_abstract_declarator initializer
%type <ival> initializer_list statement labeled_statement compound_statement declaration_list
%type <ival> statement_list expression_statement selection_statement iteration_statement
%type <ival> jump_statement translation_unit external_declaration function_definition assignment_operator

%start translation_unit

%%

primary_expression
	: IDENTIFIER  { $$ = 1; }
	| CONSTANT    { $$ = 2; }
	| STRING_LITERAL { $$ = 3; }
	| '(' expression ')' { $$ = $2; }
	;

postfix_expression
	: primary_expression { $$ = $1; }
	| postfix_expression '[' expression ']' { $$ = 4; }
	| postfix_expression '(' ')' { $$ = 5; }
	| postfix_expression '(' argument_expression_list ')' { $$ = 6; }
	| postfix_expression '.' IDENTIFIER { $$ = 7; }
	| postfix_expression PTR_OP IDENTIFIER { $$ = 8; }
	| postfix_expression INC_OP { $$ = 9; }
	| postfix_expression DEC_OP { $$ = 10; }
	;

argument_expression_list
	: assignment_expression { $$ = $1; }
	| argument_expression_list ',' assignment_expression { $$ = 11; }
	;

unary_expression
	: postfix_expression { $$ = $1; }
	| INC_OP unary_expression { $$ = 12; }
	| DEC_OP unary_expression { $$ = 13; }
	| unary_operator cast_expression { $$ = 14; }
	| SIZEOF unary_expression { $$ = 15; }
	| SIZEOF '(' type_name ')' { $$ = 16; }
	;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;


cast_expression
	: unary_expression { $$ = $1; }
	| '(' type_name ')' cast_expression { $$ = 23; }
	;

multiplicative_expression
	: cast_expression { $$ = $1; }
	| multiplicative_expression '*' cast_expression { $$ = 24; }
	| multiplicative_expression '/' cast_expression { $$ = 25; }
	| multiplicative_expression '%' cast_expression { $$ = 26; }
	;

additive_expression
	: multiplicative_expression { $$ = $1; }
	| additive_expression '+' multiplicative_expression { $$ = 27; }
	| additive_expression '-' multiplicative_expression { $$ = 28; }
	;

shift_expression
	: additive_expression { $$ = $1; }
	| shift_expression LEFT_OP additive_expression { $$ = 29; }
	| shift_expression RIGHT_OP additive_expression { $$ = 30; }
	;

relational_expression
	: shift_expression { $$ = $1; }
	| relational_expression '<' shift_expression { $$ = 31; }
	| relational_expression '>' shift_expression { $$ = 32; }
	| relational_expression LE_OP shift_expression { $$ = 33; }
	| relational_expression GE_OP shift_expression { $$ = 34; }
	;

equality_expression
	: relational_expression { $$ = $1; }
	| equality_expression EQ_OP relational_expression { $$ = 35; }
	| equality_expression NE_OP relational_expression { $$ = 36; }
	;

and_expression
	: equality_expression { $$ = $1; }
	| and_expression '&' equality_expression { $$ = 37; }
	;

exclusive_or_expression
	: and_expression { $$ = $1; }
	| exclusive_or_expression '^' and_expression { $$ = 38; }
	;

inclusive_or_expression
	: exclusive_or_expression { $$ = $1; }
	| inclusive_or_expression '|' exclusive_or_expression { $$ = 39; }
	;

logical_and_expression
	: inclusive_or_expression { $$ = $1; }
	| logical_and_expression AND_OP inclusive_or_expression { $$ = 40; }
	;

logical_or_expression
	: logical_and_expression { $$ = $1; }
	| logical_or_expression OR_OP logical_and_expression { $$ = 41; }
	;

conditional_expression
	: logical_or_expression { $$ = $1; }
	| logical_or_expression '?' expression ':' conditional_expression { $$ = 42; }
	;

assignment_expression
	: conditional_expression { $$ = $1; }
	| unary_expression assignment_operator assignment_expression { $$ = 43; }
	;

assignment_operator
	: '=' { $$ = 44; }
	| MUL_ASSIGN { $$ = 45; }
	| DIV_ASSIGN { $$ = 46; }
	| MOD_ASSIGN { $$ = 47; }
	| ADD_ASSIGN { $$ = 48; }
	| SUB_ASSIGN { $$ = 49; }
	| LEFT_ASSIGN { $$ = 50; }
	| RIGHT_ASSIGN { $$ = 51; }
	| AND_ASSIGN { $$ = 52; }
	| XOR_ASSIGN { $$ = 53; }
	| OR_ASSIGN { $$ = 54; }
	;

expression
	: assignment_expression { $$ = $1; }
	| expression ',' assignment_expression { $$ = 55; }
	;

constant_expression
	: conditional_expression { $$ = $1; }
	;

declaration
	: declaration_specifiers ';' { $$ = 56; }
	| declaration_specifiers init_declarator_list ';' { $$ = 57; }
	;

declaration_specifiers
	: storage_class_specifier { $$ = $1; }
	| storage_class_specifier declaration_specifiers { $$ = 58; }
	| type_specifier { $$ = $1; }
	| type_specifier declaration_specifiers { $$ = 59; }
	| type_qualifier { $$ = $1; }
	| type_qualifier declaration_specifiers { $$ = 60; }
	;

init_declarator_list
	: init_declarator { $$ = $1; }
	| init_declarator_list ',' init_declarator { $$ = 61; }
	;

init_declarator
	: declarator { $$ = $1; }
	| declarator '=' initializer { $$ = 62; }
	;

storage_class_specifier
	: TYPEDEF { $$ = 63; }
	| EXTERN { $$ = 64; }
	| STATIC { $$ = 65; }
	| AUTO { $$ = 66; }
	| REGISTER { $$ = 67; }
	;

type_specifier
	: VOID { $$ = 68; }
	| CHAR { $$ = 69; }
	| SHORT { $$ = 70; }
	| INT { $$ = 71; }
	| LONG { $$ = 72; }
	| FLOAT { $$ = 73; }
	| DOUBLE { $$ = 74; }
	| SIGNED { $$ = 75; }
	| UNSIGNED { $$ = 76; }
	| struct_or_union_specifier { $$ = $1; }
	| enum_specifier { $$ = $1; }
	| TYPE_NAME { $$ = 77; }
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}' { $$ = 78; }
	| struct_or_union '{' struct_declaration_list '}' { $$ = 79; }
	| struct_or_union IDENTIFIER { $$ = 80; }
	;

struct_or_union
	: STRUCT { $$ = 81; }
	| UNION { $$ = 82; }
	;

struct_declaration_list
	: struct_declaration { $$ = $1; }
	| struct_declaration_list struct_declaration { $$ = 83; }
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' { $$ = 84; }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list { $$ = 85; }
	| type_specifier { $$ = $1; }
	| type_qualifier specifier_qualifier_list { $$ = 86; }
	| type_qualifier { $$ = $1; }
	;

struct_declarator_list
	: struct_declarator { $$ = $1; }
	| struct_declarator_list ',' struct_declarator { $$ = 87; }
	;

struct_declarator
	: declarator { $$ = $1; }
	| ':' constant_expression { $$ = 88; }
	| declarator ':' constant_expression { $$ = 89; }
	;

enum_specifier
	: ENUM '{' enumerator_list '}' { $$ = 90; }
	| ENUM IDENTIFIER '{' enumerator_list '}' { $$ = 91; }
	| ENUM IDENTIFIER { $$ = 92; }
	;

enumerator_list
	: enumerator { $$ = $1; }
	| enumerator_list ',' enumerator { $$ = 93; }
	;

enumerator
	: IDENTIFIER { $$ = 94; }
	| IDENTIFIER '=' constant_expression { $$ = 95; }
	;

type_qualifier
	: CONST { $$ = 96; }
	| VOLATILE { $$ = 97; }
	;

declarator
	: pointer direct_declarator { $$ = 98; }
	| direct_declarator { $$ = $1; }
	;

direct_declarator
	: IDENTIFIER { $$ = 99; }
	| '(' declarator ')' { $$ = 100; }
	| direct_declarator '[' constant_expression ']' { $$ = 101; }
	| direct_declarator '[' ']' { $$ = 102; }
	| direct_declarator '(' parameter_type_list ')' { $$ = 103; }
	| direct_declarator '(' identifier_list ')' { $$ = 104; }
	| direct_declarator '(' ')' { $$ = 105; }
	;

pointer
	: '*' { $$ = 106; }
	| '*' type_qualifier_list { $$ = 107; }
	| '*' pointer { $$ = 108; }
	| '*' type_qualifier_list pointer { $$ = 109; }
	;

type_qualifier_list
	: type_qualifier { $$ = $1; }
	| type_qualifier_list type_qualifier { $$ = 110; }
	;


parameter_type_list
	: parameter_list { $$ = $1; }
	| parameter_list ',' ELLIPSIS { $$ = 111; }
	;

parameter_list
	: parameter_declaration { $$ = $1; }
	| parameter_list ',' parameter_declaration { $$ = 112; }
	;

parameter_declaration
	: declaration_specifiers declarator { $$ = 113; }
	| declaration_specifiers abstract_declarator { $$ = 114; }
	| declaration_specifiers { $$ = 115; }
	;

identifier_list
	: IDENTIFIER { $$ = 116; }
	| identifier_list ',' IDENTIFIER { $$ = 117; }
	;

type_name
	: specifier_qualifier_list { $$ = $1; }
	| specifier_qualifier_list abstract_declarator { $$ = 118; }
	;

abstract_declarator
	: pointer { $$ = $1; }
	| direct_abstract_declarator { $$ = $1; }
	| pointer direct_abstract_declarator { $$ = 119; }
	;

direct_abstract_declarator
	: '(' abstract_declarator ')' { $$ = 120; }
	| '[' ']' { $$ = 121; }
	| '[' constant_expression ']' { $$ = 122; }
	| direct_abstract_declarator '[' ']' { $$ = 123; }
	| direct_abstract_declarator '[' constant_expression ']' { $$ = 124; }
	| '(' ')' { $$ = 125; }
	| '(' parameter_type_list ')' { $$ = 126; }
	| direct_abstract_declarator '(' ')' { $$ = 127; }
	| direct_abstract_declarator '(' parameter_type_list ')' { $$ = 128; }
	;

initializer
	: assignment_expression { $$ = $1; }
	| '{' initializer_list '}' { $$ = 129; }
	| '{' initializer_list ',' '}' { $$ = 130; }
	;

initializer_list
	: initializer { $$ = $1; }
	| initializer_list ',' initializer { $$ = 131; }
	;

statement
	: labeled_statement { $$ = $1; }
	| compound_statement { $$ = $1; }
	| expression_statement { $$ = $1; }
	| selection_statement { $$ = $1; }
	| iteration_statement { $$ = $1; }
	| jump_statement { $$ = $1; }
	;

labeled_statement
	: IDENTIFIER ':' statement { $$ = 132; }
	| CASE constant_expression ':' statement { $$ = 133; }
	| DEFAULT ':' statement { $$ = 134; }
	;

compound_statement
	: '{' '}' { $$ = 135; }
	| '{' statement_list '}' { $$ = 136; }
	| '{' declaration_list '}' { $$ = 137; }
	| '{' declaration_list statement_list '}' { $$ = 138; }
	;

declaration_list
	: declaration { $$ = $1; }
	| declaration_list declaration { $$ = 139; }
	;

statement_list
	: statement { $$ = $1; }
	| statement_list statement { $$ = 140; }
	;

expression_statement
	: ';' { $$ = 141; }
	| expression ';' { $$ = 142; }
	;

selection_statement
	: IF '(' expression ')' statement { $$ = 143; }
	| IF '(' expression ')' statement ELSE statement { $$ = 144; }
	| SWITCH '(' expression ')' statement { $$ = 145; }
	;

iteration_statement
	: WHILE '(' expression ')' statement { $$ = 146; }
	| DO statement WHILE '(' expression ')' ';' { $$ = 147; }
	| FOR '(' expression_statement expression_statement ')' statement { $$ = 148; }
	| FOR '(' expression_statement expression_statement expression ')' statement { $$ = 149; }
	;

jump_statement
	: GOTO IDENTIFIER ';' { $$ = 150; }
	| CONTINUE ';' { $$ = 151; }
	| BREAK ';' { $$ = 152; }
	| RETURN ';' { $$ = 153; }
	| RETURN expression ';' { $$ = 154; }
	;

translation_unit
	: external_declaration { $$ = $1; }
	| translation_unit external_declaration { $$ = 155; }
	;

external_declaration
	: function_definition { $$ = $1; }
	| declaration { $$ = $1; }
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement { $$ = 156; }
	| declaration_specifiers declarator compound_statement { $$ = 157; }
	| declarator declaration_list compound_statement { $$ = 158; }
	| declarator compound_statement { $$ = 159; }
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

// Symbol table (you might need this from your lexer)
//extern unordered_map<string, string> symtab;
//extern vector<string> program;
//extern vector<pair<string, int>> error;
//extern int line;
//extern bool iserror;

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
    } else {
        outputFile << "Symbol Table:\n";
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
