; Dino Eggs Boot Sector
; Reverse Engineered by Michaelangel007

zPromDst    EQU $26     ; PROM, 16-bit data pointer to next load address
zPromSlot   EQU $2B     ; PROM, slot * 16 = $60
zPromSector EQU $3D     ; PROM, next sector to read
zPromRead   EQU $3E     ; PROM, 16-bit func pointer to read sector
PROM_Read   EQU $C05C   ; Slot 0, usually slot 6 = $C65C

CTRL_RESET  EQU $3F2    ; 16-bit func pointer
CTRL_CRC    EQU $3F4    ; <CTRL_RESET XOR $A5

; Old Reset does
;   JSR SETNORM
;   JSR INIT
;   JSR SETVID
;   JSR SETKBD
ROM_INIT    EQU $FB2F
ROM_SETKBD  EQU $FE89
ROM_SETVID  EQU $FE93
ROM_RESET   EQU $FA62

COUT        EQU $FDED
HOME        EQU $FC58
PRBYTE      EQU $FDDA

        ORG $0800

        DB #1               ; Tell PROM load 1 sector
Boot
        LDA zPromDst+1
        CMP #$09            ; First time? addr == $0900
        BNE NotFirstSec
        LDA zPromSlot       ; $60, Slot of disk drive * 16
        LSR
        LSR
        LSR
        LSR
        ORA #>PROM_Read     ; $C6, high byte, $C65C
        STA zPromRead+1
        LDA #<PROM_Read     ; $5C, low byte, $C65C
        STA zPromRead

        CLC
        LDA BootDst+1
        ADC BootNumSec
        STA BootDst+1

NotFirstSec
        LDX BootNumSec
        BMI LoadDone

        LDA Log2PhySector,X
        STA zPromSector
        DEC BootNumSec

        LDA BootDst+1
        STA zPromDst+1
        DEC BootDst+1

        LDX zPromSlot
        JMP: (zPromRead)    ; Call absolute PROM addr to read next sector

LoadDone
; Original boot sector wasted memory doing pointless work
        INC BootDst+1   ; Wasted mem, $AF -> $B0
        INC BootDst+1   ; Wasted mem, $B0 -> $B1

        JSR ROM_SETKBD
        JSR ROM_SETVID
        JSR ROM_INIT    ; For some reason, called after instead of before

        LDX zPromSlot   ; Wasted mem, never used
        JMP (BootDst)   ; This is always $B100, and BootDst is never used again

; Map Logical Sector to Physical Sector
Log2PhySector   ; Sec Address
        DB $0   ; [0] $B000
        DB $D   ; [1] $B100
        DB $B   ; [2] $B200
        DB $9   ; [3] $B300
        DB $7   ; [4] $B400
        DB $5   ; [5] $B500
        DB $3   ; [6] $B600
        DB $1   ; [7] $B700
        DB $E   ; [8] $B800
        DB $C   ; [9] $B900
        DB $A   ; [A] $BA00
        DB $8   ; [B] $BB00
        DB $6   ; [C] $BC00
        DB $4   ; [D] $BD00
        DB $2   ; [E] $BE00
        DB $F   ; [F] $BF00

Temp08FD = *
Padd08FD = $08FD - Temp08FD
        DS Padd08FD, 0

; 08FD
BootDst DW $B000         ; Load to $B000

; Note: Loading all 16 sectors is stupid since we read $B000..$B7FF **again**
; from the FTOC at Track $15, Sector $F which loads:
;    T1ASD $B000
;    T1ASC $B100
;    T1ASB $B200
;    T1ASA $B300
;    T1AS9 $B400
;    T1AS8 $B500
;    T1AS7 $B600
;    T1AS6 $B700
; Via $BC6A
;    LDA #$15 ; Track  of FTOC "Dino.Eggs.T15"
;    LDX #$0F ; Sector of FTOC "Dino.Eggs.T15"
;    LDY #$60 ; Address = $6000
BootNumSec  DB $0F      ; Load 16 sectors [0..F] inclusive
