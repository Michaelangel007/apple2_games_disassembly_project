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
