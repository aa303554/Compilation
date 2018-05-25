extern int printd(int i);
int main(void){
int j;
int _t1;
j=123;
printd(-j);
printd(-123);
_t1=123+0;
printd((-_t1));
_t1=j+0;
printd((-_t1));
return 0;
}
