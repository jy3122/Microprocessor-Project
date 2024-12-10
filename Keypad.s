#include <xc.inc>
 
global  Keypad_Setup, find_column, find_row, combine, find_key
extrn Decode_Morse
 
psect   udata_acs
column:     ds 1
row:        ds 1
result:     ds 1
delay_count: ds 1

psect   keypad_code, class=CODE
Keypad_Setup:
    movlb   15
    bsf     REPU        ; Enable pull-ups on PORT E
    movlb   0           ; Return to bank 0 for normal operations
    clrf    LATE,A      ; Clear LATE register to set all E port pins low
 
find_column:
    movlw   0xF0        ; Set upper nibble high and lower nibble low for column reading
    movwf   TRISE, A    ; Set PORT E upper pins as inputs and lower pins as outputs
    movlw 0xFF            ; Load 0xFF into W for delay counter initialization
    movwf delay_count, A  ; Initialize delay counter
    call    delay
    movf    PORTE, W, A ; Read PORT E value
    movwf   column, A   ; Store column value
 
find_row:
    movlw   0x0F        ; Set lower nibble high and upper nibble low for row reading
    movwf   TRISE, A    ; Set PORT E lower pins as inputs and upper pins as outputs
    movlw 0xFF            ; Load 0xFF into W for delay counter initialization
    movwf delay_count, A  ; Initialize delay counter
    call    delay
    movf    PORTE, W, A ; Read PORT E value
    movwf   row, A      ; Store row value
 
combine:
    movf    row, W, A
    iorwf   column, W, A ; Combine row and column values
    movwf   result, A   ; Store the result for decoding
    movlw   0xFF        ; XOR with 0xFF to invert bits
    xorwf   result, W, A
    movwf   result, A
 
find_key:
    bra     nextD      ; Branch to next check if not equal

 
nextD:
    movlw   01001000B       ; Binary pattern for 'D'
    cpfseq  result, A       ;Compare file register skip if equal
    bra     nextC
    call    Decode_Morse
    return
 

nextC:
    movlw   10001000B       ; Binary pattern for 'C' 
    cpfseq  result, A
    goto find_key
    retlw   'C'        ; Return ASCII 'C'

delay:
    decfsz delay_count, A ; Decrement the delay counter until zero
    bra delay             ; Loop until counter is zero
    return                ; Return from delay subroutine






