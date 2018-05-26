/* TEST TABLEAUX MINIC */
extern int printd(int i);


int main() {
  int tab[300];
  tab[3] = 3;
  tab[200] = 200;
  printd(tab[3]);
  printd(tab[200]);
  tab[3] = tab[200];
  printd(tab[3]);
  tab[0] = 0;
  tab[400] = 400;
  printd(tab[0]);
  printd(tab[400]);
  tab[400] = tab[0];
  printd(tab[400]);
}
