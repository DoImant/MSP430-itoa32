# MSP430 itoa / uitoa function for 32 bit (long) integer

This CCS project contains three assembler functions that can be called from C / C ++ programs:
* char * itoa32 (char* strBuf, int32_t val)
* char * uitoa32 (char* strBuf, int32_t val>)
* void strrev (char* strBuf)

The way it works is that of the "char * itoa (char strBuf, int16_t val)" function known from C.

The main.c file contains a sample code to demonstrate the itoa32 function.<br>
A serial console (9600,8,N,1) is required through which the letter "a" must be entered.<br>
If the input is recognized, the program outputs a number converted by itoa32<br>
into an ASCII string on the serial console.<br>  

The strrev function reverses the order of the characters in a char array and is<br>
required by the two functions itoa32 / uitoa32. However, it can also be used<br>
independently of the two functions.

## Usefull Documentation
* [MSP430x2xx Family User's Guide](https://www.ti.com/lit/ug/slau144j/slau144j.pdf)
* [Mixing C and Assembler With MSP430™ MCUs](https://www.ti.com/lit/an/slaa140a/slaa140a.pdf)
* [MSP430 Optimizing C/C++ Compiler](https://www.ti.com/lit/ug/slau132y/slau132y.pdf)<br>
* [MSP430 Assembly Language Tools](https://www.ti.com/lit/pdf/SLAU131Y)<br>
* [MSP430 Embedded Application Binary Interface (Rev. A)](https://www.ti.com/lit/pdf/slaa534)<br>


![CCS](https://github.com/DoImant/Stuff/blob/main/MSP430/itoa32.png)
