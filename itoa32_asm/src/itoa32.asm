;-------------------------------------------------------------------------------
; File:     itoa32.asm
; Date:     26. Dec 2021
;
; Routine for converting an signed int variable into an ASCII string (like itoa but 32Bit)
;
; Parameter:
; - Start address of the char array  (char* strBuf)
; - 32 Bit signed integer value (int32_t / long int val)
;
; Register:
; R6 = Stringbufferaddress
; R7 = Negative Reminder
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
        .global itoa32            ; Declare symbol to be exported
        .ref __mspabi_remul       ; Ref to toolchain helper function from rts430_eabi
        .ref strrev               ; Ref to external function for exchanging chars (string reverse).
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
;-------------------------------------------------------------------------------

        .sect ".text:itoa32"  ; Code is relocatable
itoa32: .asmfunc  stack_usage(STACK_USED + RETADDRSZ)
        PUSH    R6
        PUSH    R7
        PUSH    R8
        PUSH    R9
        MOV.W   R12,R6              ; Save strBuf address
        PUSH    R6                  ; Save strBuf twice for a later strlen calculation
        CLR.W   R7                  ; Marker for negative val init with 0
        MOV.W   R13,R8              ; Save val LOW
        MOV.W   R14,R9              ; Save val HIGH
test_overflow:                      ; check if value = 0x80000000 = overflow
        MOV.W   R8,R14              ; Make a copy of val (32 Bit)
        MOV.W   R9,R15
        AND.W   #-1, R14            ; LOW-Byte AND 0xFFFF
        AND.W   #0x7FFF, R15        ; HIGH-Bite AND 0x7FFF
        TST.W   R15
        JNE chk_negative            ; no overflow
        TST.W  R14
        JNE chk_negative            ; also no overflow
        CLR.W   R8                  ; If overflow then set val
        CLR.W   R9                  ; to 0
chk_negative:
        TST.W   R9                  ; Check if val is negative
        JGE calc_modulo             ; is positive -> do_calculation
        INV.W   R8                  ; Do two's complement because it's negative
        INV.W   R9
        INC.W   R8
        ADC.W   R9
        MOV.B   #1, R7              ; Set marker that val is negative
calc_modulo:
        MOV.W   R8, R12             ; Move val LOW as dividend
        MOV.W   R9, R13             ; Move val HIGH as dividend
        MOV.W   #0x000A, R14        ; Divisor LOW
        CLR.W   R15                 ; Divisor HIGH
        CALL #__mspabi_remul        ; Call helper for modulo (div32)
        ADD.B   #0x0030, R14        ; Use remainder (modulo) of div23 + '0' = ASCII Char
        INC.W   R6                  ; Increment buffer
        MOV.B   R14,0xFFFF(R6)      ; Write Char into buffer
calc_div:
        MOV.W   R8, R12             ; Next division: the integer value
        MOV.W   R9, R13             ; is reduced by a power of ten.
        MOV.W #0x000A, R14
        CLR.W   R15
        CALL #__mspabi_remul        ; Call helper for div32
        MOV.W   R12, R8             ; Result LOW
        MOV.W   R13, R9             ; Result HIGH
        TST.W   R9
        JNE calc_modulo
        TST.W   R8
        JNE calc_modulo
        TST.B   R7                  ; Check the sign marker.
        JEQ string_ready
        INC.W   R6
        MOV.B   #0x002D, 0xFFFF(R6) ; Set '-' sign
string_ready:
        CLR.B   0x0000(R6)          ; End of string set '\0'
        MOV.W   R6, R13
        POP.W   R6                  ; Get saved strBuf "start" address
        SUB.W   R6, R13             ; Sub "start" address from actual incremented strBuf address value
        DEC.B   R13                 ; -> strlen is now in R13. Decrement 1 because of stringend value '\0'
        MOV.W   R6, R12             ; "start" address is now in R12 for use in strrev
        CALL #strrev
        MOV.W   R6,R12              ; Return value of itoa32 -> char* strBuf
        POP.W   R9
        POP.W   R8
        POP.W   R7
        POP.W   R6
        RET
       .endasmfunc

       .end

