# Compiles a Game Boy ROM using the Rednex Game Boy Development System (RGBDS)
# https://rednex.github.io/rgbds/rgbds.7.html

romname = graphics
srcdir = src
outdir = bin
incdir = include

run: $(romname).gb
	bgb $(outdir)\$(romname).gb

$(romname).gb: main.o memory.o
	rgblink -o $(outdir)\$(romname).gb -n $(outdir)\$(romname).sym $(outdir)\main.o $(outdir)\memory.o
	rgbfix -v -p 0 -t "HELLO GRAPHICS" $(outdir)\$(romname).gb

main.o: $(srcdir)\main.asm gfx outdir
	rgbasm -o $(outdir)\main.o -i $(incdir)/ $(srcdir)\main.asm

memory.o: $(srcdir)\memory.asm outdir
	rgbasm -o $(outdir)\memory.o -i $(incdir)/ $(srcdir)\memory.asm

gfx: $(incdir)\gameboy.png
	rgbgfx -u -o $(incdir)\gameboy.2bpp $(incdir)\gameboy.png

outdir:
	if not exist $(outdir) mkdir $(outdir)
    
clean:
	if exist $(outdir) rmdir /s /q $(outdir)