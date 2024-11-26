#include <xc.inc>
org 0x0000
goto Setup_Timer           ; Jump to main program
org 0x0008          ; High-priority interrupt vector
goto TIMER0_ISR     ; Jump to Timer0 interrupt service routine
 
; Variables in RAM

Overflow_Count   EQU 0x20   ; Counter for Timer0 overflows

TMR0_HIGH        EQU 0x21   ; High byte of Timer0 value

TMR0_LOW         EQU 0x22   ; Low byte of Timer0 value

ELAPSED_TIME_L   EQU 0x23   ; Low byte of elapsed time

ELAPSED_TIME_H   EQU 0x24   ; High byte of elapsed time
 
; Initialization Routine

Setup_Timer:

    CLRF Overflow_Count ; Reset overflow counter
 
    ; Set up Timer0

    MOVLW 0b10000111    ; Configure Timer0: 16-bit, Fosc/4, 1:256 prescaler

    MOVWF T0CON

    CLRF TMR0L          ; Clear Timer0 low byte

    CLRF TMR0H          ; Clear Timer0 high byte
    
    BCF INTCON,TMR0IF   ; Clear Timer0 interupt flag

    BSF INTCON, TMR0IE  ; Enable Timer0 interrupt, bit set file

    BSF INTCON, GIE     ; Enable global interrupts
    ;0b10100000
 
    ; Configure RJ0 as input

    BSF TRISJ, 0        ; Set RJ0 (PORTJ, bit 0) as input
 
Button_Pressed:

    btfss PORTJ, 0      ; Wait for RJ0 to go high, bit test file, skip if set

    goto Button_Pressed ;loop until pressed
 
    ; Start Timer0
    goto Start_Timer
    
Start_Timer:
    bcf T0CON, TMR0ON   ;bit clear file, i.e. stop timer
    clrf TMR0L       ;clear timer
    clrf TMR0H
    clrf Overflow_Count
    bsf T0CON,TMR0ON     ;start timer
    
Button_Release:
    btfsc PORTJ,0
    goto Button_Release;loop until released
    
    ; if released
    bcf T0CON, TMR0ON      ; stop Timer
    call Process_Timer     
    goto Button_Pressed      
    
Process_Timer:
    movf TMR0L,W
    movwf TMR0_LOW
    movf TMR0H,W
    movwf TMR0_HIGH
    
    
   


TIMER0_ISR:

    btfss INTCON, TMR0IF ; Check if Timer0 overflowed (flag)

    retfie FAST          ; Return if not a Timer0 interrupt, return from interrupt enable
 
    incf Overflow_Count, F ; Increment overflow counter, increment file register, save to file

    bcf INTCON, TMR0IF     ; Clear Timer0 interrupt flag

    retfie FAST            ; Return from interrupt


