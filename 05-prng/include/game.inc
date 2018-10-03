; game constants and macros
GFX_TILES       EQU 257
BYTES_PER_TILE  EQU $10  ; (8x8 pixels at 2bpp => 16 bytes per tile)         
GFX_BYTES       EQU GFX_TILES * BYTES_PER_TILE

; source code breakpoint (for supported emulators)
break: MACRO
    IF DEF(DEBUG)       ; define symbol in builds w/ rgbasm -D DEBUG
        ld b, b         ; bgb treats this as a breakpoint if enabled in Options -> Exceptions
    ENDC
ENDM

; logs a debug message (for supported emulators)
; usage:
;   debug_msg "string"
;   debug_msg "register a contains: %a%"
; http://bgb.bircd.org/manual.html#expressions
debug_msg: MACRO
    IF DEF(DEBUG)
        ld d, d
        jr .end\@
        dw $6464
        dw $0000
        db \1           ; bgb logs this message to Window -> debug messages
.end\@:
    ENDC
ENDM

; bc = bc * 2^N
; Register usage:
; bc = input and output value
mult_bc_by_pow_of_2: MACRO
    REPT \1
    sla c       ; carry flag <- MSB of c
    rl b        ; LSB of b <- carry flag
    ENDR
ENDM
