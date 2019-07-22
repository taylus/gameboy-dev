romname = main
srcdir = src
outdir = bin

run: $(romname).gb
	bgb $(outdir)\$(romname).gb

$(romname).gb: outdir
	lcc -o $(outdir)\$(romname).gb $(srcdir)\$(romname).c

outdir:
	if not exist $(outdir) mkdir $(outdir)
    
clean:
	if exist $(outdir) rmdir /s /q $(outdir)