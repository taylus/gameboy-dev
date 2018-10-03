SECTION "math routines", ROMX

; Integer divides d by e, storing the result in d and the remainder in a.
; Register usage:
; d = input numerator, output quotient
; e = input denominator
; a = output remainder
; b = (clobbered)
div_bytes::
    xor a
    ld b, 8
.l0:
    sla d
    rla
    cp e
    jr c, .l1
    sub e
    inc d
.l1:
    dec b
    jr nz, .l0
    ret
