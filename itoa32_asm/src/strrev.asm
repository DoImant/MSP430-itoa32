;-------------------------------------------------------------------------------
; File:     strrev
; Date:     25. Dec 2021
;
; Routine to swap the order of characters of a char array from right to left.
; Example: "54321A" becomes "A12345".
;
; Parameter:
; - Start address of the char array (char* pLeft)
; - Number of characters in the array (uint8_t / unsigned char r_len)
;
; Extern call set:
; R12 = Stringbufferaddress
; R13 = length of string
;
;-------------------------------------------------------------------------------

      	.cdecls C,NOLIST, "msp430.h"   ; Processor specific definitions

 ;-------------------------------------------------------------------------------
      	.global strrev				; Declare symbol to be exported
 ;-------------------------------------------------------------------------------
	.if $DEFINED(__LARGE_CODE_MODEL__)
		.asg RETA,  RET
		.asg CALLA, CALL
    	.asg  4, RETADDRSZ
	.else
    	.asg  2, RETADDRSZ
    .endif
    .if $DEFINED(__LARGE_CODE_MODEL__) | $DEFINED(__LARGE_DATA_MODEL__)
    	.asg PUSHM.A,PUSH
    	.asg POPM.A, POP
STACK_USED .set 4
    .else
STACK_USED .set 2
    .endif
;-------------------------------------------------------------------------------

		.sect ".text:strrev"		; Code is relocatable
strrev: .asmfunc stack_usage(STACK_USED + RETADDRSZ)  ; Parameter StrBuf-Addr in R12, Strlen in R12
		ADD.W	R12, R13			; Calc most right address of char-array
												; most left address in R12, most right address in R13
		CMP.W	R13, R12			; check if R13 >= R12 -> nothing to change
		JHS rev_end					; If so, do nothing -> leave function
exchange_loop:
		MOV.B   @R13,R15			; save char (tmp)
		DEC.W   R13					; decrement right address
		MOV.B   @R12,0x0001(R13)	; write char from actual left addr. to actual addr. +1
		INC.W	R12					; increment left address
		MOV.B	R15,0xFFFF(R12) 	; write saved char (tmp) to actual right addr. -1
		CMP.W	R13, R12			; check if R13 >= R12 -> if so, anything is done
		JLO	exchange_loop 			; R13 isn't >= R12 -> next iteration.
rev_end:
		RET
		.endasmfunc
		.end




