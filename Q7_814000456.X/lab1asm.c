#include <p18f452.h>
#include <delays.h>
#include "xlcd.h"
#include <string.h>
#include <stdio.h>

#pragma config OSC = HS
#pragma config WDT = OFF //Disable watchdog timer
#pragma config LVP = OFF //Disable low voltage programming

unsigned int MapIndex = 0;
extern void intMapName(void);
extern char getMapChar(void);
extern char MapName;
char grpName[7];


#define _XTAL_FREQ 4000000UL

void DelayFor18TCY(void){
    Nop(); Nop(); Nop(); Nop(); Nop(); Nop();
    Nop(); Nop(); Nop(); Nop(); Nop(); Nop();
    Nop(); Nop(); Nop(); Nop(); Nop();
    Nop();
}

void DelayPORXLCD(void){  //Delay 15ms
    Delay1KTCYx(0x96);
}

void DelayXLCD(void){   //Delay 5ms
    Delay1KTCYx(0x05);
}
 

void init_lcd(){
    OpenXLCD(FOUR_BIT & LINES_5X7);
    while( BusyXLCD() );
    SetDDRamAddr(0x00);
    WriteCmdXLCD( SHIFT_DISP_LEFT );
    while( BusyXLCD() );
    WriteCmdXLCD( BLINK_ON );
}

void populate_array(){
    for(MapIndex=0;MapIndex<=6;MapIndex++){
        grpName[MapIndex] = getMapChar();
    }
    
}

void main(void){
    
    PORTD = 0X00;
    TRISD = 0x00;
    intMapName();
    populate_array();
    init_lcd();
    while(1){
        while( BusyXLCD() );
        putsXLCD(grpName);
        while( BusyXLCD() );
        while(1){}
    }
       
}