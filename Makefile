PYTHON := python
MD5 := md5sum -c --quiet

2bpp     := $(PYTHON) extras/pokemontools/gfx.py 2bpp
1bpp     := $(PYTHON) extras/pokemontools/gfx.py 1bpp
pic      := $(PYTHON) extras/pokemontools/pic.py compress
includes := $(PYTHON) extras/pokemontools/scan_includes.py

pokered_obj := audio_red.o main_red.o text_red.o wram_red.o nuzlocke_red.o
pokeblue_obj := audio_blue.o main_blue.o text_blue.o wram_blue.o nuzlocke_blue.o

version := 0.1B

CLEAN_IMAGES := NO
.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png .2bpp .1bpp .pic
.SECONDEXPANSION:
# Suppress annoying intermediate file deletion messages.
.PRECIOUS: %.2bpp
.PHONY: all clean red blue compare

roms := pokered.gbc

all: $(roms)
red: pokered.gbc

clean:
	rm -f $(roms) $(pokered_obj) $(roms:.gbc=.sym)
ifeq ($(CLEAN_IMAGES),"YES")
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pic' \) -exec rm {} +
endif

%.asm: ;

%_red.o: dep = $(shell $(includes) $(@D)/$*.asm)
$(pokered_obj): %_red.o: %.asm $$(dep)
	rgbasm -D _RED -DVERSION="\"$(version)\"" -h -o $@ $*.asm

%_blue.o: dep = $(shell $(includes) $(@D)/$*.asm)
$(pokeblue_obj): %_blue.o: %.asm $$(dep)
	rgbasm -D _BLUE -h -o $@ $*.asm

pokered_opt  = -jsv -k 01 -l 0x33 -m 0x13 -p 0 -r 03 -t "POKEMON RED"
pokeblue_opt = -jsv -k 01 -l 0x33 -m 0x13 -p 0 -r 03 -t "POKEMON BLUE"

%.gbc: $$(%_obj)
	rgblink -n $*.sym -l pokered.link -o $@ $^
	rgbfix $($*_opt) $@
	sort $*.sym -o $*.sym

%.png:  ;
%.2bpp: %.png  ; $(2bpp) $<
%.1bpp: %.png  ; $(1bpp) $<
%.pic:  %.2bpp ; $(pic)  $<
