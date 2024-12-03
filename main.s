#include <xc.inc>
; Declare external subroutines
extrn    Keypad_Setup, find_column, find_row, combine, find_key
extrn    LCD_Setup, LCD_Write_Message, LCD_Send_Byte_D
; Data section for storing variables in access RAM
psect    udata_acs   
result: ds  1   ; Variable to store the keypad result
delay_count: ds 1      ; Variable for delay routine counter
; Code section for main program
psect	code, abs	
rst: 	org 0x0
	goto	setup
 
; Main program entry point
setup:
    clrf result,A
    call Keypad_Setup     ; Initialize the keypad
    call LCD_Setup        ; Initialize the LCD display
    goto Main_Loop_Start
    
Main_Loop_Start:
    call find_column      ; Identify which column is pressed
    call find_row         ; Identify which row is pressed
    call combine          ; Combine results from row and column
    call find_key         ; Decode the pressed key
    call LCD_Send_Byte_D   ; Send the detected key to the LCD display
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