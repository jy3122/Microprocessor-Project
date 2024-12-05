#include <xc.inc>
extrn Length1,LCD_Setup,LCD_Clear,LCD_Write_Hex
extrn Length1
psect code,class=CODE
org 0x00
goto Setup
 
 
 Setup:
    call LCD_Setup
    call LCD_Clear
    goto Main_Loop
    
 Main_Loop:
    ;movlw Length1
    movf Length1,W
    call LCD_Write_Hex
    goto Loop
    
 Loop:
    bra Loop