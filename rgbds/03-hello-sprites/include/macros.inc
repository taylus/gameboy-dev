; set the given sprite number's OAM data
; args:
; \1: sprite data base address
; \2: sprite index number (for calculating offset into sprite memory)
; \3: sprite x position
; \4: sprite y position,
; \5: sprite tile number
; \6: sprite tile attributes
set_sprite: macro
    ld a, \4
    ld [(\1) + ((\2) * 4)], a  ; set y position
    ld a, \3
    ld [(\1) + ((\2) * 4) + 1], a  ; set x position
    ld a, \5
    ld [(\1) + ((\2) * 4) + 2], a  ; set tile number
    ld a, \6
    ld [(\1) + ((\2) * 4) + 3], a  ; set tile attributes
    endm

; args: x, y
set_kirby_frame_0: macro
    set_sprite player_sprite_data, 0, (\1), (\2), 2, %00100000
    set_sprite player_sprite_data, 1, (\1) + 8, (\2), 1, %00100000
    set_sprite player_sprite_data, 2, (\1), (\2) + 8, 6, %00100000
    set_sprite player_sprite_data, 3, (\1) + 8, (\2) + 8, 5, %00100000
    endm

; args: x, y
set_kirby_frame_1: macro
    set_sprite player_sprite_data, 0, (\1), (\2), 4, %00100000
    set_sprite player_sprite_data, 1, (\1) + 8, (\2), 3, %00100000
    set_sprite player_sprite_data, 2, (\1), (\2) + 8, 8, %00100000
    set_sprite player_sprite_data, 3, (\1) + 8, (\2) + 8, 7, %00100000
    endm