JOYP equ $FF00
BUTTON_DOWN equ $80
BUTTON_UP equ $40
BUTTON_LEFT equ $20
BUTTON_RIGHT equ $10
BUTTON_START equ $8
BUTTON_SELECT equ $4
BUTTON_B equ $2
BUTTON_A equ $1

section "joypad input routines", rom0

; joypad reading routine from Ms. Pac-Man
; as described in https://www.youtube.com/watch?v=ecTQVa42sJc&t=425
; clobbers: A, B
; output: button state is stored in A:
;         bit 7: 1 if down is pressed
;         bit 6: 1 if up is pressed
;         bit 5: 1 if left is pressed
;         bit 4: 1 if right is pressed
;         bit 3: 1 if start is pressed
;         bit 2: 1 if select is pressed
;         bit 1: 1 if B is pressed
;         bit 0: 1 if A is pressed
read_joypad::
    ; set bit 5 of JOYP to allow reading the d-pad from its lower nibble
    ld a, $20
    ld [JOYP], a
    rept 2  ; repeat to cause delay for debouncing
        ld a, [JOYP]
    endr

    ; flip all bits in A because the GB uses 0 for pressed and 1 for not pressed
    ; (while the opposite kinda makes more sense)
    cpl

    ; mask out the lower nibble we just read from JOYP and swap it w/ the upper nibble
    and a, $F
    swap a

    ; use register B to temporarily store the d-pad button state
    ; so that A can be used to read the remaining buttons
    ld b, a

    ; d-pad's done! now set bit 4 of JOYP to allow reading start/select/B/A from its lower nibble
    ld a, $10
    ld [JOYP], a
    rept 6  ; repeat to cause delay for debouncing
        ld a, [JOYP]
    endr

    ; flip and mask the bits again, then OR the d-pad button bits in from B
    cpl 
    and a, $F
    or a, b

    ; all done, button state is now stored in A per comments re: output above
    ret

is_left_pressed::
    call read_joypad
    ld b, BUTTON_LEFT
    and a, b
    ret

is_right_pressed::
    call read_joypad
    ld b, BUTTON_RIGHT
    and a, b
    ret
