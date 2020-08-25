MBC1_ROM_BANK equ $2000

section "memory bank controller routines", rom0
bank_switch::
    ; TODO: support ROM banks > $1F
    ; by writing upper two bits to $4000
    ; see: https://b13rg.github.io/Gameboy-Bank-Switching/#switching-to-a-rom-bank--1f
    ld [MBC1_ROM_BANK], a
    ret
