#include <gb/gb.h>
#include <stdio.h>
#include "smiley.h"

void init()
{
    //load sprite data into tiles 0 and 1
    set_sprite_data(0, 2, smiley_sprite);

    //set sprite 0 to use data from tile 0
    set_sprite_tile(0, 0);

    move_sprite(0, 88, 78);
    SHOW_SPRITES;
}

void main()
{
    int curr_sprite_tile = 0;
    init();
    while(1)
    {
        curr_sprite_tile ^= 1;
        set_sprite_tile(0, curr_sprite_tile);
        delay(500);
    }
}