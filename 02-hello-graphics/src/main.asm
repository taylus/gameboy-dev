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

    ; show tiles (0, 0) thru (20, 18) of the 32x32 bg map #1 in VRAM
    ; already set up this way by the GB's boot ROM
    ; ld a, 0
    ; ld [SCROLLX], a
    ; ld [SCROLLY], a

    ; turn off the LCD to access VRAM
    call lcd_off

    ; load tile #0 pixel data into VRAM
    ld de, $10
    ld bc, tile_graphics
    ld hl, VRAM_TILES
    call memcpy

    ; set all tiles onscreen to tile #0
    ld de, $400
    ld b, 0
    ld hl, VRAM_BG_MAP_1
    call memset

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

tile_graphics:
    incbin "tile.2bpp"

vblank:
    ld a, [SCROLLX]
    inc a
    ld [SCROLLX], a
    ld a, [SCROLLY]
    inc a
    ld [SCROLLY], a
    reti ; reti == ei, ret (re-enables interrupts before returning)
    