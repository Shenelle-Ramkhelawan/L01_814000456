#include <p18f452.h>

#pragma config OSC = HS
#pragma config WDT = OFF
#pragma config LVP = OFF

void main(void)
{
    int count = 1;
    TRISB = 0;
    
    while(count<16)
    {
        PORTB = count;
        count++;
    }
}