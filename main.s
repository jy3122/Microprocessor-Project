#include <xc.inc>
; Declare external subroutines
extrn    Setup_Timer, Button_Pressed,Start_Timer,Button_Released,Process_Timer,TIMER0_ISR
extrn    Elapsed_Time_H, Elapsed_Time_M,Elapsed_Time_L
extrn    LCD_Setup, LCD_Write_Message,LCD_Write_Hex, LCD_Send_Byte_D
; Data section for storing variables in access RAM
psect    udata_acs   
;high: ds  1   ; Variable to store the time result
;mid:  ds  1
;low:  ds  1
delay_count: ds 1      ; Variable for delay routine counter
; Code section for main program
psect	code, abs	
rst: 	org 0x0000
	goto	setup
 
; Main program entry point
setup:
    ;clrf high,A
    ;clrf mid,A
    ;clrf low,A

    call Setup_Timer     ; Initialize the keypad
    call LCD_Setup        ; Initialize the LCD display
    goto Main_Loop_Start
    
Main_Loop_Start:
    call Process_Timer      ; Identify which column is pressed
    movlw 0x80
    call LCD_Send_Byte_D
    movf Elapsed_Time_H,A
    call LCD_Write_Hex   ; Send the detected key to the LCD display
    movf Elapsed_Time_M,A
    call LCD_Write_Hex 
    movf Elapsed_Time_L,A
    call LCD_Write_Hex 
    ;movlw 0xFF            ; Load 0xFF into W for delay counter initialization
    ;movwf delay_count, A  ; Initialize delay counter
    ;call delay            ; Call delay subroutine
    goto Main_Loop_Start  ; Repeat the main loop
    
; Delay subroutine
delay:
    decfsz delay_count, A ; Decrement the delay counter until zero
    bra delay             ; Loop until counter is zero
    return                ; Return from delay subroutine
    end rst