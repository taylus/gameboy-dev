srcdir = src
outdir = bin
srcfiles = $(wildcard $(srcdir)/*.c)
outfiles = $(patsubst $(srcdir)/%.c,$(outdir)/%.o,$(srcfiles))

run: $(outdir)\main.gb
	bgb $(outdir)\main.gb

$(outdir)\main.gb: $(outfiles)
	lcc -o $@ $^

$(outdir)/%.o: $(srcdir)/%.c outdir
	lcc -I$(srcdir) -Wa-l -c -o $@ $<

outdir:
	if not exist $(outdir) mkdir $(outdir)
    
clean:
	if exist $(outdir) rmdir /s /q $(outdir)