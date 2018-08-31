Nonterminals list elems elem.
Terminals '(' ')' int symbol string.
Rootsymbol list.

list -> '(' ')'       : [].
list -> '(' elems ')' : '$2'.

elems -> elem       : ['$1'].
elems -> elem elems : ['$1'|'$2'].

elem -> int    : '$1'.
elem -> symbol : '$1'.
elem -> string : '$1'.
elem -> list   : '$1'.

Erlang code.
