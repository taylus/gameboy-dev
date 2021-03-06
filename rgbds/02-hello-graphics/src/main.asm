SECTION "rom", ROM0
INCLUDE "constants.inc"

; vblank interrupt routine called once per frame
SECTION "vblank", ROM0[$40]
jp vblank

; entry point after boot ROM executes
SECTION "init", ROM0[$100]
jp main

; ...
; ROM header from $104 - $14F set up by rgbfix
; ...

; start executing game code at $150
SECTION "main", ROM0[$150]
main:
    ; set background tile palette to black (11), dark gray (10), light gray (01), white (00)
    ; this makes it so that tile color data maps 1:1 (if you reverse it then all zero tiles will be a black screen)
    ; the GB's boot ROM defaults this to %11111100 (all black + white)
    ld a, %11100100
    ld [BG_PAL], a

    ; turn off the LCD to access VRAM
    call lcd_off

    ; load tile data into VRAM
    ld de, NUM_TILES * 16 ; 16 bytes per tile (8 x 8 pixels @ 2 bits per pixel)
    ld bc, tile_data
    ld hl, VRAM_TILES
    call memcpy

    ; set all background tiles to tile #0
    ld de, $400
    ld b, 0
    ld hl, VRAM_BG_MAP_1
    call memset

    ; set onscreen background tiles to the appropriate #s for displaying the source image
    ld de, $240
    ld bc, map_data
    ld hl, VRAM_BG_MAP_1
    call memcpy

    ; set bit zero of the interrupt enable I/O register to enable vblank interrupts,
    ; then set the Interrupt Master Enable (IME) register using the `ei` instruction to allow interrupts
    ld hl, INTERRUPT_ENABLE
    set 0, [hl]
    ei

    ; turn the LCD back on to display the map
    call lcd_on
loop:
    halt
    jp loop

lcd_off:
    ; wait for vblank
    ldh a, [CURR_SCANLINE]
    cp 144
    jr nz, lcd_off  ; loop while current scanline < 144 (18 tiles x 8 px per tile)
    ld hl, LCD_CTRL
    res 7, [hl]
    ret

lcd_on:
    ld hl, LCD_CTRL
    set 7, [hl]
    ret

; contains pixel data for tiles in 2-bits-per-pixel format
tile_data:
    incbin "gameboy.2bpp"

; contains tile #s which plot the tile data above to recontruct the original image
map_data:
    incbin "gameboy.tilemap"

vblank:
    ;ld a, [SCROLLX]
    ;inc a
    ;ld [SCROLLX], a
    ;ld a, [SCROLLY]
    ;inc a
    ;ld [SCROLLY], a
    reti ; reti == ei, ret (re-enables interrupts before returning)
    