; TODO: interrupt vectors go here

; entry point after boot ROM executes
SECTION "init", ROM0[$100]
jp main

; ...
; ROM header from $104 - $14F set up by rgbfix
; ...

; start executing game code at $150
SECTION "main", ROM0[$150]
main:
    halt
