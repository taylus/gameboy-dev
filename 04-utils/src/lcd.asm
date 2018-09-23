INCLUDE "game.inc"
INCLUDE "hardware.inc"
SECTION "lcd routines", ROMX
lcd_off::
    ; wait for vblank
    ldh a, [rLY]
    cp SCREEN_HEIGHT_IN_TILES * PIXELS_PER_TILE
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

; Translates a tile number ($0 - $167) into a tile address starting from _SCRN0,
; ignoring the scroll registers and skipping past off-screen tiles
; (making this useful mostly just for single-screen games).
;
; Example tile numbers => video memory addresses:
; +----------------------------------------------------------------------------+
; |   $0 => $9800 |   $1 => $9801 |   $2 => $9802 | .......... |  $13 => $9813 |
; +----------------------------------------------------------------------------+
; |  $14 => $9820 |  $15 => $9821 |  $16 => $9822 | .......... |  $27 => $9833 |
; +----------------------------------------------------------------------------+
; |  $28 => $9840 |  $29 => $9841 |  $2A => $9842 | .......... |  $3B => $9853 |
; +----------------------------------------------------------------------------+
; | ............. | ............. | ............. | .......... | ............. |
; +----------------------------------------------------------------------------+
; | $154 => $9A20 | $155 => $9A21 | $156 => $9A22 | .......... | $167 => $9A33 |
; +----------------------------------------------------------------------------+
;
; Register usage:
; de = the input tile number
; hl = the output VRAM address corresponding to the tile number in de
tile_index_to_vram_address::
    ; TODO: need division and modulo to translate index into coords?
    ; x = index % width, y = index / width
    ret