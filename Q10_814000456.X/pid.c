#include <p18f452.h>
#include <stdio.h>
#include <timers.h>
#include <stdlib.h>


#pragma config OSC = HS
#pragma config WDT = OFF 
#pragma config LVP = OFF 

extern void PidInitalize(void);
extern void PidMain(void);
extern void PidInterrupt(void);

extern unsigned char error0;
extern unsigned char error1;
extern unsigned char pidStat1;

extern unsigned char pidOut0;
extern unsigned char pidOut1;
extern unsigned char pidOut2;

void Initialize(void);
void ADConv(void);

#pragma interrupt PI_Interrupt
void PI_Interrupt (void)
{
    PidInterrupt();
}

#pragma code InterruptVectorHigh = 0x08

void InterruptVectorHigh (void)
{
  _asm
    goto PI_Interrupt 
  _endasm
}
#pragma code

unsigned int pid_out;  
unsigned short int error; 
unsigned char pid_sign;




void Initialize()
{
    unsigned char setpoint;    

    TRISA = 0x00;          
    TRISC = 0x00;      

    PR2 =   0x18;                 
    T2CON = 0x05;          

    ADCON1 = 0x00;        
    
    setpoint = 98;               

    PidInitalize();
}


void main(){
    Initialize();
    
    while(1)
    {
       
            CCPR1L = 0x03;                          
            CCP1CON = 0x1C;
            error = 15; 
            
            error0 = error & 0xFF;
            error1 = error >> 8;
            if (error== 0){
                
            }else{
                PidMain();
                pid_sign = (pidStat1 & 128) >> 7;
                pid_out = pidOut0 + pidOut1 + pidOut2;  
                 if (pid_sign == 1) 
                {
                    CCPR1L = 0x03 + pid_out;
                    CCP1CON = 0x1C + pid_out;
                }
                else 
                {
                    CCPR1L = 0x03 - pid_out;
                    CCP1CON = 0x1C - pid_out;
                }
            }
    
    }
}

    