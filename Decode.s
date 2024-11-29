#include <xc.inc>
    
global Compare_Pattern
extrn  LCD_Send_Byte_D, Pattern, Length
    
psect udata_acs
Decoded_Char: ds 1
    

psect decode_code, class=CODE  

    
Compare_Pattern:
    
    movf Length, W, A          ; Get the length of the input pattern

    andlw 1                    ; Compare length with 1, 1 if same, 0 if different

    btfss STATUS, 2, A            ; 1 if different, 0 if same, skip if different

    goto Check_Length_1        ; Go to length-1 patterns

    movf Length, W, A          ; Get the length of the input pattern

    andlw 2                    ; Compare length with 2, 1 if same, 0 if different

    btfss STATUS, 2, A            ; 1 if different, 0 if same, skip if different

    goto Check_Length_2        ; Go to length-2 patterns
 
    movf Length, W, A          ; Compare length with 3

    andlw 3

    btfss STATUS, 2, A            ; If length == 3

    goto Check_Length_3        ; Go to length-3 patterns
 
    movf Length, W, A          ; Compare length with 4

    andlw 4

    btfss STATUS, 2, A            ; If length == 4

    goto Check_Length_4        ; Go to length-4 patterns
    
    movf Length, W, A
    
    andlw 5                    ; Compare with 5

    btfss STATUS, 2, A            ; If length == 5

    goto Check_Length_5        ; Go to length-5 patterns
 
    movlw '?'                   
    call LCD_Send_Byte_D        ; Written into LCD
    clrf Decoded_Char, A       ; If no match, clear decoded character

    return                     ; Return no match

Check_Length_1:

    movlw Pattern              ; Load Pattern base address

    movwf FSR0, A              ; Set FSR0 to point to Pattern
 
    movlw "."                 ; Check if the pattern is E "."

    call Compare_Full_Pattern

    btfsc STATUS, 2, A            ; If matched

    goto Match_E               ; Decode as 'A'
 
    movlw "-"                 ; Check if the pattern is T "-"

    call Compare_Full_Pattern

    btfsc STATUS, 2, A            ; If matched

    goto Match_T               ; Decode as 'N'
    
    movlw '?'                   
    call LCD_Send_Byte_D        ; Written into LCD
    clrf Decoded_Char, A       ; If no match, clear decoded character

    return
 
Check_Length_2:

    movlw Pattern              ; Load Pattern base address

    movwf FSR0, A              ; Set FSR0 to point to Pattern
 
    movlw ".-"                 ; Check if the pattern is A ".-"
    call Compare_Full_Pattern
    btfsc STATUS, 2            ; If matched
    goto Match_A               ; Decode as 'A'
    
    movlw ".."                 ; Check if the pattern is I ".."
    call Compare_Full_Pattern
    btfsc STATUS, 2            ; If matched
    goto Match_I               ; Decode as 'I'
    
    movlw "-."                 ; Check if the pattern is "-."
    call Compare_Full_Pattern
    btfsc STATUS, 2            ; If matched
    goto Match_N               ; Decode as 'N'
    
    movlw "--"                 ; Check if the pattern is "--"
    call Compare_Full_Pattern
    btfsc STATUS, 2            ; If matched
    goto Match_M               ; Decode as 'M'
    
    movlw '?'                   
    call LCD_Send_Byte_D        ; Written into LCD
    clrf Decoded_Char, A       ; If no match, clear decoded character

    return
    
 
Check_Length_3:

    movlw Pattern              ; Load Pattern base address

    movwf FSR0, A              ; Set FSR0 to point to Pattern
 
    movlw "-.."                ; Check if the pattern is "-.."

    call Compare_Full_Pattern

    btfsc STATUS, Z            ; If matched

    goto Match_D               ; Decode as 'D'
 
    movlw "..."                ; Check if the pattern is "..."

    call Compare_Full_Pattern

    btfsc STATUS, Z            ; If matched

    goto Match_S               ; Decode as 'S'
 
    clrf Decoded_Char, A       ; If no match, clear decoded character

    return
    
 
Check_Length_4:

    movlw Pattern              ; Load Pattern base address

    movwf FSR0, A              ; Set FSR0 to point to Pattern
 
    movlw "--.-"               ; Check if the pattern is "--.-"

    call Compare_Full_Pattern

    btfsc STATUS, Z            ; If matched

    goto Match_Q               ; Decode as 'Q'
 
    movlw "-..."               ; Check if the pattern is "-..."

    call Compare_Full_Pattern

    btfsc STATUS, Z            ; If matched

    goto Match_B               ; Decode as 'B'
 
    clrf Decoded_Char, A       ; If no match, clear decoded character

    return
    
    
 
Check_Length_5:

    movlw Pattern              ; Load Pattern base address

    movwf FSR0, A              ; Set FSR0 to point to Pattern
 
    movlw "--.-"               ; Check if the pattern is "--.-"

    call Compare_Full_Pattern

    btfsc STATUS, Z            ; If matched

    goto Match_Q               ; Decode as 'Q'
 
    movlw "-..."               ; Check if the pattern is "-..."

    call Compare_Full_Pattern

    btfsc STATUS, Z            ; If matched

    goto Match_B               ; Decode as 'B'
 
    clrf Decoded_Char, A       ; If no match, clear decoded character

    return
 
Match_A:

    movlw 'A'                  ; Decoded as 'A'

    movwf Decoded_Char, A

    return
 
Match_N:

    movlw 'N'                  ; Decoded as 'N'

    movwf Decoded_Char, A

    return


 
Match_D:

    movlw 'D'                  ; Decoded as 'D'

    movwf Decoded_Char, A

    return
 
Match_S:

    movlw 'S'                  ; Decoded as 'S'

    movwf Decoded_Char, A

    return


 
Match_Q:

    movlw 'Q'                  ; Decoded as 'Q'

    movwf Decoded_Char, A

    return
 
Match_B:

    movlw 'B'                  ; Decoded as 'B'

    movwf Decoded_Char, A

    return

Match_I:

    movlw 'I'                  ; Decoded as 'B'

    movwf Decoded_Char, A

    return
    
Match_M:

    movlw 'M'                  ; Decoded as 'B'

    movwf Decoded_Char, A

    return
    
Match_T:

    movlw 'T'                  ; Decoded as 'B'

    movwf Decoded_Char, A

    return
    
Match_E:

    movlw 'E'                  ; Decoded as 'B'
    
    call LCD_Send_Byte_D

    movwf Decoded_Char, A

    return
 
Compare_Full_Pattern:

    movwf TEMP_PTR             ; Store the address of the target pattern

    movf Length, W, A          ; Load the length of the input pattern

    movwf TEMP_REG, A          ; Store it in TEMP_REG
 
Compare_Loop:

    movf POSTINC0, W, A        ; Get the next character from input Pattern

    subwf POSTINC1, W, A       ; Compare with target Pattern

    btfss STATUS, Z            ; If not matched

    return                     ; Return no match

    decfsz TEMP_REG, F, A      ; Decrement remaining length

    goto Compare_Loop          ; Continue comparison
 
    return                     ; If all characters match, return match

 
    
    

