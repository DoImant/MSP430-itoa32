;-------------------------------------------------------------------------------
; File:     uitoa32.asm
; Date:     25. Dec 2021
;
; Routine for converting an unsigned long int variable into an ASCII string
;
; Parameter:
; - Start address of the char array  (char* strBuf)
; - 32 Bit unsigned integer value (uint32_t / long unsigned val)
;
; Register:
; R7 = Stringbufferaddress
; R8 = val LOW-Byte
; R9 = val HIGH-Byte
;
; Extern call set:
; R12 = Stringbufferaddress
; R13 = Integervalue LOW-Byte
; R14 = Inegervalue HIGH-Byte
;
;-------------------------------------------------------------------------------

      	.cdecls C,NOLIST, "msp430.h"	; Processor specific definitions
      
;-------------------------------------------------------------------------------
		.global uitoa32					; Declare symbol to be exported
      	.ref __mspabi_remul				; Ref to toolchain helper function from rts430_eabi
      	.ref strrev						; Ref to external function for exchanging chars (string reverse).
;-------------------------------------------------------------------------------
    .if $DEFINED(__LARGE_CODE_MODEL__)
	.asg RETA, RET
        .asg 4, RETADDRSZ
     .else
        .asg 2, RETADDRSZ
     .endif
     .if $DEFINED(__LARGE_CODE_MODEL__) | $DEFINED(__LARGE_DATA_MODEL__)
        .asg PUSHM.A,PUSH
        .asg POPM.A, POP
STACK_USED .set 8
     .else
STACK_USED .set 4
     .endif

		.sect ".text:uitoa32"
uitoa32: .asmfunc stack_usage(STACK_USED + RETADDRSZ)
		PUSH 	R7
		PUSH 	R8
		PUSH 	R9
		MOV.W	R12,R7					; Save strBuf address
		PUSH	R7						; Save strBuf twice for a later strlen calculation
		MOV.W	R13,R8					; Save val LOW
		MOV.W	R14,R9					; Save val HIGH
calc_modulo:
		MOV.W	R8, R12					; Move val LOW as dividend
		MOV.W	R9, R13					; Move val HIGH as dividend
		MOV.W	#0x000A, R14			; Divisor LOW
		CLR.W	R15						; Divisor HIGH
		CALL 	#__mspabi_remul			; Call helper for modulo (div32)
		ADD.B	#0x0030, R14			; Use remainder (modulo) of div23 + '0' = ASCII Char
		INC.W	R7						; Increment buffer
		MOV.B	R14,0xFFFF(R7)			; Write Char into buffer
calc_div:
		MOV.W	R8, R12					; Next division: the integer value
		MOV.W	R9, R13					; is reduced by a power of ten.
		MOV.W	#0x000A, R14			;
		CLR.W	R15						;
		CALL 	#__mspabi_remul			; Call helper for div32
		MOV.W 	R12, R8					; Result LOW
		MOV.W 	R13, R9					; Result HIGH
		TST.W	R9
		JNE 	calc_modulo
		TST.W	R8
		JNE		calc_modulo
string_ready:
		CLR.B	0x0000(R7)				; End of string set '\0'
		MOV.W	R7, R13
		POP.W	R7						; Get saved strBuf "start" address
		SUB.W	R7, R13					; Sub "start" address from actual incremented strBuf address value
		DEC.B	R13						; -> strlen is now in R13. Decrement 1 because of stringend value '\0'
		MOV.W	R7, R12					; "start" address is now in R12
		CALL #strrev
		MOV.W	R6,R12					; Return value of uitoa32 -> char* strBuf
		POP.W 	R9
		POP.W	R8
		POP.W	R7
		RET
       .endasmfunc

       .end

