#include <xc.inc>
; Declare external subroutines
extrn    Setup_Timer, Button_Pressed,Start_Timer,Button_Released,Process_Timer,TIMER0_ISR,Check_Overflow
extrn    LCD_Setup, LCD_Write_Message,LCD_Write_Hex, LCD_Send_Byte_D,LCD_Clear
extrn    Decode_Morse,Setup_Morse
extrn    Pattern, Length, LookupTable
extrn    Keypad_Setup, find_column, find_row, combine, find_key
    
    
; Data section for storing variables in access RAM
psect    udata  
delay_count: ds 1      ; Variable for delay routine counter
Counter:ds 1
key: ds 1
  

   
psect	code,abs

rst: org 0x0000
     goto Setup
     
interrupt: org 0x0008          ; High-priority interrupt vector
           goto TIMER0_ISR     ; Jump to Timer0 interrupt service routine
Setup:
    banksel ANCON0
    clrf ANCON0         ; turning analoge inputs off
    clrf ANCON1
    clrf ANCON2
    banksel 0
    call Clear_Pattern
    clrf Length,A
    call Setup_Timer
    call LCD_Setup
    call LCD_Clear
    call Setup_Morse
    call Keypad_Setup
    bsf TRISH,2
    bsf TRISH,3
    goto Start_Test
     
Start_Test:
    clrf PORTH, A
loop_button:
    call Button_Pressed
    btfss WREG,0,A    
    goto check_RH2
    call Start_Timer
    call Button_Released
    call Check_Overflow
    ;call find_column
    ;call find_row
    ;call combine 
    ;call find_key
    ;movwf key, A
    goto loop_button
    
check_RH2:    
    btfss PORTH,2,A          ;skip next line if RH2 is pressed
    goto check_RH3
    goto handle_RH2
    
handle_RH2:
    call Decode_Morse
    goto Start_Test
    
check_RH3:
    btfss PORTH,3, A
    goto loop_button
    goto handle_RH3
    
handle_RH3:
    goto Setup 
   
      
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