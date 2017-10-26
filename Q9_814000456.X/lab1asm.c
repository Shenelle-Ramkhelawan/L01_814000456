//#include<p18f452.h>
#include<xc.h>
//#include<delays.h>
#include"lcd.h"



#pragma config OSC = HS
#pragma config WDT = OFF
#pragma config LVP = OFF

#define _XTAL_FREQ 4000000
void DelayFor18TCY( void )
{
    _delay(18);
    
}

void DelayPORXLCD (void)
{
 __delay_ms(15);
}

void DelayXLCD (void)
{
 __delay_ms(5); 
}

void init_LCD(void){
    OpenXLCD( FOUR_BIT & LINES_5X7 );
    while( BusyXLCD() );
    WriteCmdXLCD( FOUR_BIT & LINES_5X7 );
    while( BusyXLCD() );
    WriteCmdXLCD( BLINK_ON );
    while( BusyXLCD() );
    WriteCmdXLCD( SHIFT_DISP_LEFT );
}
void main(void){
    init_LCD();
    while( BusyXLCD() );
    SetDDRamAddr( 0x00 );
    putrsXLCD( "TAPOUT" );
    while(1){}
    
}