section "memory routines", romx
; memcpy implementation for Z80
; http://voidptr.io/blog/2017/01/21/GameBoy.html
memcpy::
    ; DE = size of buffer in bytes
    ; BC = source address of buffer
    ; HL = destination address

.memcpy_loop:
    ld a, [bc]
    ld [hli], a
    inc bc
    dec de

.memcpy_check_limit:
    ld a, e
    cp $00
    jr nz, .memcpy_loop
    ld A, D
    cp $00
    jr nz, .memcpy_loop
    ret

; memset implementation for Z80
memset::
    ; DE = size of buffer in bytes
    ; B  = constant byte to set in buffer
    ; HL = destination address

.memset_loop:
    ld a, b
    ld [hli], a
    dec de

.memset_check_limit:
    ld a, e
    cp $00
    jr nz, .memset_loop
    ld A, D
    cp $00
    jr nz, .memset_loop
    ret
