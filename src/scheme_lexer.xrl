Definitions.

INT        = [0-9]+
SYMBOL     = [^\s\t\n\r()"'0-9][^\s\t\n\r()'"]*
STRING     = \".*\"
WHITESPACE = [\s\t\n\r]

Rules.

{INT}         : {token, {int,  TokenLine, list_to_integer(TokenChars)}}.
{SYMBOL}      : {token, {symbol, TokenLine, list_to_atom(TokenChars)}}.
{STRING}      : {token, {string, TokenLine, TokenChars}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
{WHITESPACE}+ : skip_token.

Erlang code.
