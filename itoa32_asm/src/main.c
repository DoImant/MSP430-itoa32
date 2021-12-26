
//////////////////////////////////////////////////////////////////////////////
/// @file main.c
/// @author Kai R. 
/// @brief Example program for a UART transmission, the auxiliary functions 
///        itoa32() or uitoa32() can be used to output numbers.
/// 
/// @date 2021-12-25
/// @version 1.0
/// 
/// @copyright Copyright (c) 2021
/// 
//////////////////////////////////////////////////////////////////////////////
#include <stdint.h>
#include "msp430g2553.h"
#include "itoa32.h"
// ------------------ Definitions ----------------------------------------------

#define DCO_01_MHZ
//#define DCO_16_MHZ

// ----------------- Gl. Variables --------------------------------------------- 
volatile unsigned char rcv;

// ------------------ PROTOTYPEN -----------------------------------------------

void UART_init(void);                         // Initialize UART-Modul UCA0
void UART_send_string(unsigned char* str);    // Send String via UCA0
void UART_send_int(long val);                 // Send integer (converted to string) via UCA0

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD; // Stop WDT
  P1DIR |= BIT0 + BIT6;     // Set LED Pins P1.0, P1.6 to output
  P2DIR = 0xFF;             // All P3.x as output -> save energy
  P2OUT = 0x00;             // All P2.x to LOW
  P3DIR = 0xFF;             // All P3.x as output -> save energy
  P3OUT = 0x00;             // All P3.x to LOW

#ifdef DCO_01_MHZ  
  BCSCTL1 = CALBC1_1MHZ;              // Set DCO to 1MHz
  DCOCTL = CALDCO_1MHZ;               // Set DCO to 1MHz
#elif defined DCO_16_MHZ
  BCSCTL1 = CALBC1_16MHZ;             // Set DCO to 16MHz
  DCOCTL = CALDCO_16MHZ;              // Set DCO to 16MHz
#endif

  //long count = 0x7FFFFFF0;
  long count = 0xFFFFFFF0;     // set a signed long value for testing purposes
  //static long count = -789;     // set a signed long value for testing purposes

  UART_init();
  _EINT();                           // Enable Interrupts
  //_bis_SR_register(LPM0_bits + GIE); // Enter LPM0, interrupts enabled     // Aktiviere globale IRs (langform)

  while(1)                            
  { 
    if (rcv == 'a')                   // Have received an a?
    {
      rcv = 0x00;                     // Reset received data
      UART_send_string("Zahl: ");     // Send number
      UART_send_int(count++);
      UART_send_string("\r\n");
    } 
  } 
}

// UCA0MCTL Register 
// Bits  7  6  5  4 | 3  2  1 | 0
//        UCBFRX      UCBRSX    UCOS16
//       0  0  0  0   0  0  1   0    ->   9600 Baud,8,N,1 / DCO  1 Mhz
//       1  0  1  1   0  0  0   1    -> 115200 Baud,8,N,1 / DCO 16 Mhz

void UART_init(void) {
  P1SEL  = BIT1 + BIT2;               // P1.1 = RXD, P1.2=TXD
  P1SEL2 = BIT1 + BIT2;               // P1.1 = RXD, P1.2=TXD

  UCA0CTL1 |= UCSWRST;
  UCA0CTL1 |= UCSSEL_2;               // Use SMCLK

#ifdef DCO_01_MHZ
  UCA0BR0 = 104;          // Set baud rate to 9600 with 1MHz clock (MSP430x2xx Family-User_Guide 15.3.13)
  UCA0BR1 = 0;            // Set baud rate to 9600 with 1MHz clock
  UCA0MCTL = UCBRS0;      // Modulation UCBRFX = 0; UCBRSx = 1, UCOS16 = 0 
#elif defined DCO_16_MHZ
  UCA0BR0 = 8;            // Set baud rate to 115200 with 16MHz clock and UCOS16 Oversampling
  UCA0BR1 = 0;            // Set baud rate to 115200 with 16MHz clock (MSP430x2xx Family-User_Guide 15.3.13)
  UCA0MCTL = UCBRF_11 | UCBRS_0 | UCOS16;     // Modulationstage for 16Mhz, Oversampling (UCOS16=1)
                                              // UCBRFX only in Oversamplingmode else 0
#endif
  UCA0CTL1 &= ~UCSWRST;   // Initialize USCI state machine
  IE2 |= UCA0RXIE;        // Enable USCI_A0 RX interrupt
}

//
// Receive an unsigned char via interrupt via the UART module UCA0 des
// MSP430G2553.
//
#pragma vector=USCIAB0RX_VECTOR
__interrupt void UART_receive_ISR(void)
{
  while (!(IFG2 & UCA0RXIFG));                // Wait until the character is received ...
  rcv = UCA0RXBUF;                            // and read it out
}

//
// Send a integer via the UART module UCA0 of the MSP430G2553
//
void UART_send_int(long int val)
{
  char strBuf[12];
  char* wpStrBuf = itoa32(strBuf, val);
  while (*wpStrBuf > 0) {
    while (!(IFG2 & UCA0TXIFG));              // Wait until USART0 TX buffer free (empty) ...
    UCA0TXBUF = *wpStrBuf++;
  }
}

//
// Send a string via the UART module UCA0 of the MSP430G2553.
//
void UART_send_string(unsigned char* str)
{
  while (*str != 0)                           // As long as the terminated sign does not appear ...
  {
    P1OUT ^= BIT0;
    while (!(IFG2 & UCA0TXIFG));		      // Wait until USART0 TX buffer free (empty) ...
    UCA0TXBUF = *str++;                       // send char
  } 
}
