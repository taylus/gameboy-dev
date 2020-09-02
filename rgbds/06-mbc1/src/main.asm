section "startup", rom0[$100]
jp main

section "main", rom0[$150]
main:
    call turn_lcd_off
load_tileset:
    ld de, $800     ; number of bytes to memcpy
    ld bc, tileset  ; source address to memcpy from
    ld hl, $8000    ; destination address to memcpy to (tileset VRAM)
    call memcpy
game:
    ld a, $7F
    call rom_bank_switch
    call load_bgmap
    call turn_lcd_on
.game_loop:
    ; TODO: bank switch on input
    halt
    jr .game_loop

load_bgmap:
    ld de, 16       ; number of bytes to memcpy (length of "TEST ROM BANK NN")
    ld bc, rom1     ; source address to memcpy from
    ld hl, $9800    ; destination address to memcpy to (bg map data #1)
    call memcpy
    ret

tileset:
    incbin "gfx/ascii.2bpp"
