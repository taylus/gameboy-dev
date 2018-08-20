SECTION "rom", ROM0
INCLUDE "constants.inc"
INCLUDE "macros.inc"

; vblank interrupt routine called once per frame
SECTION "vblank", ROM0[$40]
jp vblank_handler

SECTION "timer", ROM0[$50]
jp timer_handler

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

    ; copy to HRAM the routine that uses DMA to copy sprite data from work RAM to OAM each frame during vsync
    call copy_dma_xfer_routine_to_hram

    ; turn off the LCD to access VRAM
    call turn_lcd_off

    ; load graphics -- color palettes, pixel data, and background tiles (sprite tiles handled separately)
    call init_palettes
    call load_graphics
    call load_background_tiles

    ; set the timer which fires the timer interrupt at $50
    ; bit 2 = enabled, bits 10 = frequency (00 = 4kHz, 01 = 256kHz, 10 = 64kHz, 11 = 16kHz)
    ld a, %00000100
    ld hl, TIMER_CTRL
    ld [hl], a

    ; set bits 0 and 2 of the interrupt enable I/O register to enable vblank and timer interrupts, respectively
    ; then set the Interrupt Master Enable (IME) register using the `ei` instruction to allow interrupts
    ld a, %00000101
    ld hl, INTERRUPT_ENABLE
    ld [hl], a
    ei

    ; initialize sprite OAM data
    call clear_sprite_oam
    set_kirby_frame_0 80, 80

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
    ld hl, WRAM_START_ADDR
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
    ; load 8 tiles of pixel data into VRAM at tile numbers 1-8
    ld de, $80
    ld bc, sprite_graphics
    ld hl, VRAM_TILES + $10
    call memcpy
    ret

vblank_handler:
    call HRAM_START_ADDR ; execute dma_xfer_routine copied to HRAM
    reti ; reti == ei, ret (re-enables interrupts before returning)

timer_handler:
    ld a, [player_anim_counter]
    inc a
    and 7 ; call toggle_frame every 8th execution of this handler
    jr nz, .timer_done
    call toggle_frame
.timer_done
    ld [player_anim_counter], a
    reti

; toggles the player's sprite graphics based on [player_anim_frame]
toggle_frame:
    ld a, [player_anim_frame]
    cp 1
    jr z, .frame_0
.frame_1:
    set_kirby_frame_1 80, 80
    ld a, 1
    ld [player_anim_frame], a
    ret
.frame_0:
    set_kirby_frame_0 80, 80
    ld a, 0
    ld [player_anim_frame], a
    ret

; work RAM -> sprite OAM memory transfer routine called each vblank
; copied to and executed from HRAM since the GB CPU can only access HRAM during DMA
; https://exez.in/gameboy-dma
dma_xfer_routine:
    db $F5, $3E, $C1, $EA, $46, $FF, $3E, $28, $3D, $20, $FD, $F1, $D9
    ; decompiled version of above instructions
    ; dma_xfer_routine:
    ;    ; load work RAM address $C100 into the DMA control register at $FF46
    ;    ld a, $C1
    ;    ld [$FF46], a
    ;    ; DMA transfer begins; spinwait for 160 microseconds for it to complete
    ;    ld a, $28
    ;.loop:
    ;    dec a
    ;    jr nz, .loop
    ;    ret

copy_dma_xfer_routine_to_hram:
    ld de, $0D  ; 13 bytes of instructions
    ld bc, dma_xfer_routine
    ld hl, HRAM_START_ADDR
    call memcpy
    ret

sprite_graphics:
    incbin "kirby.2bpp"

SECTION "work_ram", WRAM0[WRAM_START_ADDR + $100]
player_sprite_data: ds 16 ; 4 sprites w/ 4 bytes of data each
player_anim_counter: ds 1 ; # of timer firings before changing player animation
player_anim_frame: ds 1 ; current frame number of animation controlled by timer interrupt
