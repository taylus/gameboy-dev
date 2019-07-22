; Memory-mapped I/O registers in the Game Boy's address space from $FF00 - $FFFF
; https://fms.komkon.org/GameBoy/Tech/Software.html

LCD_CTRL EQU $FF40
SCROLLY EQU $FF42
SCROLLX EQU $FF43
CURR_SCANLINE EQU $FF44
BG_PAL EQU $FF47
OBJ0_PAL EQU $FF48
OBJ1_PAL EQU $FF49
INTERRUPT_ENABLE EQU $FFFF

; Other important memory locations:
; http://gameboy.mongenel.com/dmg/asmmemmap.html

VRAM_TILES EQU $8000
VRAM_BG_MAP_1 EQU $9800
VRAM_BG_MAP_2 EQU $9C00
