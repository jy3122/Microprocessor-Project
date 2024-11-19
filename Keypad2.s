#include <xc.inc>
    
global  Keypad_Setup, Keypad_read_input, Keypad_result

psect	udata_acs   ; reserve data space in access ram
Keypad_counter:	ds    1	    ; reserve 1 byte for variable Keypad_counter
Keypad_row:	ds    1	    ; reserve 1 byte for pressed row
Keypad_col:	ds    1	    ; reserve 1 byte for pressed column
Keypad_result:	ds    1	    ; reserve the decoded value
delay_count:    ds    1    ; reserve one byte for counter in the delay routine

psect	keypad_code,class=CODE
    
Keypad_Setup:
    bsf	    REPU	    ; set up pullups for port E
    clrf    LATE, A        ; write 0s to LATE register
    movlw   0x0F        ; this is 00001111
    movwf   TRISE, A       ; assign to port E, 0-3 input, 4-7 output
    return
    
Keypad_scan_row:
    movlw   0x0F        ; 00001111
    movwf   LATE, A        ; drive 0-3 high, drive 4-7 low
    movlw   0x0F        ; 00001111
    movwf   TRISE, A       ; 0-3 input, 4-7 output 
    call    delay
    movf    PORTE, W, A
    andlw   0x0F        ; keep 0-3(rows), and gate
    movwf   Keypad_row, A  ; save status of row
    return
    
Keypad_scan_col:
    movlw   0xF0        ; 11110000
    movwf   LATE, A        ; drive column pins (4-7) high, row pins (0-3) low
    movlw   0xF0        ; 11110000
    movwf   TRISE, A       ; 0-3 output,4-7 input
    call    delay
    movf    PORTE, W, A
    andlw   0xF0        ; keep column status (4-7), and gate
    movwf   Keypad_col, A
    return
    
Keypad_decode:
    ; Check if the row is the 1st row (0x01)
    movf    Keypad_row, W, A       ; Load row state into W
    xorlw   00000111B              ; Compare with 0x01 (1st row)
    bnz	    Check_Row2             ; Go to check the 2nd row
 
    ; Check which column in the 1st row
    movf    Keypad_col, W, A       ; Load column state into W
    andwf   10000000B, W             ; Compare with 0x10 (1st column)
    bnz	    Check_Col2_1           ; Not the 1st column
    movlw   0x01                   ; Key '1'
    movwf   Keypad_result, A       ; Store result
    return
 
Check_Col2_1:
    movf    Keypad_col, W, A       ; Load column state into W  
    andwf   01000000B, W
    ;xorlw   11010000B                   ; Compare with 0x20 (2nd column)
    bnz	    Check_Col3_1           ; Not the 2nd column
    movlw   0x02                   ; Key '2'
    movwf   Keypad_result, A
    return
 
Check_Col3_1:
    movf    Keypad_col, W, A
    andwf   00100000B, W
    ;xorlw   0x40                   ; Compare with 0x40 (3rd column)
    bnz	    Check_Col4_1           ; Not the 3rd column
    movlw   0x03                   ; Key '3'
    movwf   Keypad_result, A
    return
 
Check_Col4_1:
    movf    Keypad_col, W, A
    andwf   00010000B, W
    ;xorlw   0x80                   ; Compare with 0x80 (4th column)
    bnz	    Check_Row2             ; Not the 4th column
    movlw   0x46                   ; Key 'F'
    movwf   Keypad_result, A
    return
 
Check_Row2:
    ; Check if the row is the 2nd row (0x02)
    movf    Keypad_row, W, A
    xorlw   00001011B, W
    bnz	    Check_Row3
 
    ; Check which column in the 2nd row
    movf    Keypad_col, W, A
    andwf   10000000B, W
    ;xorlw   0x10
    bnz	    Check_Col2_2
    movlw   0x04                   ; Key '4'
    movwf   Keypad_result, A
    return
 
Check_Col2_2:
    movf    Keypad_col, W, A
    andwf   01000000B, W
    ;xorlw   0x20
    bnz	    Check_Col3_2
    movlw   0x05                   ; Key '5'
    movwf   Keypad_result, A
    return
 
Check_Col3_2:
    movf    Keypad_col, W, A
    andwf   00100000B, W
    ;xorlw   0x40
    bnz	    Check_Col4_2
    movlw   0x06                   ; Key '6'
    movwf   Keypad_result, A
    return
 
Check_Col4_2:
    movf    Keypad_col, W, A
    andwf   00010000B, W
    ;xorlw   0x80
    bnz	    Check_Row3
    movlw   0x45                   ; Key 'E'
    movwf   Keypad_result, A
    return
 
Check_Row3:
    ; Check if the row is the 3rd row (0x04)
    movf    Keypad_row, W, A
    xorlw   00001101,W
 
    ; Check which column in the 3rd row
    movf    Keypad_col, W, A
    andwf   10000000B, W
    ;xorlw   0x10
    bnz	    Check_Col2_3
    movlw   0x07                   ; Key '7'
    movwf   Keypad_result, A
    return
 
Check_Col2_3:
    movf    Keypad_col, W, A
    andwf   01000000B, W
    ;xorlw   0x20
    bnz	    Check_Col3_3
    movlw   0x08                   ; Key '8'
    movwf   Keypad_result, A
    return
 
Check_Col3_3:
    movf    Keypad_col, W, A
    andwf   00100000B, W
    ;xorlw   0x40
    bnz	    Check_Col4_3
    movlw   0x09                   ; Key '9'
    movwf   Keypad_result, A
    return
 
Check_Col4_3:
    movf    Keypad_col, W, A
    andwf   00010000B, W
    ;xorlw   0x80
    bnz	    Check_Row4
    movlw   0x44                   ; Key 'D'
    movwf   Keypad_result, A
    return
 
Check_Row4:
    ; Check if the row is the 4th row (0x08)
    movf    Keypad_row, W, A
    xorlw   00001110,W
    bnz	    Check_Row4
    return			    ; If no key pressed, return
 
    ; Check which column in the 4th row
    movf    Keypad_col, W, A
    andwf   10000000B, W
    ;xorlw   0x10
    bnz	    Check_Col2_4
    movlw   0x41                   ; Key 'A'
    movwf   Keypad_result, A
    return
 
Check_Col2_4:
    movf    Keypad_col, W, A
    andwf   01000000B, W
    ;xorlw   0x20
    bnz	    Check_Col3_4
    movlw   0x00                   ; Key '0'
    movwf   Keypad_result, A
    return
 
Check_Col3_4:
    movf    Keypad_col, W, A
    andwf   00100000B, W
    ;xorlw   0x40
    bnz	    Check_Col4_4
    movlw   0x42                   ; Key 'B'
    movwf   Keypad_result, A
    return
 
Check_Col4_4:
    movf    Keypad_col, W, A
    andwf   00010000B, W
    ;xorlw   0x80
    return
    movlw   0x43                   ; Key 'C'
    movwf   Keypad_result, A
    return
    
Keypad_read_input:
    call    Keypad_scan_row
    call    Keypad_scan_col
    call    Keypad_decode
    return
    
delay:	
    decfsz  delay_count, A	    ; decrement until zero
    bra	    delay
    return
    
    end
