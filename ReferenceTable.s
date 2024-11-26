; Morse Code Lookup Table
; Format: [Length of Morse Code], [Morse Code Pattern], [ASCII Character]
 
LookupTable:
    ; Letters
    DT 2, B'01', 'A'      ; A: .-
    DT 4, B'1000', 'B'    ; B: -...
    DT 4, B'1010', 'C'    ; C: -.-.
    DT 3, B'100', 'D'     ; D: -..
    DT 1, B'0', 'E'       ; E: .
    DT 4, B'0010', 'F'    ; F: ..-.
    DT 3, B'110', 'G'     ; G: --.
    DT 4, B'0000', 'H'    ; H: ....
    DT 2, B'00', 'I'      ; I: ..
    DT 4, B'0111', 'J'    ; J: .---
    DT 3, B'101', 'K'     ; K: -.-
    DT 4, B'0100', 'L'    ; L: .-..
    DT 2, B'11', 'M'      ; M: --
    DT 2, B'10', 'N'      ; N: -.
    DT 3, B'111', 'O'     ; O: ---
    DT 4, B'0110', 'P'    ; P: .--.
    DT 4, B'1101', 'Q'    ; Q: --.-
    DT 3, B'010', 'R'     ; R: .-.
    DT 3, B'000', 'S'     ; S: ...
    DT 1, B'1', 'T'       ; T: -
    DT 3, B'001', 'U'     ; U: ..-
    DT 4, B'0001', 'V'    ; V: ...-
    DT 3, B'011', 'W'     ; W: .--
    DT 4, B'1001', 'X'    ; X: -..-
    DT 4, B'1011', 'Y'    ; Y: -.--
    DT 4, B'1100', 'Z'    ; Z: --..
 
    ; Numbers
    DT 5, B'01111', '1'   ; 1: .----
    DT 5, B'00111', '2'   ; 2: ..---
    DT 5, B'00011', '3'   ; 3: ...--
    DT 5, B'00001', '4'   ; 4: ....-
    DT 5, B'00000', '5'   ; 5: .....
    DT 5, B'10000', '6'   ; 6: -....
    DT 5, B'11000', '7'   ; 7: --...
    DT 5, B'11100', '8'   ; 8: ---..
    DT 5, B'11110', '9'   ; 9: ----.
    DT 5, B'11111', '0'   ; 0: -----
 
    DB 0x00               ; End of Table Marker

 


