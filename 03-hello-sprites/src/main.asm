SECTION "rom", ROM0
INCLUDE "constants.inc"
INCLUDE "macros.inc"

; TODO: use sprite OAM DMA transfer during vblank instead of directly manipulating OAM while screen is off
; TODO: use a timer interrupt or something to make Kirby animate (change sprite tile numbers)

; vblank interrupt routine called once per frame
SECTION "vblank", ROM0[$40]
jp vblank_handler

; entry point after boot ROM executes
SECTION "init", ROM0[$100]
jp main

; ...
; ROM header from $104 - $14F set up by rgbfix
; ...

; start executing game code at $150
SECTION "main", ROM0[$150]
main:
    ; zero out general purpose work RAM
    call clear_work_ram

    ; turn off the LCD to access VRAM
    call turn_lcd_off

    ; load graphics -- color palettes, pixel data, and background tiles (sprite tiles handled separately)
    call init_palettes
    call load_graphics
    call load_background_tiles

    ; set bit zero of the interrupt enable I/O register to enable vblank interrupts,
    ; then set the Interrupt Master Enable (IME) register using the `ei` instruction to allow interrupts
    ld hl, INTERRUPT_ENABLE
    set 0, [hl]
    ei

    ; initialize sprite OAM data
    call clear_sprite_oam
    set_kirby 80, 80

    ; turn the LCD back on to display the background tiles and sprites
    call turn_lcd_on
loop:
    halt
    jp loop

turn_lcd_off:
    ; wait for vblank
    ldh a, [CURR_SCANLINE]
    cp 144
    jr nz, turn_lcd_off  ; loop while current scanline < 144 (18 tiles x 8 px per tile)
    ld hl, LCD_CTRL
    res 7, [hl]
    ret

turn_lcd_on:
    ld hl, LCD_CTRL
    ld a, %10011010
    ld [hl], a
    ret

clear_work_ram:
    ld de, WRAM_SIZE
    ld b, 0
    ld hl, WRAM_ADDR
    call memset
    ret

clear_sprite_oam:
    ld de, SPRITE_OAM_SIZE
    ld b, 0
    ld hl, SPRITE_OAM_ADDR
    call memset
    ret

init_palettes:
    ; set background tile palette to black (11), dark gray (10), light gray (01), white (00)
    ; this makes it so that tile color data maps 1:1 (if you reverse it then all zero tiles will be a black screen)
    ; the GB's boot ROM defaults this to %11111100 (all black + white)
    ld a, %11100100
    ld [BG_PAL], a

    ; set sprite palette #0 to black, light gray, white, white
    ; (the last color is transparent)
    ld a, %11010000
    ld [OBJ0_PAL], a
    ret

load_background_tiles:
    ; set all background tiles to tile #0
    ld de, $400
    ld b, 0
    ld hl, VRAM_BG_MAP_1
    call memset
    ret

load_graphics:
    ; load sprite tile data into VRAM at tile numbers 1-4
    ld de, $80
    ld bc, sprite_graphics
    ld hl, VRAM_TILES + $10
    call memcpy
    ret

vblank_handler:
    ; ...
    reti ; reti == ei, ret (re-enables interrupts before returning)

sprite_graphics:
    incbin "kirby.2bpp"
