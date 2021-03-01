%{
#define YYSTYPE char *
#include "y.tab.h"
int cur_line = 1;
void yyerror(const char *msg);
void unrecognized_char(char c);
%}

IP		"ip.src"
HOST 		"http.host"
COOKIE		"http.cookie"
URI		"http.request.uri"
URI_PATH	"http.request.uri.path"
URI_FULL	"http.request.full_uri"
URI_QUERY	"http.request.uri.query"
XFF		"http.x_forwarded_for"
REF		"http.referer"
OP_IN		"in"
OP_EQ		"eq"
OP_CT		"contains"
OP_MC		"matches"
IDENTIFIER      [_a-zA-Z][_a-zA-Z0-9]*
WHITESPACE      [ \t]*
OPERATOR        [-/+*()=;{}]
STRING          (\042[^\042\n]*\042)

dec_octet   [0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]
IPv4Address {dec_octet}\.{dec_octet}\.{dec_octet}\.{dec_octet}

%%
and|"&&"	return AND;
or|"||"		return OR;
not		return '!';
{OPERATOR}      { return yytext[0]; }
{IPv4Address}   { yylval = strdup(yytext); return T_IP_ADDR; }
{STRING}   	{ yylval = strdup(yytext); return T_STRING; }

{OP_IN}       	{ yylval = strdup(yytext); return T_OP_IN; }
{OP_EQ}       	{ yylval = strdup(yytext); return T_OP_EQ; }
{OP_CT}       	{ yylval = strdup(yytext); return T_OP_CT; }
{OP_MC}       	{ yylval = strdup(yytext); return T_OP_MC; }

{IP}       	{ yylval = strdup(yytext); return T_IP; }
{HOST}       	{ yylval = strdup(yytext); return T_HOST; }
{COOKIE}       	{ yylval = strdup(yytext); return T_COOKIE; }
{URI}       	{ yylval = strdup(yytext); return T_URI; }
{URI_PATH}      { yylval = strdup(yytext); return T_URI_PATH; }
{URI_FULL}      { yylval = strdup(yytext); return T_URI_FULL; }
{URI_QUERY}     { yylval = strdup(yytext); return T_URI_QUERY; }
{XFF}       	{ yylval = strdup(yytext); return T_XFF; }
{REF}       	{ yylval = strdup(yytext); return T_REF; }

{IDENTIFIER}    { yylval = strdup(yytext); return T_Identifier; }
{WHITESPACE}    { /* ignore every whitespcace */ }
\n              { cur_line++; }
.               { unrecognized_char(yytext[0]); }
%%

int yywrap(void) { 
    return 1;
}

void unrecognized_char(char c) {
    char buf[32] = "Unrecognized character: ?";
    buf[24] = c;
    yyerror(buf);
}

void yyerror(const char *msg) {
    printf("Error at line %d:\n\t%s\n", cur_line, msg);
    exit(1);
}
