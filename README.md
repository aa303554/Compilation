# Compilation
**Lancer le programme :**
lex ANSI-C.l
yacc -d cfe.y
gcc -o programme y.tab.c lex.yy.c
./programme < monpseudocode
