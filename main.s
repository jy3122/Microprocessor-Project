#include <xc.inc>
extrn    LCD_Setup, LCD_Write_Message,LCD_Write_Hex, LCD_Send_Byte_D,LCD_Clear
extrn LookupTable

    
; Define variables

psect	code,abs

rst: org 0x0000
     goto Setup
     
Setup:
    call LCD_Setup
    call LCD_Clear
    call Setup_Morse
    goto Decode_Morse

    
Setup_Morse:
    bcf CFGS
    bsf EEPGD
    clrf FSR1, A                ; Clear FSR1
    clrf INDF1, A 
    clrf TBLPTRH,A
    clrf TBLPTRH,A
    clrf TBLPTRL,A
    clrf TABLAT, A
    return
 

Decode_Morse:
    ; Set table pointer to LookupTable
    movlw low highword(LookupTable)
    movwf TBLPTRU, A
    movlw high(LookupTable)
    ;call LCD_Write_Hex
    movwf TBLPTRH,A
    ;movf TBLPTRH,W
    ;call LCD_Write_Hex
    movlw low(LookupTable)
    ;call LCD_Write_Hex

    movwf TBLPTRL,A
    ;movf TBLPTRL,W
    ;call LCD_Write_Hex
    goto Decode_Loop
 
Decode_Loop:
    ; Read the length of the current table entry
    tblrd*                      ; Read the length byte from TBLPTR
    movf TABLAT, W, A           ; Store the length in W
    call LCD_Write_Hex


Loop:

    bra Loop                

 