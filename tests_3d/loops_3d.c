extern int printd(int i);
int main(void){
int i;
i=0;
goto L1;
L2: printd(i);
i=i+2;
L1: if (i<10) goto L2;
i=-10;
L3: if (i>10) goto L4;
printd(i);
i=i+1;
goto L3;
L4: i=0;
goto L5;
L6: printd(i);
i=i-1;
L5: if (i>=-20) goto L6;
return 0;
}
