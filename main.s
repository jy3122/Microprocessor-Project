#include <xc.inc>
; Declare external subroutines
;extrn    Setup_Timer, Button_Pressed,Start_Timer,Button_Released,Process_Timer,TIMER0_ISR,Check_Overflow
;extrn    Elapsed_Time_L,Elapsed_Time_M,Elapsed_Time_H
extrn    LCD_Setup, LCD_Write_Message,LCD_Write_Hex, LCD_Send_Byte_D,LCD_Clear
extrn    Decode_Morse,Pattern, Length, Setup_Morse, LookupTable
;extrn    Keypad_Setup, find_column, find_row, combine, find_key
; Data section for storing variables in access RAM
    

psect    udata   
delay_count: ds 1      ; Variable for delay routine counter
  

    
    
psect	code, abs	

rst: org 0x0000
     goto Setup
     
Setup:
    call LCD_Setup
    call LCD_Clear
    call Setup_Morse
    goto Start_Test
     

 
Start_Test:
    ;movlw Pattern
    ;movlw LookupTable
    ;call LCD_Write_Hex
    call Decode_Morse
 
    

Loop:

    bra Loop                

      
; Delay subroutine
delay:
    decfsz delay_count, A ; Decrement the delay counter until zero
    bra delay             ; Loop until counter is zero
    return                ; Return from delay subroutine
    end rst