#include <xc.inc>
; Declare external subroutines
;extrn    Setup_Timer, Button_Pressed,Start_Timer,Button_Released,Process_Timer,TIMER0_ISR,Check_Overflow
;extrn    Elapsed_Time_L,Elapsed_Time_M,Elapsed_Time_H
extrn    LCD_Setup, LCD_Write_Message,LCD_Write_Hex, LCD_Send_Byte_D,LCD_Clear
extrn    Decode_Morse,Setup_Morse
extrn Pattern, Length, LookupTable
extrn Write_Dash, Write_Dot
;extrn    Keypad_Setup, find_column, find_row, combine, find_key
; Data section for storing variables in access RAM
    

psect    udata  
delay_count: ds 1      ; Variable for delay routine counter
Counter:ds 1
  

   
psect	code,abs

rst: org 0x0000
     goto Setup
     
Setup:
    call LCD_Setup
    call LCD_Clear
    call Setup_Morse
    goto Start_Test
     

 
Start_Test:
    clrf Length,A
    call Clear_Pattern
    
    ;call Write_Dash
    ;call Write_Dash
    ;call Write_Dash
    call Write_Dot
    call Write_Dash
    call Write_Dot
    ;call Write_Dot
    ;call Write_Dot
    ;call Write_Dash
    ;call Write_Dash
    call Write_Dash
    ;call Write_Dash
    ;call Write_Dot


    ;movf Length, W
    ;clrf PORTJ
    ;movwf PORTJ,A
    ;call Print_Pattern
    ;movf Pattern
    ;call LCD_Write_Hex
  
    call Decode_Morse
 
    

Loop:

    bra Loop                

      
; Delay subroutine
delay:
    decfsz delay_count, A ; Decrement the delay counter until zero
    bra delay             ; Loop until counter is zero
    return                ; Return from delay subroutine
    
Print_Pattern:
    movlw HIGH Pattern         ; Load high byte of Pattern address
    movwf FSR1H, A             ; Set FSR1 high byte
    movlw LOW Pattern          ; Load low byte of Pattern address
    movwf FSR1L, A             ; Set FSR1 low byte
 
    clrf Counter, A            ; Initialize Counter to 0
    goto Print_Loop
 
Print_Loop:
    movf Counter, W, A         ; Load Counter into W
    subwf Length, W, A         ; Compare Counter with Length
    btfsc STATUS, 2, A            ; If Counter == Length, exit loop
    goto Print_End
 
    movf INDF1, W, A           ; Load current byte of Pattern
    call LCD_Write_Hex         ; Print current byte to LCD
 
    incf FSR1L, F, A           ; Move FSR1 to next byte
    btfsc STATUS, 0, A         ; If carry, increment FSR1H
    incf FSR1H, F, A
 
    incf Counter, F, A         ; Increment Counter
    goto Print_Loop            ; Repeat loop
 
Print_End:
    return 
    
Clear_Pattern:
    lfsr 1, Pattern            ; Load the base address of Pattern into FSR1
    movlw 8                    ; Load the size of Pattern (8 bytes)
    movwf Counter, A           ; Store it in Counter
    goto Clear_Loop
 
Clear_Loop:
    clrf POSTINC1, A           ; Clear the current byte and increment FSR1
    decfsz Counter, F, A       ; Decrement Counter, check if it reaches 0
    goto Clear_Loop            ; If not, repeat the loop
 
    return                     ; Return when all bytes are cleared
end rst