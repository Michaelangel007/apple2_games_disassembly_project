# Lode Runner

To debug the iris VFX  screen effect.

```
BPC *
BPM 62B0
BPM 62B3
G
```

Lode Runner

* clears both HGR pages
* draws the level on HGR page 2
* draws the scoreboard footer on HGR page 1
* iris VFX copies bits from page 2 to page 1

# Sprites

Sprites are located at $AD00. With dimenions 10x11.

The format is [104][22] because there are 2 bytes per scanline.

![Tiles](viewtiles_2x.png)

# Sprite Viewer

See [viewtiles.s](viewtiles.s).
