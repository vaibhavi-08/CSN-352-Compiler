D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U)?(L|LL|l|ll)?
%{
#include <bits/stdc++.h>
using namespace std;
unordered_map<string,string> symtab;
vector<string> program;
vector<pair<string,int>> error;
void comment();
void count();
int main(int argc, char *argv[]);
int line=1;
bool iserror=false;

%}


%%

"/*"			{ comment();if(iserror){error.emplace_back("unterminated comment",line);}count();}
"//"[^\n]*(\n)?	{ /* do nothing */  count();}
"auto"			{ symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"break"         { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"case"          { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"char"          { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"const"			{ symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"continue"      { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"default"       { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"do"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"double"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"else"          { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"enum"          { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"extern"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"float"         { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"for"           { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"goto"          { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"if"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"int"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"long"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"register"	    { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"return"	    { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"short"		    { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"signed"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"sizeof"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"static"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"struct"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"switch"        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"typedef"       { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"union"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"unsigned"      { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"void"          { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"bool"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"volatile"      { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}
"while"	        { symtab[yytext]="KEYWORD";program.emplace_back(yytext);count();}

 
{L}({L}|{D})*   { symtab[yytext]="IDENTIFIER";program.emplace_back(yytext);count();}
{D}+{IS}        { symtab[yytext]="INTEGER";program.emplace_back(yytext);count();}
L?'(\\.|[^\\'])+'  { symtab[yytext]="CONSTANT CHAR";program.emplace_back(yytext);count();}
{D}+{E}{FS}?        { symtab[yytext]="CONSTANT EXP";program.emplace_back(yytext);count();}
{D}*"."{D}+({E})?{FS}? { symtab[yytext]="CONSTANT FLOAT";program.emplace_back(yytext);count();}
L?\"(\\.|[^\\"])*\"    { symtab[yytext]="STRING LITERAL";program.emplace_back(yytext);count();}

"..."   { symtab[yytext]="ELLIPSIS";program.emplace_back(yytext);count(); return (ELLIPSIS);}
">>="   { symtab[yytext]="RIGHT_ASSIGN";program.emplace_back(yytext);count();return (RIGHT_ASSIGN);}
"<<="   { symtab[yytext]="LEFT_ASSIGN";program.emplace_back(yytext);count();return (LEFT_ASSIGN);}
"+="    { symtab[yytext]="ADD_ASSIGN";program.emplace_back(yytext);count();return (ADD_ASSIGN);}
"-="    { symtab[yytext]="SUB_ASSIGN";program.emplace_back(yytext);count();return (SUB_ASSIGN);}
"*="    { symtab[yytext]="MUL_ASSIGN";program.emplace_back(yytext);count();return (MUL_ASSIGN);}
"/="    { symtab[yytext]="DIV_ASSIGN";program.emplace_back(yytext);count();return (DIV_ASSIGN);}
"%="    { symtab[yytext]="MOD_ASSIGN";program.emplace_back(yytext);count();return (MOD_ASSIGN);}
"&="    { symtab[yytext]="AND_ASSIGN";program.emplace_back(yytext);count();return (AND_ASSIGN);}
"^="    { symtab[yytext]="XOR_ASSIGN";program.emplace_back(yytext);count();return (XOR_ASSIGN);}
"|="    { symtab[yytext]="OR_ASSIGN";program.emplace_back(yytext);count();return (OR_ASSIGN);}
">>"    { symtab[yytext]="RIGHT_OP";program.emplace_back(yytext);count();return (RIGHT_OP);}
"<<"    { symtab[yytext]="LEFT_OP";program.emplace_back(yytext);count();return (LEFT_OP);}
"++"    { symtab[yytext]="INC_OP";program.emplace_back(yytext);count();return (INC_OP);}
"--"    { symtab[yytext]="DEC_OP";program.emplace_back(yytext);count();return (DEC_OP);}
"->"    { symtab[yytext]="PTR_OP";program.emplace_back(yytext);count();return (PTR_OP);}
"&&"    { symtab[yytext]="AND_OP";program.emplace_back(yytext);count();return (AND_OP);}
"||"    { symtab[yytext]="OR_OP";program.emplace_back(yytext);count();return (OR_OP);}
"<="    { symtab[yytext]="LE_OP";program.emplace_back(yytext);count();return (LE_OP);}
">="    { symtab[yytext]="GE_OP";program.emplace_back(yytext);count();return (GE_OP);}
"=="    { symtab[yytext]="EQ_OP";program.emplace_back(yytext);count();return (EQ_OP);}
"!="    { symtab[yytext]="NE_OP";program.emplace_back(yytext);count();return (NE_OP);}
";"	    { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return (';');}
("{"|"<%")  { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return ('{');}
("}"|"%>")  { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return ('}');
","	        { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return (',');}
":"	        { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return (':');}
"="	        { symtab[yytext]="ASSIGN";program.emplace_back(yytext);count(); return ('=');}
"("	        { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return ('(');}
")"	        { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return (')');}
("["|"<:")  { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return ('[');}
("]"|":>")  { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return (']');}
"."	        { symtab[yytext]="SEPERATOR";program.emplace_back(yytext);count();return ('.');}
"&"	        { symtab[yytext]="BITWISE_AND";program.emplace_back(yytext);count();return ('&');}
"!"         { symtab[yytext]="NOT";program.emplace_back(yytext);count();return ('!');}
"~"	        { symtab[yytext]="BITWISE_NOT";program.emplace_back(yytext);count();return ('!');}
"-"	        { symtab[yytext]="MINUS";program.emplace_back(yytext);count();return ('-');}
"+"	        { symtab[yytext]="PLUS";program.emplace_back(yytext);count();return ('+');}
"*"	        { symtab[yytext]="MUL";program.emplace_back(yytext);count();return ('*');}
"/"	        { symtab[yytext]="DIV";program.emplace_back(yytext);count();return ('/');}
"%"	        { symtab[yytext]="MOD";program.emplace_back(yytext);count();return ('%');}
"<"	        { symtab[yytext]="LESSTHAN";program.emplace_back(yytext);count();return ('<');}
">"         { symtab[yytext]="GREATERTHAN";program.emplace_back(yytext);count();return ('>');}
"^"	        { symtab[yytext]="XOR";program.emplace_back(yytext);count();return ('^');}
"|"	        { symtab[yytext]="OR";program.emplace_back(yytext);count();return ('|');}
"?"	        { symtab[yytext]="QUESTION MARK";program.emplace_back(yytext);count();return ('?');}
[ \t\v\n\f]		{ /* DO NOTHING*/ count();}
.			{ iserror=true;error.emplace_back(yytext,line);count();}


%%
void comment()
{
	char c, c1;

loop:
	while ((c = yyinput()) != '*' && c != 0);
	if ((c1 = yyinput()) != '/' && c != 0)
	{
		unput(c1);
		goto loop;
	}
	
	if (c != 0){
		// do nothing
	}
    if(c==0){
        iserror=true;
    }
		
}
void count(){
    for(int i=0;i<yyleng;i++){
        if(yytext[i]=='\n')line++;
    }
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
    yylex();  // Perform lexical analysis

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



int yywrap()
{	
	return(1);
}
