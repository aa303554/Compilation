extern int printd(int i);
int main(void){
int tab[300];
int *_t100;
int _t1;
int *_t99;
_t100=tab+3;
*_t100=3;
_t100=tab+200;
*_t100=200;
_t100=tab+3;
_t1=*_t100;
printd(_t1);
_t100=tab+200;
_t1=*_t100;
printd(_t1);
_t100=tab+200;
_t99=tab+3;
*_t99=*_t100;
_t100=tab+3;
_t1=*_t100;
printd(_t1);
_t100=tab+0;
*_t100=0;
_t100=tab+400;
*_t100=400;
_t100=tab+0;
_t1=*_t100;
printd(_t1);
_t100=tab+400;
_t1=*_t100;
printd(_t1);
_t100=tab+0;
_t99=tab+400;
*_t99=*_t100;
_t100=tab+400;
_t1=*_t100;
printd(_t1);
}
