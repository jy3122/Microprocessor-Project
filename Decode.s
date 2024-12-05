#include <xc.inc>
global Decode_Morse, Display_Result
extrn LCD_Send_Byte_D, LookupTable, LookupTable_End,Pattern, Length
 
psect udata_acs
tem_length: ds 1         ; Temporary storage for input Pattern length
bit_count:  ds 1         ; Temporary storage for remaining bytes to compare
 
psect morse_decoder, class=CODE
 
; Decodes the Morse code stored in Pattern
Decode_Morse:
    movlw LookupTable        ; Load the starting address of the LookupTable
    movwf FSR0, A            ; Set FSR2 to point to the LookupTable
    goto Decode_Loop
Decode_Loop:
    ; Compare Length
    movf Length, W, A        ; Load the length of the input Morse code
    movwf tem_length, A      ; Store it in tem_length
    subwf INDF0, W, A        ; Compare it with the Length of the current table entry
    btfss STATUS, 2, A       ; Skip if the lengths match (Z flag is set)
    goto Next_Entry          ; If lengths don't match, jump to the next entry
 
    ; Compare Pattern
    incf FSR0, F, A          ; Move to the start of the Pattern in the current entry
    movlw Pattern            ; Load the starting address of the input Pattern
    movwf FSR1, A            ; Set FSR1 to point to the input Pattern
    movf tem_length, W, A    ; Load the number of bytes to compare
    movwf bit_count, A       ; Store it in bit_count
    goto Compare_Pattern
 
Compare_Pattern:
    movf INDF1, W, A         ; Load the current byte from the input Pattern
    xorwf INDF0, W, A        ; Compare it with the current byte from the table Pattern
    btfsc STATUS, 2, A       ; If bytes match, skip the next instruction
    goto Next_Entry          ; If bytes don't match, jump to the next entry
    incf FSR1, F, A          ; Move the input Pattern pointer to the next byte
    incf FSR0, F, A          ; Move the table Pattern pointer to the next byte
    decfsz bit_count, F, A   ; Decrease bit_count, check if all bytes are compared
    goto Compare_Pattern     ; If not finished, continue comparing
 
    ; Match found, display the character
    movf INDF0, W, A         ; Load the ASCII character from the table entry
    call Display_Result      ; Call the subroutine to display the result
    return                   ; Return after successful decoding
 
Next_Entry:
    ; Calculate the total length of the current entry and jump to the next one
    movf INDF0, W, A         ; Load Length (first byte) of the current entry
    addlw 1                  ; Add 1 for the ASCII character length
    addwf FSR0, F, A         ; Move the pointer to the start of the next entry
    movlw LookupTable_End    ; Load the end address of the LookupTable
    subwf FSR0, W, A         ; Check if the pointer has reached the end of the table
    btfsc STATUS, 2, A       ; If at the end (Z = 1), jump to Decode_Failed
    goto Decode_Failed       ; Display '?' if decoding fails
    goto Decode_Loop         ; Otherwise, continue decoding
 
Decode_Failed:
    movlw '?'                ; Load '?' into WREG
    call Display_Result      ; Display '?' on the LCD
    return                   ; Return to the caller
 
; Subroutine to display the result
Display_Result:
    call LCD_Send_Byte_D     ; Send the ASCII character in WREG to the LCD
    return                   ; Return to the caller
