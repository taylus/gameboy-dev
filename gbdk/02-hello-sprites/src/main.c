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

void input()
{
    const int movement_speed = 6;

    int buttons = joypad();

    if (buttons & J_LEFT)
    {
        scroll_sprite(0, -movement_speed, 0);
    }
    else if (buttons & J_RIGHT)
    {
        scroll_sprite(0, movement_speed, 0);
    }

    if (buttons & J_UP)
    {
        scroll_sprite(0, 0, -movement_speed);
    }
    else if (buttons & J_DOWN)
    {
        scroll_sprite(0, 0, movement_speed);
    }
}

void main()
{
    int curr_sprite_tile = 0;
    
    init();
    
    while(1)
    {
        input();
        
        curr_sprite_tile ^= 1;
        set_sprite_tile(0, curr_sprite_tile);
        
        delay(500);
    }
}