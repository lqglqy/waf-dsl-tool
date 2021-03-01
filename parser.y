%{
#include <stdio.h>
#include <stdlib.h>
#include<string.h>
void yyerror(const char*);
#define YYSTYPE char *
#define YYDEBUG 1
#define YYERROR_VERBOSE
%}

%token T_IntConstant T_Identifier T_IP T_OP_EQ T_OP_IN T_IP_ADDR T_OP_MC T_OP_CT T_HOST T_COOKIE T_URI T_URI_PATH T_URI_FULL T_URI_QUERY T_XFF T_REF T_STRING

%left OR AND

%%


S   :   Stmt
    |   S Stmt
    |   paren Stmt rparen or paren Stmt rparen
    ;

or: OR {printf(" or ");}
   ;
not: '!' {printf(" not ");}
   ;

and: AND { printf(" and "); }
   ;

paren: '(' { printf(" ( "); }
     ;
rparen: ')' { printf(" ) "); }
     ;

brace: '{' {}
     ;
rbrace: '}' {}
     ;

Stmt: Expr
    | Stmt and Expr 
    | paren Stmt rparen
    ;

Expr: IP_Expr
    | STR_VAR_Expr
    | not Expr;

STR_VAR_Expr: str_var str_op_common T_STRING { printf("str_%s( %s, \"%s\" )", $2, $1, $3); }

str_op_common: T_OP_CT
	     | T_OP_MC
	     ;
		;
str_var : T_HOST {
		$$ = (char *)malloc(strlen("var.host")+1);
		sprintf($$, "var.host");
	}
	| T_COOKIE 	
	| T_URI
	| T_URI_PATH
	| T_URI_FULL
	| T_URI_QUERY
	| T_XFF
	| T_REF
	;

IP_Expr   :  T_IP T_OP_IN ipaddr_list { printf("ip_%s( ngx.remote.addr, %s )", $2, $3); }
	  |  T_IP T_OP_EQ ipaddr { printf("ip_%s( ngx.remote.addr, \"%s\" )", $2, $3); }
    ;

ipaddr_list: brace ipaddr_segs rbrace { 
		$$ = (char *)malloc(sizeof(char)*(strlen($2)+1+2)); 
		sprintf($$,"{%s}", $2);
	}
	;
ipaddr_segs: ipaddr{ 
		$$ = (char *)malloc(sizeof(char)*(strlen($1)+1+2)); 
		sprintf($$,"\"%s\"", $1);
	}

	| ipaddr_segs ipaddr { 
		$$ = (char *)malloc(sizeof(char)*(strlen($1)+strlen($2)+1+4)); 
		sprintf($$,"%s, \"%s\"", $1, $2);
	}
	;

ipaddr: T_IP_ADDR { $$ = $1; }
;

%%

int main() {
    return yyparse();
}
