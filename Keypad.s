#include <xc.inc>
 
global  Keypad_Setup, find_column, find_row, combine, find_key
 
psect   udata_acs
column:     ds 1
row:        ds 1
result:     ds 1
delay_count: ds 1      ; Variable for delay routine counter
 
psect   keypad_code, class=CODE
Keypad_Setup:
    movlb   15
    bsf     REPU        ; Enable pull-ups on PORT E
    movlb   0           ; Return to bank 0 for normal operations
    clrf    LATE,A      ; Clear LATE register to set all E port pins low
 
find_column:
    movlw   0xF0        ; Set upper nibble high and lower nibble low for column reading
    movwf   TRISE, A    ; Set PORT E upper pins as inputs and lower pins as outputs
    call    delay
    movf    PORTE, W, A ; Read PORT E value
    movwf   column, A   ; Store column value
 
find_row:
    movlw   0x0F        ; Set lower nibble high and upper nibble low for row reading
    movwf   TRISE, A    ; Set PORT E lower pins as inputs and upper pins as outputs
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
    clrf   TRISF,A
    movwf    PORTF,A
 
find_key:
;     movlw   0x00
;     cpfseq  result, A  ; Compare result with 0x00, skip if equal
;    retlw 0x00
    bra     next1      ; Branch to next check if not equal
;    retlw   0x00       ; Return 0x00 if no key pressed
 
next1:
    movlw   00010001B       ; Binary pattern for '1' (01110111)
    cpfseq  result, A  ; Compare and skip if equal
    bra     next2
    retlw   '1'        ; Return ASCII '1'
 
next2:
    movlw   00010010B       ; Binary pattern for '2' (10110111)
    cpfseq  result, A
    bra     next3
    retlw   '2'        ; Return ASCII '2'
 
next3:
    movlw   00010100B       ; Binary pattern for '3' (11010111)
    cpfseq  result, A
    bra     nextF
    retlw   '3'        ; Return ASCII '3'
 
nextF:
    movlw   00011000B       ; Binary pattern for 'F' (11100111)
    cpfseq  result, A
    bra     next4
    retlw   'F'        ; Return ASCII 'F'
 
next4:
    movlw   00100001B       ; Binary pattern for '4' (01111011)
    cpfseq  result, A
    bra     next5
    retlw   '4'        ; Return ASCII '4'
 
next5:
    movlw   00100010B       ; Binary pattern for '5' (10111011)
    cpfseq  result, A
    bra     next6
    retlw   '5'        ; Return ASCII '5'
 
next6:
    movlw   00100100B       ; Binary pattern for '6' (11011011)
    cpfseq  result, A
    bra     nextE
    retlw   '6'        ; Return ASCII '6'
 
nextE:
    movlw   00101000B       ; Binary pattern for 'E' (11101011)
    cpfseq  result, A
    bra     next7
    retlw   'E'        ; Return ASCII 'E'
 
next7:
    movlw   01000001B       ; Binary pattern for '7' (01111101)
    cpfseq  result, A
    bra     next8
    retlw   '7'        ; Return ASCII '7'
 
next8:
    movlw   01000010B       ; Binary pattern for '8' (10111101)
    cpfseq  result, A
    bra     next9
    retlw   '8'        ; Return ASCII '8'
 
next9:
    movlw   01000100B       ; Binary pattern for '9' (11011101)
    cpfseq  result, A
    bra     nextD
    retlw   '9'        ; Return ASCII '9'
 
nextD:
    movlw   01001000B       ; Binary pattern for 'D' (11101101)
    cpfseq  result, A
    bra     nextA
    retlw   'D'        ; Return ASCII 'D'
 
nextA:
    movlw   10000001B       ; Binary pattern for 'A' (01111110)
    cpfseq  result, A
    bra     next0
    retlw   'A'        ; Return ASCII 'A'
 
next0:
    movlw   10000010B       ; Binary pattern for '0' (10111110)
    cpfseq  result, A
    bra     nextB
    retlw   '0'        ; Return ASCII '0'
 
nextB:
    movlw   10000100B       ; Binary pattern for 'B' (11011110)
    cpfseq  result, A
    bra     nextC
    retlw   'B'        ; Return ASCII 'B'
 
nextC:
    movlw   10001000B       ; Binary pattern for 'C' (11101110)
    cpfseq  result, A
    bra     nextnobu
    retlw   'C'        ; Return ASCII 'C'
    
nextnobu:
    retlw ' '

delay:
    decfsz delay_count, A ; Decrement the delay counter until zero
    bra delay             ; Loop until counter is zero
    return                ; Return from delay subroutine
 
    end







