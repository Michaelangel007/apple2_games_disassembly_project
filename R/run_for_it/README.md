# Run-for-It

# Intro

Back in the 80's I played a **bad** game called [Run-for-It](https://www.mobygames.com/game/run-for-it). 

* ![Title Screen](pics/demo_level.png)


# Why?

If it was so bad why write all this up? I was curious about:

* How many rooms there were?
* What are all the font glyphs?
* What is the main game loop?
* What is the tile set it used?

Back in Dec. 2021 / Jan. 2022 I spent a few days reverse engineering it.


# Reverse Engineering

The goal is to turn this raw machine code ...

* ![main machine](pics/main_loop_pre_disassembly.png)

... into this nice assembly language disassembly:

* ![main assembly](pics/main_loop_post_disassembly.png)

Look at the AppleWin [Run for It debugger script](run_for_it.txt) for details.


# Map

After 40 years I can finally answer the question:

* There are 6*12 = 72 rooms

Here is the 1:1 world map for the 6 zones:

* ![Zone ABC](pics/world_with_mobs/run_for_it_zone0_abc_with_mobs.png)
* ![Zone DEF](pics/world_with_mobs/run_for_it_zone1_def_with_mobs.png)
* ![Zone GHI](pics/world_with_mobs/run_for_it_zone2_ghi_with_mobs.png)
* ![Zone JKL](pics/world_with_mobs/run_for_it_zone3_jkl_with_mobs.png)
* ![Zone MNO](pics/world_with_mobs/run_for_it_zone4_mno_with_mobs.png)
* ![Zone PQR](pics/world_with_mobs/run_for_it_zone5_pqr_with_mobs.png)

The world is broken up into Zones and Rooms;

* There are 6 zones.
* Each zone has 12 rooms in a 4x3 layout.

The first zone has rooms A1, A2, A3, A4, B1, B2, B3, B4, C1, C2, C3, and C4.


# Tile Set

Here zone has their own respective tile set.  I only dumped the tiles for the first zone, glyphs 00..7F:

* ![Tileset 00-3F](pics/tiles0_00_3F.png)
* ![Tileset 40-7F](pics/tiles0_40_7F.png)

See the assembly source [view_tiles.s](view_tiles.s).


# Font

I was curious about the font so I dumped it:

* ![font](pics/run_for_it_font.png)

See the assembly source [view_font.s](view_font.s)


# Cheats

As long as you have energy you can't die.

* Unlimited energy:

```
// Invulnerability
// v3
//     1261:90 // Original: BCC $128C
       1261:80 // Cheat   : BRA $128C ; Never collide with enemies
```

* Infinite time:

There is also a running clock that we can stop:

```
// Infinite Time
//     08E9:C6 B0  // Original: DEC $B0
       08E9:A5 B0  // Cheat:    LDA $B0 ; Infinite Time

       00AE:50     // Reset time back to full 5 bars
       00B0:50     // 
```

See the assembly file [run_for_it_cheats.txt](run_for_it_cheats.txt)

Last updated: Mon, Oct. 31, 2022.
