extern int printd(int i);
int main(void){
int tab[60];
int _t1;
int _t2;
int _t3;
int _t4;
int *_t100;
int _t5;
int _t6;
int _t7;
int _t8;
int *_t99;
_t1=1*4;
_t2=2*5;
_t3=_t1+_t2;
_t4=_t3+3;
_t100=tab+_t4;
*_t100=4;
_t1=0*4;
_t2=1*5;
_t3=_t1+_t2;
_t4=_t3+2;
_t100=tab+_t4;
*_t100=2;
_t1=1*4;
_t2=2*5;
_t3=_t1+_t2;
_t4=_t3+3;
_t100=tab+_t4;
_t5=*_t100;
printd(_t5);
_t1=0*4;
_t2=1*5;
_t3=_t1+_t2;
_t4=_t3+2;
_t100=tab+_t4;
_t5=*_t100;
printd(_t5);
_t1=0*4;
_t2=1*5;
_t3=_t1+_t2;
_t4=_t3+2;
_t100=tab+_t4;
_t5=1*4;
_t6=2*5;
_t7=_t5+_t6;
_t8=_t7+3;
_t99=tab+_t8;
*_t99=*_t100;
_t1=1*4;
_t2=2*5;
_t3=_t1+_t2;
_t4=_t3+3;
_t100=tab+_t4;
_t5=*_t100;
printd(_t5);
_t1=0*4;
_t2=1*5;
_t3=_t1+_t2;
_t4=_t3+2;
_t100=tab+_t4;
_t5=*_t100;
printd(_t5);
}
