extern int printd(int i);
int fact(int n){
int _t1;
int _t2;
int _t3;
if (n>1) goto L1;
return 1;
L1: _t1=n-1;
_t2=fact(_t1);
_t3=n*_t2;
return _t3;
}
int main(void){
int _t1;
_t1=fact(10);
printd(_t1);
return 0;
}
