# Conan: Halls of Volta

It was one of the first Apple 2 games to use a 1-bit [stencil buffer](https://en.wikipedia.org/wiki/Stencil_buffer) for foreground/background objects.

* ![1-bit Stencil Buffer](pics/conan_hgr_and_stencil.png)

I uploaded [this](https://i.imgur.com/5ZtUmBh.png) to imgur years ago.

# Death Screen

There are 9 levels in Conan:

* Level 0 is the outside castle,
* Levels 1 - 7 are playable, and
* Level 8 is the end won screen.

Each of the 7 playable levels have 4 unique death messages (!) for a whopping 28 unique death messages & beautiful artwork:

* ![Conan Level 1a](pics/conan_death_10.png)
* ![Conan Level 1b](pics/conan_death_11.png)
* ![Conan Level 1c](pics/conan_death_12.png)
* ![Conan Level 1d](pics/conan_death_13.png)

* ![Conan Level 2a](pics/conan_death_20.png)
* ![Conan Level 2b](pics/conan_death_21.png)
* ![Conan Level 2c](pics/conan_death_22.png)
* ![Conan Level 2d](pics/conan_death_23.png)

* ![Conan Level 3a](pics/conan_death_30.png)
* ![Conan Level 3b](pics/conan_death_31.png)
* ![Conan Level 3c](pics/conan_death_32.png)
* ![Conan Level 3d](pics/conan_death_33.png)

* ![Conan Level 4a](pics/conan_death_40.png)
* ![Conan Level 4b](pics/conan_death_41.png)
* ![Conan Level 4c](pics/conan_death_42.png)
* ![Conan Level 4d](pics/conan_death_43.png)

* ![Conan Level 5a](pics/conan_death_50.png)
* ![Conan Level 5b](pics/conan_death_51.png)
* ![Conan Level 5c](pics/conan_death_52.png)
* ![Conan Level 5d](pics/conan_death_53.png)

* ![Conan Level 6a](pics/conan_death_60.png)
* ![Conan Level 6b](pics/conan_death_61.png)
* ![Conan Level 6c](pics/conan_death_62.png)
* ![Conan Level 6d](pics/conan_death_63.png)

* ![Conan Level 7a](pics/conan_death_70.png)
* ![Conan Level 7b](pics/conan_death_71.png)
* ![Conan Level 7c](pics/conan_death_72.png)
* ![Conan Level 7d](pics/conan_death_73.png)

The [Conand - Guide and Walkthrough](https://gamefaqs.gamespot.com/appleii/577826-conan/faqs/7804) has an incomplete and incorrect list.

Here are all the correct descriptions:

* 1a  Back to Cimmeria barbarian!!
* 1b  Bats in your belfry (moon)
* 1c  Your Struggles are in Vain
* 1d  Your odyssey has ended before it had begun (torch)
* 2a  A watery barrier (river)
* 2b  Quest terminated
* 2c  There is no glory for you here (flower)
* 2d  You withdraw battered and torn (tree)
* 3a  Death at thy feet, life from above... (ants)
* 3b  You beat a heated retreat... (lava)
* 3c  Only a cleric can help you now (cleric)
* 3d  You Succumb to Lassitude (cavern outline)
* 4a  Thus, the story ended...
* 4b  Conan's Bane! (mushroom mob on ledge)
* 4c  The End (crossed swords)
* 4d  You sink slowly into a peaceful bliss (vase)
* 5a  You shuffle off defeated for now (quarter moon)
* 5b  To be continued... (tombstone)
* 5c  Adveture's End... (candle) [NOTE: misspelt "Adventure"]
* 5d  The glow from the pyre lights the room (bonfire)
* 6a  The eyes have it (3 eyes)
* 6b  Thy fate is sealed (scroll)
* 6c  A Shocking End (lightning)
* 6d  Crom awaits (sword & goblet)
* 7a  Volta's minions take you to the Loph-ka slave pits (horse)
* 7b  Volta is victorious
* 7c  You retire more dead than alive (island)
* 7d  The Crimson Orb recedes on your horizon (sun)

Animated death icons:

* ![Conan Death Icons](pics/conan_death_icons_animated.gif)

# RNG

When you first enter a level `ResetLevel` at $1A22 is called to initialize your score, axes, lives.

* ![Debugger ResetLevel](pics/debugger_resetlevel.png)

When you have no lives left ($34B) and die a death timer is started ($34F).  When it reaches #$18 the ShowDeathMessage at $1C7C is called.

It calls `random()` which lives at $1EA8.  It then does `A mod 4` to determine which of the 4 death screens it should show for that level.

* ![Debugger ShowDeathMsg](pics/debugger_showdeathmessage.png)

By manually setting the accumulator to 0 .. 3 we can manually control which death message is shown.

We can also streamline this by setting a breakpoint on `ResetLevel` and then manually setting:

* lives to zero, `34B:0`
* death timer to one, `34F:0`

our player will die once the level loads. :-)

See the included AppleWin debugger script: [conan_death_screens.sym](conan_death_screens.sym).

The death screen uses this RNG algorithm:

```asm
random        ; 1EA8
    ROL $4E
    ROL $037A
    ROL $0371
    LDA $4E
    ASL
    EOR $0371
    ROL
    ROL
    ROL
    ROL
    ROL
    PHA
    ROL $4F
    EOR $037A
    STA $4E
    PLA
    STA $0371
    ADC $4E
    ADC $037A
    STA $0372
    RTS
```


# Easter Eggs

* **Introduction** -- Wait for the music to stop playing to see the knight riding

* **Level 1** -- If you DON'T kil lthe bat and jump off the top of the building and there is a secret ladder in the tree that gives an extra life

* **Level 3** -- Jump and hit the bird with your head for an extra life

* **Level 7** -- There is a secret super jump move in the bottom right by holding down `Q` to jump up to the heighest floor.

* **End Screen** -- Secret initials of EP.

  * ![End screen](pics/conan_win.png)

* **Text Screen** -- Pressing `Ctrl`-`Reset` will show the Datasoft logo on the text screen. **Note:** Missing in qkumba's ProDOS port. :-/

  * ![Logo](pics/conan_easter_egg_text_screen.png)

# ProDOS

qkumba did a [1-sided file conversion.](http://pferrie.epizy.com/misc/lowlevel16.htm?i=1)

He closed with this cheeky statement:

> With that problem solved, we can compress the data to the point that it fits on a single side of a floppy disk. Imagine what other levels the authors could have included with a whole other side of the disk...
