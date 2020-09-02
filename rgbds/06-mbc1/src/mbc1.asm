MBC1_ROM_BANK equ $2000
MBC1_RAM_BANK equ $4000
MBC1_RAM_BANKING_MODE equ $6000

section "bank switching routines for MBC1", rom0

; switch the MBC to ROM banking mode
set_rom_banking_mode: macro
    push af
    xor a
    ld [MBC1_RAM_BANKING_MODE], a
    pop af
endm

; switch to the ROM bank specified by A
; clobbers: A
rom_bank_switch::
    ; write lower 5 bits to $2000 (TODO: need to mask?)
    ld [MBC1_ROM_BANK], a

    ; switch to ROM banking mode (may have been in RAM banking mode)
    set_rom_banking_mode

    ; write upper 2 bits to $4000
    ; see: https://b13rg.github.io/Gameboy-Bank-Switching/#switching-to-a-rom-bank--1f
    rept 5
        rrca    ; rotate right 5 times to move bits 6 and 7 into position
    endr
    ld [MBC1_RAM_BANK], a
    ret
