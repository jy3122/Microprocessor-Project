#include <xc.inc>
global Decode_Morse, Display_Result, Setup_Morse
extrn LCD_Send_Byte_D, LookupTable, Pattern, Length, LCD_Write_Hex
 
; Define variables
psect udata_acs
tem_length: ds 1         ; Temporary storage for the current table entry length
bit_count: ds 1          ; Remaining bytes to compare

 
psect morse_decoder, class=CODE
 

Setup_Morse:
    bcf CFGS
    bsf EEPGD
    clrf FSR1, A                ; Clear FSR1
    clrf INDF1, A                
    clrf TBLPTRH,A
    clrf TBLPTRL,A
    clrf TABLAT, A
    clrf tem_length, A          ; Initialize tem_length
    clrf bit_count, A           ; Initialize bit_count
    return
 

Decode_Morse:
    ; Set table pointer to LookupTable
    movlw HIGH Pattern
    movwf FSR1H,A
    movlw LOW Pattern
    movwf FSR1L
    ;movf FSR1H,W
    ;call LCD_Write_Hex
    movlw high(LookupTable)
    movwf TBLPTRH,A
    ;movf TBLPTRH,W
    ;call LCD_Write_Hex
    movlw low(LookupTable)
    movwf TBLPTRL,A
    goto Decode_Loop
 
Decode_Loop:
    ; Read the length of the current table entry
    tblrd*                      ; Read the length byte from TBLPTR
    movf TABLAT, W, A           ; Store the length in W
    call LCD_Write_Hex
    movwf tem_length, A         ; Save it to tem_length
    movwf bit_count, A          ; Initialize bit_count with the same value
 
    ; Compare lengths
    movf Length, W, A          ; Load the length of the input pattern
    subwf tem_length, W, A      ; Compare input pattern length with table entry length
    btfss STATUS, 2, A          ; If lengths do not match, skip to the next entry (Z=1 when sub=0, match)
    goto Next_Entry
 
    ; Compare patterns
    incf TBLPTRL, F, A          ; Skip the length byte, point to pattern data
    btfsc STATUS, 0, A          ; Skip if there's no carry
    incf TBLPTRH, F, A          
    goto Compare_Pattern
 
Compare_Pattern:
    tblrd*+                     ; Read the current byte of the table pattern into TABLAT
    movf INDF1, W, A            ; Load the current byte from the input pattern
    xorwf TABLAT, W, A          ; Compare the input pattern byte with the table byte, same if 0, not same if 1
    btfss STATUS, 2, A          ; If bytes do not match, go to the next entry (Z=1 when xor=0, i.e. same pattern)
    goto Next_Entry
    incf FSR1, F, A             ; Increment input pattern pointer
    decfsz bit_count, F, A      ; Decrement remaining bytes count, skip if zero
    goto Compare_Pattern        ; If not finished, continue comparing
 
    ; Match found
    tblrd*+                     ; Read the ASCII character from the table entry
    movf TABLAT, W, A           ; Load the ASCII character into WREG
    call Display_Result         ; Display the result
    return
 
Next_Entry:
    ; Dynamically skip the remaining portion of the current table entry
    subwf bit_count, W, A       ; Calculate remaining bytes to skip
    addlw 1                     ; need to skip ascii as well
    addwf TBLPTRL, F, A         ; Skip remaining bytes
    btfsc STATUS, 0,A           ; Check if carry occurred, skip if no carry
    incf TBLPTRH, F, A          ; Increment high byte if carry occurred
  
    ; Check if the end of the table has been reached
    tblrd*                     ; Read the current table value into TABLAT     
    movlw 0x06                 ; Load the end marker value (0x06)     
    subwf TABLAT, W, A         ; Compare the current table value with 0x06     
    btfsc STATUS, 2, A         ; If the value matches (Z = 1), decode fail     
    goto Decode_Failed         ; Jump to Decode_Failed if the marker is found
  
    ; Otherwise, continue decoding
    goto Decode_Loop
 
Decode_Failed:
    movlw '?'                   ; Load '?' into WREG
    call Display_Result         ; Display '?'
    return
 
Display_Result:
    call LCD_Send_Byte_D        ; Send the ASCII character in WREG to the LCD
    return
