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
    ld a, 1
    call rom_bank_switch
    call load_bgmap
    call load_instructions
    call enable_vblank_interrupt
    call turn_lcd_on
.game_loop:
    ; TODO: bank switch on input
    halt
    jr .game_loop

load_bgmap::
    ld de, 16       ; number of bytes to memcpy (length of "TEST ROM BANK NN")
    ld bc, rom1     ; source address to memcpy from
    ld hl, $9800    ; destination address to memcpy to (bg map data #1)
    call memcpy
    ret

load_instructions:
    ld de, 306      ; number of bytes to memcpy (length of instructions text)
    ld bc, instr    ; source address to memcpy from
    ld hl, $9900    ; destination address to memcpy to (partway into bg map data #1)
    call memcpy
    ret

tileset:
    incbin "gfx/ascii.2bpp"

charmap "->", 91
charmap "<-", 92
charmap "<OCTOCAT>", 45

instr:
    db "PRESS -> OR <-"
    rept 20
        db 0
    endr
    db "TO BANK SWITCH"
    rept 18 + (32 * 7)
        db 0
    endr
    db "<OCTOCAT>GITHUB.COM/TAYLUS"
