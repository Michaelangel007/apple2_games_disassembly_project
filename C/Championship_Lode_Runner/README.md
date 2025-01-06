# Championship Lode Runner

Some notes about the excellent _Championship Lode Runner_ puzzle/platformer game.

# Cheat Keys

There are 10 cheat keys in the C64 version, 12 cheat keys in the Apple 2 version.

## C64 Cheat Keys

David Youd has a [fantastic analysis](https://www.youtube.com/watch?v=GpiABMu9dTk) of the cheat keys in the C64 version.

The C64 version has the following cheat:

   RUN/STOP, F7, RUN/STOP

```asm
IGC_Pause                  .block                           ; 
GetNextPauseKey             jsr GetNewKey                   ; 
                            cmp #$03                        ; test F7
                            bne CheckChar_RunStop           ; check: EQ - no
                            sta CL_CheatMode                ; set flag cheat mode on after <RUN/STOP> and F7
CheckChar_RunStop           cmp #$3f                        ; test <RUN/STOP>
                            bne GetNextPauseKey             ; check: EQ - no
                            jmp GameInputHandler            ; 
                           .bend                            ;
```

## Apple 2 Cheat Keys Analysis

The Apple 2 pause code doesn't have any code to set the cheat flag:

```asm
75A3: IGC_Pause  JSR WaitKey          ; v $8AC7
75B1:            CMP #$9B             ; ESC
75B3:            BNE IGC_Pause        ; ^ $75A3
75B5:            JMP GameInputHandler ; ^ $7569
```

# AppleWin Debugger Reverse Engineering

The in-game cheat commands are found at $76A9 .. $76B5.

The in-game cheat dispatch is at $76AB6 ... $76CD.

```
// Key                    ^[ ^R ^A ^S ^J ^K ^H ^U ^X ^Y ^M ^B
// Index                 [ 0  1  2  3  4  5  6  7  8  9  A  B  C]
DB CmdChar   76A9:76B5 // 9B 92 81 93 8A 8B 88 95 98 99 8D 82 00
DA CmdAddr   76B6:76CD

// To view cheat commands
//   400<76A9.76B5M
//   TEXT
sym IGC_Pause       = 75AE // $75AD [0] 9B  ESC IGC_Pause
sym IGC_Resign      = 75B8 // $75B7 [1] 92  ^R  IGC_Resign
sym IGC_Suicide     = 75BC // $75BB [2] 81  ^A  IGC_Suicide  (Abort)
sym IGC_Sound       = 75BF // $75BE [3] 93  ^S  IGC_Sound
sym IGC_SetJoystick = 75C8 // $75C8 [4] 8A  ^J  IGC_SetJoystick
sym IGC_SetKeyboard = 75CF // $75CF [5] 8B  ^K  IGC_SetKeyboard
sym IGC_IncSpeed    = 75FF // $75FE [6] 88  <-  IGC_IncSpeed
sym IGC_DecSpeed    = 75F4 // $75F3 [7] 95  ->  IGC_DecSpeed
sym IGC_SwapJoyX    = 75D6 // $75D5 [8] 98  ^X  n/a    // swaps joystick left-right $76CE $76CF:0C 30
sym IGC_SwapJoyY    = 75E5 // $75E4 [9] 99  ^Y  n/a    // swaps joystick up-down    $76D0 $76D1:0C 30
sym IGC_HighScores  = 8302 // $8301 [A] 8D  ^M  n/a    // View High Scores / Leaderboard
sym IGC_CtrlB       = 76D2 // $76D1 [B] 82  ^B  ???    // Toggles ZPG $D5, init $00
```
