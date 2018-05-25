extern int printd(int i);
int main(void){
int i,j;
i=3;
switch (i)case 0:printd(0);
goto L1;
case 1:printd(1);
goto L1;
case 2:printd(2);
goto L1;
case 3:printd(3);
case 4:printd(4);
default:printd(-1);
}
