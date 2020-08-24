romname = mbc1-test
srcdir = src
incdir = include
srcfiles = $(wildcard $(srcdir)/*.asm)

gfxdir = gfx
gfxfiles = $(wildcard $(gfxdir)/*.png)
gfxoutfiles = $(patsubst $(gfxdir)/%.png,$(gfxdir)/%.2bpp,$(gfxfiles))

outdir = bin
outfiles = $(patsubst $(srcdir)/%.asm,$(outdir)/%.o,$(srcfiles))

run: $(outdir)/$(romname).gb
	bgb $<

$(outdir)/$(romname).gb: $(outfiles)
	rgblink -n $(outdir)\$(romname).sym -m $(outdir)\$(romname).map -o $@ $^
	rgbfix -v -t "MBC1 TEST ROM" -m 1 -p 1 $@

$(outdir)/%.o: $(srcdir)/%.asm $(gfxoutfiles) outdir
	rgbasm -D DEBUG -i $(incdir)/ -i ../common/ -o $@ $<

$(gfxdir)/%.2bpp: $(gfxdir)/%.png
	rgbgfx -o $@ $<

outdir:
	if not exist $(outdir) mkdir $(outdir)

clean:
	if exist $(outdir) rmdir /s /q $(outdir)
