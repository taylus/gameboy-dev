srcdir = src
incdir = include
srcfiles = $(wildcard $(srcdir)/*.asm)

gfxdir = gfx
gfxfiles = $(wildcard $(gfxdir)/*.png)
gfxoutfiles = $(patsubst $(gfxdir)/%.png,$(gfxdir)/%.2bpp,$(gfxfiles))

outdir = bin
outfiles = $(patsubst $(srcdir)/%.asm,$(outdir)/%.o,$(srcfiles))

run: $(outdir)/prng.gb
	bgb $<

$(outdir)/prng.gb: $(outfiles)
	rgblink -n $(outdir)\prng.sym -m $(outdir)\prng.map -o $@ $^
	rgbfix -v -p 0 -t "PRNG TEST ROM" $@

$(outdir)/%.o: $(srcdir)/%.asm $(gfxoutfiles) outdir
	rgbasm -D DEBUG -i $(incdir)/ -i ../common/ -o $@ $<

$(gfxdir)/%.2bpp: $(gfxdir)/%.png
	rgbgfx -o $@ $<

outdir:
	if not exist $(outdir) mkdir $(outdir)

clean:
	if exist $(outdir) rmdir /s /q $(outdir)
