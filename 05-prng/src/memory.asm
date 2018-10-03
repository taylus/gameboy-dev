SECTION "memory routines", ROMX

; Copies a region of memory from one location to another.
; Register usage:
; bc = size of source in bytes
; de = source address
; hl = destination address
; a = (clobbered)
memcpy::
    ld a, [de]
    ldi [hl], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, memcpy   ; do... while((b | c) != 0)
    ret

; Sets a region of memory to the value in register d.
; Register usage:
; d = value to set at each byte of destination
; bc = size of destination in bytes
; hl = destination address
; a = (clobbered)
memset::
    ld a, d
    ldi [hl], a
    dec bc
    ld a, b
    or c
    jr nz, memset   ; do... while((b | c) != 0)
    ret
