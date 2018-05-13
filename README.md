# PROJET DE COMPILATION
## A propos
Projet de compilation 2017-2018  
L3 Informatique - Valrose  
MALALEL Steve & JUNG Victor  
  
## Le programme
### Ce que fait le programme
Le programme va prendre en entrée un fichier de code écrit dans un sous-ensemble de C (supposé correct) et va rendre en sortie un fichier écrit dans un sous-ensemble de C, plus proche d'un langage machine.  
Entre autre, le code généré sera un code trois adresses, et les boucles ainsi que les conditions seront remplacées par des étiquettes et des instructions goto.  
  
### Comment lancer le programme
Executer dans le terminal les commandes suivantes :
> cd dossier_du_programme  
> lex ANSI-C.l  
> yacc -d cfe.y  
> gcc -o programme y.tab.c lex.yy.c  
> ./programme < monpseudocode  

**Note** :  
dossier_du_programme : dossier dans lequel se trouve les fichiers ANSI-C.l et cfe.y  
monpseudocode : code que vous souhaitez traduire.
