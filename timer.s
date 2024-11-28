#include <xc.inc>
    
global Setup_Timer, Button_Pressed,Start_Timer,Button_Released,Process_Timer,TIMER0_ISR
org 0x0000
goto Setup_Timer           ; Jump to main program
org 0x0008          ; High-priority interrupt vector
goto TIMER0_ISR     ; Jump to Timer0 interrupt service routine

    

; Variables in RAM

Overflow_Count   EQU 0x20   ; Counter for Timer0 overflows

TMR0_HIGH        EQU 0x21   ; High byte of Timer0 value

TMR0_LOW         EQU 0x22   ; Low byte of Timer0 value

Elapsed_Time_L   EQU 0x23   ; Low byte of elapsed time
   
Elapsed_Time_M   EQU 0x24   ;mid bit

Elapsed_Time_H   EQU 0x25   ; High byte of elapsed time
 
; Initialization Routine

Setup_Timer:

    clrf Overflow_Count, A ; Reset overflow counter
 
    ; Set up Timer0

    movlw 0b10000111    ; Configure Timer0: 16-bit, Fosc/4, 1:256 prescaler

    movwf T0CON,A

    clrf TMR0L,A          ; Clear Timer0 low byte

    clrf TMR0H,A          ; Clear Timer0 high byte
    
    movlw 0b10100000
    movwf INTCON,A
    
    ;bcf INTCON,TMR0IF   ; Clear Timer0 interupt flag

    ;bsf INTCON, TMR0IE  ; Enable Timer0 interrupt, bit set file

    ;bsf INTCON, GIE     ; Enable global interrupts
   
 
    ; Configure RJ0 as input

    bsf TRISJ, 0,A        ; Set RJ0 (PORTJ, bit 0) as input
 
Button_Pressed:

    btfss PORTJ, 0,A      ; Wait for RJ0 to go high, bit test file, skip if set

    goto Button_Pressed ;loop until pressed
 
    ; Start Timer0
    goto Start_Timer
    
Start_Timer:
    bcf T0CON, TMR0ON   ;bit clear file, i.e. stop timer
    clrf TMR0L,A       ;clear timer
    clrf TMR0H,A
    clrf Overflow_Count,A
    clrf Elapsed_Time_L,A
    clrf Elapsed_Time_M,A
    clrf Elapsed_Time_H,A
    bsf T0CON,TMR0ON     ;start timer
    
Button_Released:
    btfsc PORTJ,0,A
    goto Button_Release;loop until released
    
    ; if released
    bcf T0CON, TMR0ON      ; stop Timer
    call Process_Timer     
    goto Button_Pressed      
    
Process_Timer:
    ; Get current Timer0 tick value (16 bits)
    movf TMR0L, W,A         
    movwf TMR0_LOW,A        
    movf TMR0H, W,A         ; W = 0x02
    movwf TMR0_HIGH,A       ; TMR0_HIGH = 0x02
 
 
    movf Overflow_Count, W,A           
    movwf Elapsed_Time_H,A   ; high 8 bit = overflowcount
    
    movf TMR0H, W,A           
    movwf Elapsed_Time_M,A   ; ELAPSED_TIME_M = high bit of TMR0
    
    movf TMR0L, W,A           
    movwf Elapsed_Time_L,A   ; ELAPSED_TIME_L = Low bit of TMR0
    
    
    return
    

TIMER0_ISR:

    btfss INTCON, TMR0IF ; Check if Timer0 overflowed (flag)

    retfie FAST          ; Return if not a Timer0 interrupt, return from interrupt enable
 
    incf Overflow_Count, F ; Increment overflow counter, increment file register, save to file

    bcf INTCON, TMR0IF     ; Clear Timer0 interrupt flag

    retfie FAST            ; Return from interrupt
 end

