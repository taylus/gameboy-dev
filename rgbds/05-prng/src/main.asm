INCLUDE "game.inc"
INCLUDE "hardware.inc"
SECTION "startup", ROM0[$100]
jp main

SECTION "main", ROM0[$150]
main:
    call clear_workram
    ld de, $babe
    call prng_init
    call lcd_off
    call clear_screen
    call load_graphics
    call lcd_on
    call enable_interrupts
.game_loop:
    halt
    jr .game_loop

vblank::
    call get_random_tile_addr
    push hl
    call prng
    pop hl
    ld [hl], a
    reti

load_graphics:
    ld bc, GFX_BYTES            ; size of destination in bytes
    ld de, graphics_data        ; source address
    ld hl, _VRAM                ; destination address
    call memcpy
    ret

clear_workram:
    ld bc, $2000                ; size of destination (8 KB)
    ld d, 0                     ; byte to write
    ld hl, _RAM                 ; destination address (beginning of work RAM)
    call memset
    ret

; Generates and returns the VRAM address of a random onscreen tile.
; Register usage:
; hl = the output VRAM address of to the random tile
; de = (clobbered)
; a = (clobbered)
get_random_tile_addr:
    ; a = random byte % screen width in tiles
    call prng
    ld d, a
    ld e, SCRN_X_B
    call div_bytes

    ; a = random byte % screen height in tiles
    push af
    call prng
    ld d, a
    ld e, SCRN_Y_B
    call div_bytes

    ; de = (x, y)
    ld e, a
    pop af
    ld d, a

    ; return address of tile (x, y) in hl
    call tile_coords_to_vram_address
    ret

graphics_data:
    incbin "gfx/literals.2bpp"
