# Nosh Kosh

![pics/title.png](pics/title.png)


# TASC

_Nosh Kosh_ was originally written in Applesoft (!)
and compiled with Microsoft's [TASC](https://devblogs.microsoft.com/oldnewthing/20220419-00/?p=106496) (The AppleSoft Compiler) version 2.01 (!!).

We know this due to three reasons:

1. There is a `RUNTIME` file on disk which is loaded by `HELLO` via ` 100  PRINT  CHR$ (4)"BLOAD RUNTIME,A$4000"`.  The TASC runtime resides from $4000 .. $4FAC.
2. There is a Microsoft copyright signature at $4F93:4FAC (memory) in the file `RUNTIME` (disk).
3. There are multiple versions of TASC. Comparing the `RUNTIME` file on TASC 2.0 and [2.01](disk/TASC 2.01 \(Microsoft 1981\).dsk) we find the 2.01 is 100% byte identical to the one on _Nosh Kosh_ !

In AppleWin you can view memory and see the Microsoft copyright signature:

```
ASC 4F93:4FAC
MA1 4F93 // MS TASC copyright signature
```
Versions of TASC:

| Disk name                       | Version | RUNTIME file size |
|:--------------------------------|:--------|------------------:|
| `TASC COMPILER.dsk`             | ?.?     | 3,969 |
| `tasc-compiler.dsk`             | 2.0     | 4,013 |
| `TASC 2.0 (Microsoft 1981).dsk` | 2.0     | 4,013 |
| `TASC 2.01 (Microsoft 1981).dsk`| 2.01    | 4,013 |

# N-R2.OBJ

The Applesoft BASIC `HELLO` loads a few pictures, loads TASC RUNTIME, and the compiled program:

```BASIC
 5 X =  FRE (0)
 10  HGR
 12  HOME : FOR D = 1 TO 20
 13  PRINT "NOSH KOSH "
 14  NEXT D
 15  POKE  - 16302,0
 30  PRINT  CHR$ (4)"BLOAD PIC.T1,A$2000"
 35  FOR D = 1 TO 1000: NEXT
 40  PRINT  CHR$ (4)"BLOAD CREDIT,A$4000"
 50  POKE  - 16299,0
 55  FOR D = 1 TO 1700: NEXT
 60  PRINT  CHR$ (4)"BLOAD PIC.T5,A$2000"
 65  FOR D = 1 TO 1700: NEXT
 70  POKE  - 16300,0
 100  PRINT  CHR$ (4)"BLOAD RUNTIME,A$4000"
 200  PRINT  CHR$ (4)"BRUNN-R2.OBJ"
```

The file `N-R2.OBJ` resides at $4FAD and calls the RUNTIME.INIT ($4000) first thing.
```
4FAD: JSR $4000
```

See the last file name loaded by DOS 3.3:
```
MA2 AA75 // DOS last filename
```

# Levels

![pics/level1.png](pics/level1.png)

There are 5 levels.

Each level is 20x10 tiles (200 bytes).

The disk includes the original Applesoft BASIC program to create them.

```BASIC
"BSAVE SCRN1,A36256,L200"
```

* `SCREAN1` generates level `SCRN1`
* `SCREAN2` generates level `SCRN2`
* `SCREAN3` generates level `SCRN3`
* `SCREAN4` generates level `SCRN4`
* `SCREAN5` generates level `SCRN5`

# UI

The UI is mirrored on the text screen!

# AppleWin Debugger Reverse Engineering

1. `F7`
2. `cd ..`
3. `run noshkosh.txt`

See [noshkosh.txt](noshkosh.txt)
