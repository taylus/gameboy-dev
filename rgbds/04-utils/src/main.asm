INCLUDE "game.inc"
INCLUDE "hardware.inc"
SECTION "startup", ROM0[$100]
jp main

SECTION "main", ROM0[$150]
main:
    call lcd_off
    call load_bg_palette
    call load_graphics
    call clear_workram
    call clear_screen
    call enable_interrupts
    call lcd_on
.game_loop:
    halt
    jr .game_loop

vblank::
    ; there's probably a more clever way to color these tiles but ¯\_(ツ)_/¯
    call clear_last_tile
    call fill_prev_prev_tile
    call fill_prev_tile
    call fill_current_tile
    call increment_current_tile_with_wrap
    reti

fill_current_tile:
    ld hl, curr_tile_x
    ld d, [hl]
    ld hl, curr_tile_y
    ld e, [hl]
    call tile_coords_to_vram_address    ; hl = vram address of tile at coords (d, e)
    ld [hl], 3                          ; set tile to tile #3 (black)
    ret

fill_prev_tile:
    ld hl, prev_tile_x
    ld d, [hl]
    ld hl, prev_tile_y
    ld e, [hl]
    call tile_coords_to_vram_address    ; hl = vram address of tile at coords (d, e)
    ld [hl], 2                          ; set tile to tile #2 (dark gray)
    ret

fill_prev_prev_tile:
    ld hl, prev_prev_tile_x
    ld d, [hl]
    ld hl, prev_prev_tile_y
    ld e, [hl]
    call tile_coords_to_vram_address    ; hl = vram address of tile at coords (d, e)
    ld [hl], 1                          ; set tile to tile #1 (light gray)
    ret

clear_last_tile:
    ld hl, last_tile_x
    ld d, [hl]
    ld hl, last_tile_y
    ld e, [hl]
    call tile_coords_to_vram_address    ; hl = vram address of tile at coords (d, e)
    ld [hl], 0                          ; set tile to tile #0 (white)
    ret

increment_current_tile_with_wrap:
    ; last tile = prev prev tile
    ld a, [prev_prev_tile_y]
    ld [last_tile_y], a
    ld a, [prev_prev_tile_x]
    ld [last_tile_x], a

    ; prev prev tile <- prev tile
    ld a, [prev_tile_y]
    ld [prev_prev_tile_y], a
    ld a, [prev_tile_x]
    ld [prev_prev_tile_x], a

    ; prev tile <- curr tile
    ld a, [curr_tile_y]
    ld [prev_tile_y], a
    ld a, [curr_tile_x]
    ld [prev_tile_x], a

    ; increment curr tile
    inc a
    ld [curr_tile_x], a
    cp SCREEN_WIDTH_IN_TILES
    jr nz, .done
.wrap_horiz:
    ; wrap around right side of screen by resetting x and incrementing y
    debug_msg "Horizontal wrap"
    xor a
    ld [curr_tile_x], a
    ld a, [curr_tile_y]
    inc a
    ld [curr_tile_y], a
    cp SCREEN_HEIGHT_IN_TILES
    jr nz, .done
.wrap_vert
    ; wrap back up to top of screen by resetting x and y
    debug_msg "Vertical wrap"
    xor a
    ld [curr_tile_x], a
    ld [curr_tile_y], a
.done
    ret

load_graphics:
    debug_msg "Loading tile data..."
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

clear_screen:
    ld bc, (_SCRN1 - _SCRN0)    ; size of destination in bytes (whole screen)
    ld d, 0                     ; byte to write (tile 0 = blank space)
    ld hl, _SCRN0               ; destination address
    call memset
    ret

graphics_data:
    incbin "gfx/tiles.2bpp"

SECTION "variables", WRAM0
curr_tile_x:: ds 1              ; 0 to SCREEN_WIDTH_IN_TILES - 1
prev_tile_x:: ds 1
prev_prev_tile_x:: ds 1
last_tile_x:: ds 1
curr_tile_y:: ds 1              ; 0 to SCREEN_HEIGHT_IN_TILES - 1
prev_tile_y:: ds 1
prev_prev_tile_y:: ds 1
last_tile_y:: ds 1
