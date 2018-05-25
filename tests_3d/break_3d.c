extern int printd(int i);
int main(void){
int i;
i=0;
L3: if (i>=10) goto L1;
{
if (i!=5) goto L2;
goto L1;
L2: i=i+1;
}
goto L3;
L1: printd(i);
}
