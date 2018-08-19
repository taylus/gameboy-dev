; set the given sprite number's OAM data
; args: sprite #, x, y, tile #, tile attributes
set_sprite: macro
    ld a, \3
    ld [SPRITE_OAM_ADDR + ((\1) * 4)], a  ; set y position
    ld a, \2
    ld [SPRITE_OAM_ADDR + ((\1) * 4) + 1], a  ; set x position
    ld a, \4
    ld [SPRITE_OAM_ADDR + ((\1) * 4) + 2], a  ; set tile number
    ld a, \5
    ld [SPRITE_OAM_ADDR + ((\1) * 4) + 3], a  ; set tile attributes
    endm

; args: x, y
set_kirby: macro
    set_sprite 0, (\1), (\2), 2, %00100000
    set_sprite 1, (\1) + 8, (\2), 1, %00100000
    set_sprite 2, (\1), (\2) + 8, 6, %00100000
    set_sprite 3, (\1) + 8, (\2) + 8, 5, %00100000
    endm