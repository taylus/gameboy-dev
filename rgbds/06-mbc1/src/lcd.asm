LCD_CTRL equ $FF40
CURR_SCANLINE equ $FF44

section "lcd routines", rom0
turn_lcd_off::
    ; wait for vblank
    ldh a, [CURR_SCANLINE]
    cp 144
    jr nz, turn_lcd_off  ; loop while current scanline < 144 (18 tiles x 8 px per tile)
    ld hl, LCD_CTRL
    res 7, [hl]
    ret

turn_lcd_on::
    ld hl, LCD_CTRL
    set 7, [hl]
    ret
