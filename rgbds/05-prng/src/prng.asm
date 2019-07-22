INCLUDE "game.inc"
SECTION "prng routines", ROMX

; Initializes the pseudorandom number generator's seed with register de
; Register usage:
; de = input seed
; hl = (clobbered)
; a = (clobbered)
prng_init::
    ld a, e
    ld hl, rng_seed
    ld [hl+], a
    ld a, d
    ld [hl], a
    ret

; Generates and returns a random byte in register a using rng_seed.
; See: https://wiki.nesdev.com/w/index.php/Random_number_generator
; Register usage:
; a = output random byte
; b = (clobbered)
; hl = (clobbered)
prng::
    ld b, 8                     ; iteration count (8 bits)
    ld a, [rng_seed]
.l0:
    sla a
    ld hl, rng_seed + 1
    rl [hl]
    jr nc, .l1
    xor $2D                     ; apply xor feedback when a 1 bit is shifted out
.l1:
    dec b
    jr nz, .l0
    ld [rng_seed], a
    cp 0                        ; reload flags
    debug_msg "Random number: %a%"
    ret

SECTION "prng globals", WRAM0
rng_seed:: ds 2