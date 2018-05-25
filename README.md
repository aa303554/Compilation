# PROJET DE COMPILATION
## A propos
Projet de compilation 2017-2018  
L3 Informatique - Valrose  
MALALEL Steve & JUNG Victor  
  
## Le programme
### Ce que fait le programme
Le programme va prendre en entrée un fichier de code écrit dans un sous-ensemble de C (supposé correct) et va rendre en sortie un fichier écrit dans un sous-ensemble de C, plus proche d'un langage machine.  
Entre autre, le code généré sera un code trois adresses, et les boucles ainsi que les conditions seront remplacées par des étiquettes et des instructions goto.  
  
### Détection d'erreur
Le programme est capable de détecter quelques erreurs, tels que une opération avec deux types différents (addition d'un void et d'un int ?) ou bien une variable non déclaré avant utilisation.  
  
### Comment lancer le programme
Executer dans le terminal les commandes suivantes.  
**Créer le programme de compilation**  
> cd dossier_du_programme  
> lex ANSI-C.l  
> yacc -d cfe.y  
> gcc -o mongcc y.tab.c lex.yy.c  
  
**Utiliser le programme de compilation**
> ./mongcc < code.c > code_3d.c  

Le code généré sera un code trois adresses.  
Le programme prend en entrée un code mini-c (ici code.c) et retourne un code mini-c trois adresses (ici code_3d.c).  
Si aucun fichier de sortie n'est spécifié, le code sera affiché sur le terminal.  

**Compiler les fichiers de test en éxécutables**
> gcc -c code_3d.c -o code_3d.o  
> gcc code_3d.o printd.o -o code_3d  

On suppose que le fichier printd.o existe déjà, et qu'il se trouve au même endroit que le fichier code_3d.o  
  
Le fichier code_3d sera un éxécutable, et pourra être éxécuté de la façon suivante :  
> ./code_3d  

**Note** :  
dossier_du_programme : dossier dans lequel se trouve les fichiers ANSI-C.l et cfe.y  
code.c : code que vous souhaitez traduire.  
code_3d.c : fichier de sortie (3 adresses).  

**Priorité d'opérateurs** : https://fr.wikibooks.org/wiki/Programmation_C/Op%C3%A9rateurs

### Execution des tests
OK...add  
OK...compteur  
OK...cond  
OK...div  
OK...expr  
OK...functions  
OK...loops  
OK...lsh  
OK...mul  
OK...neg  
OK...rsh  
OK...sub  
OK...tableaux  
OK...variables  
OK...break  
  
NO...tableaux-multi  
NO...switch  
