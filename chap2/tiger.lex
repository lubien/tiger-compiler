%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

#define MAX_STR_CONST 1025

char stringBuffer[MAX_STR_CONST];
int charPos=1;
int commentDeep = 0;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

%}
%Start  COMMENT STR
%%
<INITIAL,COMMENT>"/*"    {adjust(); commentDeep++; BEGIN COMMENT;}

<STR>{
  \\n    {adjust(); strcat(stringBuffer, "\n");}
  \\t    {adjust(); strcat(stringBuffer, "\t");}
  \"    {adjust(); yylval.sval = stringBuffer; BEGIN 0; return STRING;}
  .+    {adjust(); strcat(stringBuffer, yytext);}
}

<COMMENT>{
  "*/"    {adjust(); commentDeep--; if (commentDeep == 0) { BEGIN 0; };}
  .   {adjust();}
}

<INITIAL>{
  \"  {adjust(); stringBuffer[0] = '\0'; BEGIN STR;}
  ","  {adjust(); return COMMA;}
  ":"  {adjust(); return COLON;}
  ";"  {adjust(); return SEMICOLON;}
  "("  {adjust(); return LPAREN;}
  ")"  {adjust(); return RPAREN;}
  "["  {adjust(); return LBRACK;}
  "]"  {adjust(); return RBRACK;}
  "{"  {adjust(); return LBRACE;}
  "}"  {adjust(); return RBRACE;}
  "."  {adjust(); return DOT;}
  "+"  {adjust(); return PLUS;}
  "-"  {adjust(); return MINUS;}
  "*"  {adjust(); return TIMES;}
  "/"  {adjust(); return DIVIDE;}
  "="  {adjust(); return EQ;}
  "<>"  {adjust(); return NEQ;}
  "<"  {adjust(); return LT;}
  "<="  {adjust(); return LE;}
  ">"    {adjust(); return GT;}
  ">="  {adjust(); return GE;}
  "&"  {adjust(); return AND;}
  "|"  {adjust(); return OR;}
  ":="    {adjust(); return ASSIGN;}
  (?i:ARRAY)   {adjust(); return ARRAY;}
  (?i:IF)   {adjust(); return IF;}
  (?i:THEN)   {adjust(); return THEN;}
  (?i:ELSE)   {adjust(); return ELSE;}
  (?i:WHILE)   {adjust(); return WHILE;}
  (?i:FOR)   {adjust(); return FOR;}
  (?i:TO)   {adjust(); return TO;}
  (?i:DO)   {adjust(); return DO;}
  (?i:LET)   {adjust(); return LET;}
  (?i:IN)   {adjust(); return IN;}
  (?i:END)   {adjust(); return END;}
  (?i:OF)   {adjust(); return OF;}
  (?i:BREAK)   {adjust(); return BREAK;}
  (?i:NIL)   {adjust(); return NIL;}
  (?i:FUNCTION)   {adjust(); return FUNCTION;}
  (?i:VAR)   {adjust(); return VAR;}
  (?i:TYPE)   {adjust(); return TYPE;}
  [0-9]+    {adjust(); yylval.ival = atoi(yytext); return INT;}
  (?i:[a-z][a-z0-9_]*)   {adjust(); yylval.sval = String(yytext); return ID;}
  \n	 {adjust(); EM_newline(); continue;}
  [ \t\r]+	 {adjust(); continue;}
  .	 {adjust(); EM_error(EM_tokPos,"illegal token");}
}
