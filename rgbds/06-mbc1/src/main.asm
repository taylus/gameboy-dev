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
    ld a, 4
    call bank_switch
    call load_bgmap
    call turn_lcd_on
.game_loop:
    ; TODO: bank switch on input
    halt
    jr .game_loop

load_bgmap:
    ld de, 16       ; number of bytes to memcpy (length of "TEST ROM BANK #N")
    ld bc, rom1     ; source address to memcpy from
    ld hl, $9800    ; destination address to memcpy to (bg map data #1)
    call memcpy
    ret

tileset:
    incbin "gfx/ascii.2bpp"

section "rom1", romx, bank[1]
rom1:
    db "TEST ROM BANK #1"

section "rom2", romx, bank[2]
rom2:
    db "TEST ROM BANK #2"
    
section "rom3", romx, bank[3]
rom3:
    db "TEST ROM BANK #3"

section "rom4", romx, bank[4]
rom4:
    db "TEST ROM BANK #4"

; TODO: banks and bank switching > $1F
