#include <xc.inc>
; Declare external subroutines
extrn    Setup_Timer, Button_Pressed,Start_Timer,Button_Released,Process_Timer,TIMER0_ISR,Check_Overflow
extrn    Elapsed_Time_L,Elapsed_Time_M,Elapsed_Time_H
extrn    LCD_Setup, LCD_Write_Message,LCD_Write_Hex, LCD_Send_Byte_D
; Data section for storing variables in access RAM
    
    
psect    udata   
delay_count: ds 1      ; Variable for delay routine counter

    
    
psect	code, abs	

rst: org 0x0000
     goto setup
     
     
interrupt: org 0x0008          ; High-priority interrupt vector
           goto TIMER0_ISR     ; Jump to Timer0 interrupt service routine

 
; Main program entry point
setup:
    call Setup_Timer     ; Initialize the timer
    call LCD_Setup        ; Initialize the LCD display
    goto Main_Loop_Start
    
Main_Loop_Start:
    call Button_Pressed
    call Start_Timer
    call Button_Released
    call Check_Overflow
    ;movlw 0x80
    ;call LCD_Send_Byte_D
    
    
    ;movf Elapsed_Time_H, W, A
    ;movf PORTD, W, A
    ;call LCD_Write_Hex   ; Send the detected key to the LCD display
    
    ;movf Elapsed_Time_M, W, A
    ;call LCD_Write_Hex 
    
    ;movf Elapsed_Time_L, W, A
    ;call LCD_Write_Hex 
    
    
    
    movlw 0xFF            ; Load 0xFF into W for delay counter initialization
    movwf delay_count, A  ; Initialize delay counter
    call delay            ; Call delay subroutine
    goto Main_Loop_Start  ; Repeat the main loop
    
; Delay subroutine
delay:
    decfsz delay_count, A ; Decrement the delay counter until zero
    bra delay             ; Loop until counter is zero
    return                ; Return from delay subroutine
    end rst