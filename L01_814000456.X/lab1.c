//Shenelle Ramkhelawan
#include <p18f452.h>

#pragma config OSC = HS
#pragma config WDT = OFF
#pragma config LVP = OFF

void main(void)
{
    int count = 1;          //Initializes the variable 'count' to the value 1
    TRISB = 0;              //Configures PORTB to be an output
    PORTB= 0;
    
    while(count<16)         //Creates a while loop which will repeat as long as count<16 
    {
        PORTB = count;      //Assigns the value of count to PORTB
        count++;            //Increments the count
    }
}
