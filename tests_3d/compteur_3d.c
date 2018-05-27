extern int printd(int i);
int main(void){
int i;
i=0;
L1: if (i>=1000) goto L2;
printd(i);
i=i+1;
goto L1;
L2: return 0;
}
