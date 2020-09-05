INTERRUPT_ENABLE equ $FFFF

; vblank interrupt routine called once per frame
section "vblank", rom0[$40]
jp vblank

bank_switch_and_reload_screen: macro
    call rom_bank_switch
    call load_bgmap
endm

inc_rom_bank: macro
    ld a, [current_rom_bank]
    inc a
endm

dec_rom_bank: macro
    ld a, [current_rom_bank]
    dec a
endm

section "vblank handler", rom0
vblank:
    ; TODO: delay this to slow input down
    ; (do something like https://github.com/taylus/nes-dev/blob/master/10-palette-cycling/palette-cycling.s#L64?)
    call is_left_pressed
    jr z, .left_not_pressed
    dec_rom_bank
    bank_switch_and_reload_screen
.left_not_pressed:
    call is_right_pressed
    jr z, .right_not_pressed
    inc_rom_bank
    bank_switch_and_reload_screen
.right_not_pressed:
    reti

; set bit 0 of the interrupt enable I/O register to enable vblank interrupts,
; then set the Interrupt Master Enable (IME) register using the `ei` instruction to allow interrupts
; clobbers: HL
enable_vblank_interrupt::
    ld hl, INTERRUPT_ENABLE
    set 0, [hl]
    ei
    ret
