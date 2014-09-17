
/* description: the parser definition for tamejs. */

/* To build parser:
     % <jison> parser.y lexer.l
*/


%start expr


%%

expr : or  { $$ = $1; }
     | and { $$ = $1; }
     | LPAREN expr RPAREN { $$ = $1; }
     | URL { $$ = new yy.URL($1); }
     ;

or : expr OR expr  { $$ = new yy.OR($1, $3); }
     | or OR expr  { $1.push($3); $$ = $1;
     ;

and : expr AND expr { $$ = new yy.AND($1, $3); }
     | and AND expr { $1.push($3); $$ = $1; }
     ;

