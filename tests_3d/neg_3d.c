extern int printd(int i);
int main(void){
int j;
int _t1;
int _t2;
j=123;
_t1=-j;
printd(_t1);
_t1=-123;
printd(_t1);
_t1=123+0;
_t2=-_t1;
printd(_t2);
_t1=j+0;
_t2=-_t1;
printd(_t2);
return 0;
}
