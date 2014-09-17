%lex

%%

[ \t\n]+             /* ignore */
[^ \t\n()&|]+        return 'URL';
&&                   return 'AND';
||                   return 'OR';
'('                  return 'LPAREN';
')'                  return 'RPAREN';
.                    return 'UNHANDLED';
<<EOF>>              return 'EOF';

/lex

%left OR
%left AND

%start expressions

%% /* language grammar */

expressions
    : e EOF { $$ = $1; }
    ;

e
    : e OR e    { $$ = new yy.OR($1, $3); }
    | e AND e   { $$ = new yy.AND($1, $3); }
    | '(' e ')' { $$ = $2; }
    | URL       { $$ = new yy.URL($1); }
    ;
