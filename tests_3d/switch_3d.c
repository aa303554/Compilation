/* WARNING : FUNCTION main MUST RETURN AN INT ! (added return 0; statement) */
extern int printd(int i);
int main(void){
int i,j;
int _t1;
i=3;
if (i==0) goto L1;
if (i==1) goto L3;
if (i==2) goto L4;
if (i==3) goto L5;
if (i==4) goto L6;
goto L7;
L1: printd(0);
goto L2;
L3: printd(1);
goto L2;
L4: printd(2);
goto L2;
L5: printd(3);
L6: printd(4);
L7: _t1=-1;
printd(_t1);
L2 :return 0;
}
