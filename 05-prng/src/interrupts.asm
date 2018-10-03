INCLUDE "hardware.inc"
INCLUDE "game.inc"
SECTION "vblank interrupt", ROM0[$40]
    jp vblank

enable_interrupts::
    ld hl, rIE
    ld [hl], IEF_VBLANK
    ei
    ret
