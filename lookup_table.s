#include <xc.inc>
global Length, Pattern   , LookupTable
global Write_Dash, Write_Dot
extrn LCD_Write_Hex
    
    

psect    data


LookupTable:
    ; Letters
    DB 0x02, 0x01, 0x02, 'A'      ; A: .-
    DB 0x04, 0x02, 0x01, 0x01, 0x01, 'B' ; B: -...
    DB 0x04, 0x02, 0x01, 0x02, 0x01, 'C' ; C: -.-.
    DB 3, 0x02, 0x01, 0x01, 'D' ; D: -..
    DB 1, 0x01, 'E'             ; E: .
    DB 4, 0x01, 0x01, 0x02, 0x01, 'F' ; F: ..-.
    DB 3, 0x02, 0x02, 0x01, 'G' ; G: --.
    DB 4, 0x01, 0x01, 0x01, 0x01, 'H' ; H: ....
    DB 0x02, 0x01, 0x01, 'I'       ; I: ..
    DB 4, 0x01, 0x02, 0x02, 0x02, 'J' ; J: .---
    DB 3, 0x02, 0x01, 0x02, 'K' ; K: -.-
    DB 4, 0x01, 0x02, 0x01, 0x01, 'L' ; L: .-..
    DB 2, 0x02, 0x02, 'M'       ; M: --
    DB 2, 0x02, 0x01, 'N'       ; N: -.
    DB 3, 0x02, 0x02, 0x02, 'O' ; O: ---
    DB 4, 0x01, 0x02, 0x02, 0x01, 'P' ; P: .--.
    DB 4, 0x02, 0x02, 0x01, 0x02, 'Q' ; Q: --.-
    DB 3, 0x01, 0x02, 0x01, 'R' ; R: .-.
    DB 3, 0x01, 0x01, 0x01, 'S' ; S: ...
    DB 1, 0x02, 'T'             ; T: -
    DB 3, 0x01, 0x01, 0x02, 'U' ; U: ..-
    DB 4, 0x01, 0x01, 0x01, 0x02, 'V' ; V: ...-
    DB 3, 0x01, 0x02, 0x02, 'W' ; W: .--
    DB 4, 0x02, 0x01, 0x01, 0x02, 'X' ; X: -..-
    DB 4, 0x02, 0x01, 0x02, 0x02, 'Y' ; Y: -.--
    DB 4, 0x02, 0x02, 0x01, 0x01, 'Z' ; Z: --..
 
    ; Numbers
    DB 5, 0x01, 0x02, 0x02, 0x02, 0x02, '1' ; 1: .----
    DB 5, 0x01, 0x01, 0x02, 0x02, 0x02, '2' ; 2: ..---
    DB 5, 0x01, 0x01, 0x01, 0x02, 0x02, '3' ; 3: ...--
    DB 5, 0x01, 0x01, 0x01, 0x01, 0x02, '4' ; 4: ....-
    DB 5, 0x01, 0x01, 0x01, 0x01, 0x01, '5' ; 5: .....
    DB 5, 0x02, 0x01, 0x01, 0x01, 0x01, '6' ; 6: -....
    DB 5, 0x02, 0x02, 0x01, 0x01, 0x01, '7' ; 7: --...
    DB 5, 0x02, 0x02, 0x02, 0x01, 0x01, '8' ; 8: ---..
    DB 5, 0x02, 0x02, 0x02, 0x02, 0x01, '9' ; 9: ----.
    DB 5, 0x02, 0x02, 0x02, 0x02, 0x02, '0' ; 0: -----
 
    DB 0x06                       ; End of LookupTable marker

psect table_code, class=CODE

    
    
    
Write_Dot:

    ; Load initial address of Pattern into FSR0
    clrf FSR0
    
    movlw low(Pattern)

    movwf FSR0L, A             ; Load low byte of Pattern address

    movlw high(Pattern)

    movwf FSR0H, A             ; Load high byte of Pattern address
 
    ; Add Length to calculate the current position in RAM

    movf Length, W, A          ; Get current Length

    addwf FSR0L, F, A          ; Add Length to low byte of FSR0

    btfsc STATUS, 0            ; Handle carry to high byte

    incf FSR0H, F, A
 
    ; Write '.' to the calculated position

    movlw 0x01                 ; Symbol for '.'

    movwf INDF0, A             ; Write symbol

    incf Length, F, A          ; Increment Length for next write
    
    return

 
Write_Dash:

    ; Load initial address of Pattern into FSR0
    clrf FSR0

    movlw low(Pattern)

    movwf FSR0L, A             ; Load low byte of Pattern address

    movlw high(Pattern)

    movwf FSR0H, A             ; Load high byte of Pattern address
 
    ; Add Length to calculate the current position in RAM

    movf Length, W, A          ; Get current Length

    addwf FSR0L, F, A          ; Add Length to low byte of FSR0

    btfsc STATUS, 0            ; Handle carry to high byte

    incf FSR0H, F, A
 
    ; Write '-' to the calculated position

    movlw 0x02                 ; Symbol for '-'

    movwf INDF0, A             ; Write symbol

    incf Length, F, A          ; Increment Length for next write

    return

 
