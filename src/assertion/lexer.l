
%%

<INITIAL>[^ \t()&|]+          return 'URL';
<INITIAL>&&	                  return 'AND';
<INITIAL>||                   return 'OR';
<INITIAL>'('                  return 'LPAREN';
<INITIAL>')'                  return 'RPAREN';
<INITIAL>[ \t\n]+             /* ignore */
<INITIAL>.                    return 'UNHANDLED';
