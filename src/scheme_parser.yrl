Nonterminals list elems elem.
Terminals '(' ')' int symbol string.
Rootsymbol list.

list -> '(' ')'       : [].
list -> '(' elems ')' : '$2'.

elems -> elem       : ['$1'].
elems -> elem elems : ['$1'|'$2'].

elem -> int    : extract_token('$1').
elem -> symbol : extract_token('$1').
elem -> string : extract_token('$1').
elem -> list   : '$1'.

Erlang code.

extract_token({_Token, _Line, Value}) -> Value.
