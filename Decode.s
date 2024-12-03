#include <xc.inc>
global Decode_Morse, Display_Result
extrn LCD_Send_Byte_D,LookupTable, Pattern, Length,LookupTable_End
    
    
psect udata_acs
tem_length: ds 1 
 
 

psect morse_decoder, class=CODE

; Decodes the Morse code stored in Pattern
Decode_Morse:
    movlw LookupTable        ; Load base address of LookupTable
    movwf FSR2, A            ; Set FSR0 to LookupTable
    goto Decode_Loop
 
Decode_Loop:
    ; Compare Length
    movf Length, W, A        ; Load the length of the current Morse code input
    movwf tem_length, A      
    subwf INDF2, W, A        ; Compare with the first byte of the table entry (length)
    btfss STATUS, 2, A       ; Skip if the lengths are equal (Z flag is set)
    goto Next_Entry          ; If not equal, check the next entry
 
    ; Compare Pattern
    incf FSR2, F, A          ; Point to the Morse code pattern in the table
    movlw Pattern            ; Load address of Pattern
    movwf FSR1, A            ; Set FSR1 to Pattern
    goto Compare_Pattern
 
Compare_Pattern:
    movf INDF1, W, A         ; Load a byte from Pattern
    xorwf INDF2, W, A        ; Compare it with the table pattern, 0 if same
    btfsc STATUS, 2, A       ; Skip if bytes dismatch (Z clear)
    goto Next_Pattern_Byte   ; If not matched, skip to the next pattern byte
    goto Next_Entry          ; If mismatch, move to the next entry
 
Next_Pattern_Byte:
    incf FSR2, F, A          ; Move to the next table pattern byte
    incf FSR1, F, A          ; Move to the next input pattern byte
    decfsz tem_length, F, A  ; Decrement file register, skip if zero
    goto Compare_Pattern     ; Loop until all bytes are compared
 
    ; Match found, output the character
    incf FSR2, F, A          ; Move to the ASCII character in the table
    movf INDF2, W, A         ; Load the ASCII character
    call Display_Result      ; Call the subroutine to display the result
    return                   ; Return after successful decoding
 
Next_Entry:
    addlw 3                  ; Move to the next table entry (Length, Pattern, ASCII)
    movlw LookupTable_End    ; Check if at the end of the table
    subwf FSR2, W, A
    btfsc STATUS, 2, A       ; If FSR0 == LookupTable_End, reached the end of the table
    goto Decode_Failed       ; Go to decode failure logic if end of table is reached
    goto Decode_Loop         ; Check the next entry
 
Decode_Failed:
    movlw '?'                ; Load '?' into WREG
    call Display_Result      ; Display '?' on the LCD
    return                   ; Return to the caller
 
; Subroutine to display the result on LCD
Display_Result:
    call LCD_Send_Byte_D     ; Send WREG (ASCII character) to the LCD
    return                   ; Return to the caller

