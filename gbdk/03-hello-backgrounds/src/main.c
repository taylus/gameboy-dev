#include <gb/gb.h>
#include "pkmn_tiles.h"
#include "pkmn_map.h"

void vblank()
{
    scroll_bkg(1, 0);
}

void main()
{
    set_bkg_data(0, 8, tile_data);
    set_bkg_tiles(0, 0, 40, 20, map_data);
    scroll_bkg(0, 16);
    SHOW_BKG;

    add_VBL(vblank);
}