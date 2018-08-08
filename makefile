# Compiles a Game Boy ROM using the Rednex Game Boy Development System (RGBDS)
# https://rednex.github.io/rgbds/rgbds.7.html

romname = main
srcdir = src
outdir = bin

run: $(romname).gb
	bgb $(outdir)\$(romname).gb

$(romname).gb: $(romname).o
	rgblink -o $(outdir)\$(romname).gb -n $(outdir)\$(romname).sym  $(outdir)\$(romname).o
	rgbfix -v -p 0 -t "HELLO GAME BOY" $(outdir)\$(romname).gb

$(romname).o: $(srcdir)\$(romname).asm outdir
	rgbasm -o $(outdir)\$(romname).o $(srcdir)\$(romname).asm

outdir:
	if not exist $(outdir) mkdir $(outdir)
    
clean:
	if exist $(outdir) rmdir /s /q $(outdir)