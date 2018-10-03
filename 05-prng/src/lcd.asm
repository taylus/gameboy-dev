INCLUDE "game.inc"
INCLUDE "hardware.inc"
SECTION "lcd routines", ROMX
lcd_off::
    ; wait for vblank
    ldh a, [rLY]
    cp SCRN_Y
    jr nz, lcd_off  ; loop while current scanline < 144 (still onscreen)
    ld hl, rLCDC
    res 7, [hl]
    ret

lcd_on::
    ld hl, rLCDC
    set 7, [hl]
    ret

load_bg_palette::
    ld a, %11100100
    ld [rBGP], a
    ret

clear_screen::
    ld bc, (_SCRN1 - _SCRN0)    ; size of destination in bytes (whole screen)
    ld d, 0                     ; byte to write (tile 0 = blank space)
    ld hl, _SCRN0               ; destination address
    call memset
    ret

; Translates tile coordinates (x, y) into a tile address starting from _SCRN0,
; ignoring the scroll registers and skipping past off-screen tiles
; (making this useful mostly just for single-screen games).
;
; Example tile coordinates => video memory addresses:
; +----------------------------------------------------------------------------+
; |  (00, 00) => $9800 | (01, 00) => $9801 | ............ |  (19, 00) => $9813 |
; +----------------------------------------------------------------------------+
; |  (00, 01) => $9820 | (01, 01) => $9821 |  ........... |  (19, 01) => $9833 |
; +----------------------------------------------------------------------------+
; |  (00, 02) => $9840 | (01, 02) => $9841 |  ........... |  (19, 02) => $9853 |
; +----------------------------------------------------------------------------+
; | .................. | ................. | ............ | ...................|
; +----------------------------------------------------------------------------+
; |  (00, 17) => $9A20 | (01, 17) => $9A21 |  ........... |  (19, 17) => $9A33 |
; +----------------------------------------------------------------------------+
;
; Register usage:
; d = the x coordinate of the input tile (0 - 19)
; e = the y coordinate of the input tile (0 - 17)
; hl = the output VRAM address corresponding to the tile number in de
; bc = (clobbered)
tile_coords_to_vram_address::
    ld b, 0
    ld c, e                 ; load bc with y coordinate in e
    mult_bc_by_pow_of_2 5   ; bc = bc * 32 (to move down one row of tiles)
    ld hl, _SCRN0
    add hl, bc
    ld b, 0
    ld c, d                 ; load bc with x coordinate in d
    add hl, bc
    ret                     ; return $9800 + (y * 32) + x
