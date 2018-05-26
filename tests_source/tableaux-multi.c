/* TEST TABLEAUX MULTIDIMENSIONNELS MINIC */
extern int printd(int i);
//int tab[3][4][5];

int main() {
  int tab[3][4][5];
  tab[1][2][3] = 4;
  tab[0][1][2] = 2;
  printd(tab[1][2][3]);
  printd(tab[0][1][2]);
  tab[1][2][3] = tab[0][1][2];
  printd(tab[1][2][3]);
  printd(tab[0][1][2]);
}
