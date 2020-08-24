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
    ; TODO: load background map text from ROM bank
    ; TODO: bank switch on input
.game_loop:
    halt
    jr .game_loop

tileset:
    incbin "gfx/ascii.2bpp"

section "rom1", romx, bank[1]
    db "TEST ROM BANK 1"

section "rom2", romx, bank[2]
    db "TEST ROM BANK 2"
    
section "rom3", romx, bank[3]
    db "TEST ROM BANK 3"
