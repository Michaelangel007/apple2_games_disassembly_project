; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;            Dino Eggs RWTS            
; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Reverse Engineered by Michaelangel007
; Copyleft {c} 2023
; https://github.com/Michaelangel007/dino_eggs_keyboard_patch

zPromDst            EQU   $26 ; PROM, 16-bit data pointer to next load address
zPromSlot           EQU   $2B ; PROM, slot * 16 = $60
zPromSector         EQU   $3D ; PROM, next sector to read
zPromRead           EQU   $3E ; PROM, 16-bit func pointer to read sector
zPromVolume         EQU   $41

PROM_Read           EQU $C05C ; Slot 0, usually slot 6 = $C65C

; --- Game Data --
; A800: [0] Menu
; A801: [1] ???
; A802: [2] ???
; A803: [3,4] Score
; A804: [5,6] High Score
; A807: [7] ???
; A808: [8] ???
; A809: [9] ???
; A80A: [A] Level
Men                 EQU  $A800
;                   EQU  $A801
;                   EQU  $A802
Score32             EQU  $A803  ; BCD 32
Score10             EQU  $A804  ; BCD   10
HighScore32         EQU  $A805  ; BCD 32
HighScore10         EQU  $A806  ; BCD   10
;                   EQU  $A808
;                   EQU  $A809
Level               EQU  $A80A
;
Main                EQU  $A892

HIGH_SCORE_TRACK  = 8
HIGH_SCORE_SECTOR = 8

; --- RWTS Zero Page ---
zRwtsTemp           EQU    $26  ; @WRITE16 ; NibBuff1[0] -> Zero Page for cycle counting
zRwtsSlot           EQU    $27  ; Slot#1
zSeekSlot           EQU    $2B  ; Slot#2 @ SEEK

zDriveNo            EQU    $35  ; 
zDosDCT             EQU    $3C  ; 16-bit pointer to DCT -> $B7FB, DOS 3.3 DEVCTBL = $3C
zBufferPtr          EQU    $3E  ; 16-bit pointer to buffer -> $0200; @PreNibble
WRITE_NIB_AA        EQU    $3E  ; @DiskFormat (Reused!)
zNumSector          EQU    $3F  ; @SECTOK

zWriteTrack         EQU    $44  ; @DiskFormat ; How many bloody track variables do we need?!
zWriteNumSync       EQU    $45  ; @DiskFormat ; 

;  Slot     0     1     2     3     4     5     6     7
; Hole0  $478  $479  $47A  $47B  $47C  $47D  $47E  $47F
; Hole1  $4F8  $4F9  $4FA  $4FB  $4FC  $4FD  $4FE  $4FF
; Hole2  $578  $579  $57A  $57B  $57C  $57D  $57E  $57F
; Hole3  $5F8  $5F9  $5FA  $5FB  $5FC  $5FD  $5FE  $5FF
; Hole4  $678  $679  $67A  $67B  $67C  $67D  $67E  $67F
; Hole5  $6F8  $6F9  $6FA  $6FB  $6FC  $6FD  $6FE  $6FF
; Hole6  $778  $779  $77A  $77B  $77C  $77D  $77E  $77F
; Hole7  $7F8  $7F9  $7FA  $7FB  $7FC  $7FD  $7FE  $7FF
aWriteSlot          EQU  $0475  ; Slot#3; Visible on screen! VTAB 17:HTAB 38: DOS 3.3 = $678, Text Page Screen Hole4Slot0
aRecalibCount       EQU  $0476  ; DOS 3.3 = $6F8 RECALCCNT, Text Page Screen Hole5Slot0
aRetryCount         EQU  $0578  ; DOS 3.3 = $578 RETRYCNT , Text Page Screen Hole2Slot0
aReadSlot           EQU  $05F8  ; Slot#4 DOS 3.3 = $5F8 "SLOT"; How many bloody slot variables do we need?!

zMetaCount          EQU    $26  ; Reuses zMetaCount zRwtsTemp zSeekDeltaTrack
zMetaPrev44         EQU    $26  ; Resues zMetaCount zRwtsTemp zSeekDeltaTrack
zChecksum           EQU    $27  ; Reuses zSeekPrevTrk @ReadAddress
zMetaChecksum       EQU    $2C  ; [0] @ReadAddres
zMetaSector         EQU    $2D  ; [1] @ReadAddres
zMetaTrack          EQU    $2E  ; [2] @ReadAddres
zMetaVolume         EQU    $2F  ; [3] @ReadAddres

zSeekDeltaTrack     EQU    $26  ; zMetaCount zRwtsTemp zSeekDeltaTrack
zSeekTrack          EQU    $2A  ; @SEEK
zSeekPrevTrk        EQU    $27  ; @SEEK
zDosIOB             EQU    $48  ; 16-bit data pointer to DOS Input/Output Buffer
aTrack              EQU  $0478  ; Current Track DOS 3.3 CURTRK
Drive1Track         EQU  $0478  ; Re-used! DOS 3.3 DRV2TRK,Y  y=06 -> $47E
Drive2Track         EQU  $04F8  ; Re-used! DOS 3.3 DRV2TRK,Y  y=06 -> $4FE
aSeekCount          EQU  $04F8  ; DOS 3.3 SEEKCNT  = $4F8, Text Page Screen Hole1Slot0

; --- RWTS Buffers ---
FtocBuffer          EQU  $0200  ; @LoadFile
NibBuf1             EQU  $0600  ; DOS 3.3 NBUF1    = $BB00
NibBuf2             EQU  $0700  ; DOS 3.3 NBUF2    = $BC00
OrgBuf1             EQU  $BB00  ; @DiskFormat -- this is never called
OrgBuf2             EQU  $BC00  ; @DiskFormat -- this is never called

; --- RWTS Format unused target labels ---
OrgFormatError      EQU  $BF04  ; Original FORMERR  was here; replaced with WipeMem Ctrl-Reset code
OrgWriteTrack16     EQU  $BF0D  ; Original WTRACK16 was here; replaced with WipeMem Ctrl-Reset code
OrgNotSector15      EQU  $BF81  ; Original VTRACK   was here; replaced with NibbleCount
OrgFound            EQU  $BFA8  ; Original FOUND    was here; replaced with INTERLEAVE due to NibbleCount

NIBBLES_PER_SECTOR      = $156  ; @PreNibble, @DiskFormat; 6&2 = 342 disk nibbbles (not including checksum)
RWTS_MIN_NIBBLES_DELTA  =   $8  ; @RWTS
RWTS_SYNC_NIBBLES       =  $28  ; @DiskFormat (Unused)
RWTS_RETRY_SECTORS      =   48  ; @DiskFormat number of sectors to retry
RWTS_RECALIB_MIN_TRACK  =    0  ; @Recalibrate
RWTS_RECALIB_MAX_TRACK  =   96  ; @Recalibrate
RWTS_RECALIB_SEEK_TRY   =    4  ; @Recalibrate
RWTS_LAST_TRACK         =   35  ; @DiskFormat
RWTS_MIN_SYNC_NIBBLES   =    5  ; @VTRACK
RWTS_FLAG_NO_SECTOR     =  $FF  ; @SECTOK;  -1 flag 
RWTS_NUM_SYNC_NIBBLES   =   16  ;

RWTS_FIRST_VALID_NIBBLE =  $96
MAX_DISK_NIBBLE         =  $3F  ; 64 valid disk nibbles for 6&2 Encoding

; --- Nibble Check ---
NIBBLE_CHECK_SECTOR     =  $0F
NIBBLE_CHECK_LOCK_5     =  $CF
NIBBLE_CHECK_LOCK_6     =  $9E
;
NIBBLE_CHECK_OPT_1      =  $9E
NIBBLE_CHECK_OPT_2      =  $E7
NIBBLE_CHECK_OPT_3      =  $F9

NIBBLE_CHECK_PRE        =  $FF
NIBBLE_CHECK_POST       =  $FF
NIBBLE_COUNT_POST       =   16  ; Read 16 SyncFF
NIBBLE_CHECK_EPI_1      =  $D5  ; This is partial Addr Fields D5 AA 96
NIBBLE_CHECK_EPI_2      =  $AA  ; This is partial Addr Fields D5 AA 96
NIBBLE_COUNT_SLACK      =    5  ; Nibble Count within 5 bytes of max?
zNibCount           EQU    $26  ; Resuses zRwtsTemp; PostNib16


; --- Error Msg ---
; Technically these are never used but exist in residual DOS 3.3 code
ERR_FORMAT              =   $8
ERR_VOL_MISMATCH        =  $20  ; IBVMME = Volume Mismatch Error
ERR_WRITE_PROT          =  $10  ; IBWPER = Write Protected Error

; --- DCT @ <- ($3C) ---
; DCT_MOTOR_TIME is copied from $B7FB to $46 @ PTRMOV+$A (@BD5E)
DCT_MOTOR_TIME          =  $46  ; B7FD: DCT [2] DOS3.3 $B7FD; 16-bit word

DCT_OFFSET_TYPE         =   $0  ; B7FB: [0]    $0 = Disk II; never used
DCT_OFFSET_PHASE        =   $1  ; B7FC: [1]    $1 = Two Phases/Track, @MYSEEK2, @DriveSelect
DCT_OFFSET_MOTOR        =   $2  ; B7FD: [2] $D8EF = Delay in 100 microseconds to turn motor on

; --- IOB @ BA7A <- ($48) ---
; Input Output Control Block (struct)
; zDosIOB points to IOB
; See ORG_TYPE
IOB_OFFSET_TYPE         =  $0 ; BA7A: [0] 
IOB_OFFSET_SLOT         =  $1 ; BA7B: [1]
IOB_OFFSET_DRIVE        =  $2 ; BA7C: [2]
IOB_OFFSET_VOLUME       =  $3 ; BA7D: [3]
IOB_OFFSET_TRACK        =  $4 ; BA7E: [4]
IOB_OFFSET_SECTOR       =  $5 ; BA7F: [5]
IOB_OFFSET_DCT          =  $6 ; BA80: [6] 16-bit pointer to Device Characteristic Table = $B7FB
IOB_OFFSET_BUFFER       =  $8 ; BA82: [7] 16-bit pointer to destination $0200
IOB_OFFSET_LEN          =  $A ; BA84: [8] 16-bit Little Endian Length
IOB_OFFSET_COMMAND      =  $C ; BA86: [9] 0=nop, 1=Read, 2=Write, 4=Format
IOB_OFFSET_ERROR        =  $D ; BA87: [A] Wasted memory: Could set high bit of IOB_COMMAND
IOB_OFFSET_MOD          =  $E ; BA88: [B] Temp volume
IOB_OFFSET_PREV_SLOT    =  $F ; BA89: [C] Wasted memory for Dino Eggs, slot and drive are constant
IOB_OFFSET_PREV_DRIVE   = $10 ; BA8A: [D] Wasted memory for Dino Eggs, slot and drive are constant

; DOS 3.3A  IOB at $B7E8..$B7FA
; Dino Eggs IOB at $BA7A..$BA7
ORG_TYPE        EQU $B7E8

; --- RWTS Comamnd ---
RWTS_CMD_NOP            = $0
RWTS_CMD_READ           = $1 ; Read Sector
RWTS_CMD_WRITE          = $2 ; Write Sector
RWTS_CMD_FORMAT         = $4 ; Write Tracks
; Raw Disk Nibbles
; DOS3.3   <D5> <AA> <96> <Vol> <Vol> <Trk> <Trk> <Sec> <Sec> <Crc> <Crc> <DE> <AA>
; DinoEggs <D5> <AA> <96> <Vol> <Vol> <Trk> <Trk> <Sec> <Sec> <Crc> <Crc> <9E> <E7>
ADDR_PROLOG1 = $D5
ADDR_PROLOG2 = $AA
ADDR_PROLOG3 = $96
ADDR_EPILOG1 = $9E ; Custom Epilog!  DOS 3.3 hard-coded $DE
ADDR_EPILOG2 = $E7 ; Custom Epilog!  DOS 3.3 hard-coded $AA
ADDR_META_44 =   4 ; Number of 4&4 disk nibbles of meta-data

; <D5> <AA> <AD> ... <Crc> <D5> <AA> <EB> <FF>
DATA_PROLOG1 = $D5
DATA_PROLOG2 = $AA
DATA_PROLOG3 = $AD
;
DATA_EPILOG1 = $D5  ; DOS 3.3 $DE
DATA_EPILOG2 = $AA
DATA_EPILOG3 = $EB
DATA_EPILOG4 = $FF

; --- Disk I/O ---
DRIVE_PHASE_OFF EQU $C080
DRIVE_MOTOR_OFF EQU $C088
DRIVE_MOTOR_ON  EQU $C089
DRIVE_SELECT1   EQU $C08A
DRIVE_SELECT2   EQU $C08B


; Original shitty Disk Controller I/O Names
; WTF is the _functionality_ ???
;
;   Q7 Q6
;   0  0   Read Mode
;   0  1   Write-Protect Sense
;   1  0   Write Mode
;   1  1
Q6L         EQU $C08C
Q6H         EQU $C08D
Q7L         EQU $C08E
Q7H         EQU $C08F

; --- ROM variables ---
CTRL_RESET        EQU  $3F2 ; 16-bit func pointer
CTRL_CRC          EQU  $3F4 ; <CTRL_RESET XOR $A5

; The boot sector loads the entire Track $0
;    Sec Addr
;    [0] $B000
;    [1] $B100
;    [2] $B200
;    [3] $B300
;    [4] $B400
;    [5] $B500
;    [6] $B600
;    [7] $B700
;    [8] $B800
;    [9] $B900
;    [A] $BA00
;    [B] $BB00
;    [C] $BC00
;    [D] $BD00
;    [E] $BE00
;    [F] $BF00
; It will then RE-LOAD $B000..$B7FF @ BC61, Track $15, Sector $F into $6000 .. $B7FF !
; === RWTS hogs $B800..$BFFF ===
            ORG $B800

; $B800 PRENIB16 PreNibble
PreNibble       LDX #$0
                LDY #2
_PreNib1        DEY
                LDA (zBufferPtr),Y
                LSR
                ROL NibBuf2,X
                LSR A
                ROL NibBuf2,X
                STA NibBuf1,Y
                INX
                CPX #<NIBBLES_PER_SECTOR
                BCC _PreNib1
                LDX #0
                TYA
                BNE _PreNib1
                LDX #<NIBBLES_PER_SECTOR-1
_PreNib2        LDA NibBuf2,X
                AND #MAX_DISK_NIBBLE
                STA NibBuf2,X
                DEX
                BPL _PreNib2
                RTS

; $B82A WRITE16
;    WRITE16 Write pre-nibbled sector data; this normally comes after WADR16
; On Entry:
;     X = Slot*16, i.e. $60
; Uses:
;    Encode6n2
;    NibBuf1
;    NibBuf2
;    zRwtsTemp
WRITE16         SEC
                STX zRwtsSlot           ; Read = 3 cycles
                STX aWriteSlot          ; Read = 4 Cycles
                LDA Q6H,X      
                LDA Q7L,X               ; Write Protect?
                BMI WEXIT
                LDA NibBuf2
                STA zRwtsTemp           ; Crappy DOS 3.3 name "WTEMP" 
                LDA #$FF                ; $FF sync, it takes 40 µseconds to write sync nibble (compared to 32 µseconds for normal nibble)
                STA Q7H,X               ;+5 =   5
                ORA Q6L,X               ;+4 =   9
                PHA                     ;+3 =  12
                PLA                     ;+4 =  16
                NOP                     ;+2 =  18
                LDY #4                  ;+2 =  20
WSYNC           PHA                     ;+3 =  23
                PLA                     ;+4 =  27
                JSR WNIBL7              ;+6 =  33 JSR += 6; WNIBL7 += 13 -> 15; Original DOS 3.3 has comment: (13,9,6)
                DEY                     ;+2 =  17
                BNE WSYNC               ;+2*=  20 BNE = 3, BEQ = 2
                LDA #DATA_PROLOG1       ;(2)
                JSR WNIBL9              ;(15,9,6)
                LDA #DATA_PROLOG2       ;(2)
                JSR WNIBL9              ;(15,9,6)
                LDA #DATA_PROLOG3       ;(2)
                JSR WNIBL9              ;(15,9,6)
                TYA                     ;(2)
                LDY #<NIBBLES_PER_SECTOR ;(2)
                BNE WDATA1              ;(3)
WDATA0          LDA NibBuf2,Y           ;(4)
WDATA1          EOR NibBuf2-1,Y         ;(5)
                TAX                     ;(2)
                LDA Encode6n2,X         ;(4)
                LDX zRwtsSlot           ;(3)
                STA Q6H,X               ;(5)
                LDA Q6L,X               ;(4)
                DEY                     ;(2)
                BNE WDATA0              ;(2*)
                LDA zRwtsTemp           ;(3)
                NOP                     ;(2)
WDATA2          EOR NibBuf1,Y           ;(5)
                TAX                     ;(2)
                LDA Encode6n2,X         ;(4)
                LDX aWriteSlot          ;(4) ; 4 cycle
                STA Q6H,X               ;(5)
                LDA Q6L,X               ;(4)
                LDA NibBuf1,Y           ;(4)
                INY                     ;(2)
                BNE WDATA2              ;(2*)
                TAX                     ;(2)
                LDA Encode6n2 ,X        ;(4) 
                LDX zRwtsSlot           ;(3) ; 3 cycle
                JSR WNIBL               ;(6,9,6) Checksum
                LDA #DATA_EPILOG1       ;(2)
                JSR WNIBL9              ;(15,9,6)
                LDA #DATA_EPILOG2       ;(2)
                JSR WNIBL9              ;(15,9,6)
                LDA #DATA_EPILOG3       ;(2)
                JSR WNIBL9              ;(15,9,6)
                LDA #DATA_EPILOG4       ;(2)
                JSR WNIBL9              ;(15,9,6)
                LDA Q7L,X               ; Read Mode
WEXIT           LDA Q6L,X               ;
                RTS                     ;
WNIBL9          CLC                     ;+2
WNIBL7          PHA                     ;+3 = 36
                PLA                     ;+4 = 40
WNIBL           STA Q6H,X               ;+5 =  5
                ORA Q6L,X               ;+4 =  9
                RTS                     ;+6 =  ; Total = Original DOS 3.3 does not count RTS here


; $B8C2 POSTNB16 PostNib16
; zNibCount
;  == 0    Total = 256 Bytes
;  == 1    Total =   1 Bytes
;  == 2    Total =   2 Bytes
;  :
;  == 255  Total = 255 Bytes
PostNib16       LDY #$0
POST1           LDX #<NIBBLES_PER_SECTOR
POST2           DEX
                BMI POST1
                LDA NibBuf1,Y
                LSR NibBuf2,X           ; Shift 2 bits from NibBuf2
                ROL
                LSR NibBuf2,X           ; into NibBuff1
                ROL                     
                STA (zBufferPtr),Y
                INY
                CPY zNibCount
                BNE POST2
                RTS

; $B8DC READ16 ReadData
;   Read raw 6-bit disk nibbles (Data) into NibBuf1, NibBuf2
;   <D5> <AA> <AD> ... <Crc> <D5> <AA> <EB> <FF>
; References:
;    NibBuf1
;    NibBuf2
;    Decode6n2
;    zRwtsTemp
READ16          LDY #$20
RSYNC           DEY
                BEQ ReadError
READ1           LDA Q6L,X
                BPL READ1               ; ** Do NOT cross page **
RSYNC1          EOR #DATA_PROLOG1
                BNE RSYNC
                NOP
READ2           LDA Q6L,X
                BPL READ2               ; ** Do NOT cross page **
                CMP #DATA_PROLOG2
                BNE RSYNC1
                LDY #<NIBBLES_PER_SECTOR
READ3           LDA Q6L,X
                BPL READ3               ; ** Do NOT cross page **
                CMP #DATA_PROLOG3
                BNE RSYNC1
                LDA #$00
RDATA1          DEY
                STY zRwtsTemp           ; Lots of wasted code due to ...
READ4           LDY Q6L,X
                BPL READ4
                EOR Decode6n2-RWTS_FIRST_VALID_NIBBLE,Y
                LDY zRwtsTemp           ; ... register juggling ...
                STA NibBuf2,Y
                BNE RDATA1
RDATA2          STY zRwtsTemp           ; ... instead of self-modifying code.
READ5           LDY Q6L,X
                BPL READ5               ; ** Do NOT cross page **
                EOR Decode6n2-RWTS_FIRST_VALID_NIBBLE,Y
                LDY zRwtsTemp
                STA NibBuf1,Y
                INY
                BNE RDATA2
READ6           LDY Q6L,X               ; Checksum
                BPL READ6               ; ** Do NOT cross page **
                CMP Decode6n2-RWTS_FIRST_VALID_NIBBLE,Y
                BNE ReadError           ;
READ7           LDA Q6L,X
                BPL READ7               ; ** Do NOT cross page **
                CMP #DATA_EPILOG1
                BNE ReadError
                NOP
READ8           LDA Q6L,X
                BPL READ8               ; ** Do NOT cross page **
                CMP #DATA_EPILOG2
                BEQ ReadExit            ;vv
; $B942 Also called from RDADR16!
ReadError       SEC                     ; Error ; DOS 3.3 Patch: Ingore checksum: 18
                RTS                     ; Exit from READ16 OR READADDR16

; $B944 RDADR16 ReadAddress
;    Read raw 6-bit disk nibbles (Addr) 
; Uses:
;    zMetaCount
;    zMetaChecksum
;    zMetaPrev44
RDADR16         LDY #$100-4             ; = $FC, must find ADDR_PROLOG1 within 4 disk nibbles
                STY zMetaCount
RDASYN          INY
                BNE ReadAddr1
                INC zMetaCount
                BEQ ReadError           ;^^
ReadAddr1       LDA Q6L,X
                BPL ReadAddr1
RDASN1          CMP #ADDR_PROLOG1
                BNE RDASYN
                NOP         
ReadAddr2       LDA Q6L,X
                BPL ReadAddr2
                CMP #ADDR_PROLOG2
                BNE RDASN1
                LDY #ADDR_META_44-1
ReadAddr3       LDA Q6L,X
                BPL ReadAddr3
                CMP #ADDR_PROLOG3
                BNE RDASN1
                LDA #$0                 ; CRC = 0
RDAFLD          STA zChecksum
ReadAddr4       LDA Q6L,X               ; Read odd bits
                BPL ReadAddr4           ; A=1a1c1e1g
                ROL                     ; A=a1c1e1gC, C=1
                STA zMetaPrev44
ReadAddr5       LDA Q6L,X               ; Read even bits
                BPL ReadAddr5           ; A=1b1d1f1h
                AND zMetaPrev44         ; &=a1c1e1g1
                STA zMetaChecksum,Y     ; A=abcdefgh
                EOR zChecksum
                DEY
                BPL RDAFLD
                TAY
                BNE ReadError           ; DOS 3.3 Patch: Disable Checksum: EA EA
ReadAddr6       LDA Q6L,X
                BPL ReadAddr6
                CMP #ADDR_EPILOG1
                BNE ReadError
; Normal DOS
;                NOP
;ReadAddr7       LDA Q6L,X
; Custom DOS
                CLC
ReadAddr7       RTS
                DW Q6L
; Custom DOS
                BPL ReadAddr7
                CMP #ADDR_EPILOG2
                BNE ReadError           ;^^
; $B99E Also called from READ16!
ReadExit        CLC 
                RTS

; $B9A0 SEEK
;    Move disk arm.  This whole routine is over-engineered.
; Entry:
;    A = Track
;    X = Slot*16
SEEK            STX zSeekSlot
                STA zSeekTrack
                CMP aTrack
                BEQ SEEKRTS
                LDA #$0
                STA zSeekDeltaTrack         ; Half Track Count
SEEK2           LDA aTrack
                STA zSeekPrevTrk
                SEC
                SBC zSeekTrack              ; Delta Tracks
                BEQ SEEKEND                 ; On destination track?
                BCS OUT
                EOR #$FF                    ; Move inwards towards Track $22
                INC aTrack
                BCC MinTest                 ; Always
OUT             ADC #$FE                    ;C=1 -> $FF = -1, Move outwards towards Track $00
                DEC aTrack
MinTest         CMP zSeekDeltaTrack
                BCC MaxTest
                LDA zSeekDeltaTrack
MaxTest         CMP #OnTableEnd-ONTABLE     ; Table Size = $C
                BCS STEP2
STEP            TAY
STEP2           SEC                         ; C=1 Phase On
                JSR SETPHASE
                LDA ONTABLE,Y
                JSR MSWAIT                  ; 100 uSec
                LDA zSeekPrevTrk
                CLC                         ; C=0 Phase Off
                JSR ClearPhase
                LDA OFFTABLE,Y
                JSR MSWAIT
                INC zSeekDeltaTrack
                BNE SEEK2
SEEKEND         JSR MSWAIT                  ; A=0 -> wait 25 ms for disk head to stabilize
                CLC
SETPHASE        LDA aTrack
ClearPhase      AND #3                      ; 4 magnetic phases for stepper motor; if only DCT_OFFSET_PHASE was used. /s
                ROL
                ORA zSeekSlot
                TAX
                LDA DRIVE_PHASE_OFF,X
                LDX zSeekSlot
SEEKRTS         RTS

; $B9FD 3 bytes unused "*  "
padB9FD         DB $AA, $A0, $A0

; $BA00 MSWAIT
MSWAIT          LDX #$11
msWait1         DEX
                BNE msWait1
                INC DCT_MOTOR_TIME
                BNE msWait2
                INC DCT_MOTOR_TIME+1
msWait2         SEC
                SBC #$1
                BNE MSWAIT
                RTS

; $BA11 ONTABLE @ STEP2
ONTABLE         DB $01 ; [0]
                DB $30 ; [1]
                DB $28 ; [2]
                DB $24 ; [3]
                DB $20 ; [4]
                DB $1E ; [5]
                DB $1D ; [6]
                DB $1C ; [7]
                DB $1C ; [8]
                DB $1C ; [9]
                DB $1C ; [A]
                DB $1C ; [B]
OnTableEnd

; $BA1D OFFTABLE @ STEP2
OFFTABLE        DB $70 ; [0]
                DB $2C ; [1]
                DB $26 ; [2]
                DB $22 ; [3]
                DB $1F ; [4]
                DB $1E ; [5]
                DB $1D ; [6]
                DB $1C ; [7]
                DB $1C ; [8]
                DB $1C ; [9]
                DB $1C ; [A]
                DB $1C ; [B]


; $BA29 Crappy nondescript DOS 3.3 name "NIBL"
;       **HOW** are the nibbles used? Is it encoding?? decoding???
; **NOTE:** This table should not cross a page boundary
;           since that will add +1 to the cycle count of the instruction
;
; There are 64 valid disk nibbles with 6&2 encoding
;    !!  Technically $AA is a valid disk nibble but it is reserved for meta-data
;    @@  Techincally $D5 is a valid disk nibble but it is reserved for meta-data
;
; The standard way of writing this is too just listi it in a linear fashion by how it appears in memory:
;               DB $96,$97,$9A,$9B      ; [$00]
;               DB $9D,$9E,$9F,$A6      ; [$04]
;               DB $A7,$AB,$AC,$AD      ; [$08]
;               DB $AE,$AF,$B2,$B3      ; [$0C]
;               DB $B4,$B5,$B6,$B7      ; [$10]
;               DB $B9,$BA,$BB,$BC      ; [$14]
;               DB $BD,$BE,$BF,$CB      ; [$18]
;               DB $CD,$CE,$CF,$D3      ; [$1C]
;               DB $D6,$D7,$D9,$DA      ; [$20]
;               DB $DB,$DC,$DD,$DE      ; [$24]
;               DB $DF,$E5,$E6,$E7      ; [$28]
;               DB $E9,$EA,$EB,$EC      ; [$2C]
;               DB $ED,$EE,$EF,$F2      ; [$30]
;               DB $F3,$F4,$F5,$F6      ; [$34]
;               DB $F7,$F9,$FA,$FB      ; [$38]
;               DB $FC,$FD,$FE,$FF      ; [$3C]
; But a better way to organize it is by valid disk nibbles:
;                   x0  x1  x2  x3  x4  x5  x6  x7  x8  x9  xA  xB  xC  xD  xE  xF
;                9x:--  --  --  --  --  --  96  97  --  --  9A  9B  --  9D  9E  9F
;                Ax:--  --  --  --  --  --  A6  A7  --  --  !!  AB  AC  AD  AE  AF
;                Bx:--  --  B2  B3  B4  B5  B6  B7  --  B9  BA  BB  BC  BD  BE  BF
;                Cx:--  --  --  --  --  --  --  --  --  --  --  CB  --  CD  CE  CF
;                Dx:--  --  --  D3  --  @@  D6  D7  --  D9  DA  DB  DC  DD  DE  DF
;                Ex:--  --  --  --  --  E5  E6  E7  --  E9  EA  EB  EC  ED  EE  EF
;                Fx:--  --  F2  F3  F4  F5  F6  F7  --  F9  FA  FB  FC  FD  FE  FF
Encode6n2       DB                         $96,$97,        $9A,$9B,    $9D,$9E,$9F ; [$00]
                DB                         $A6,$A7,            $AB,$AC,$AD,$AE,$AF ; [$07]
                DB         $B2,$B3,$B4,$B5,$B6,$B7,    $B9,$BA,$BB,$BC,$BD,$BE,$BF ; [$0E]
                DB                                             $CB,    $CD,$CE,$CF ; [$1B]
                DB             $D3,        $D6,$D7,    $D9,$DA,$DB,$DC,$DD,$DE,$DF ; [$1F]
                DB                     $E5,$E6,$E7,    $E9,$EA,$EB,$EC,$ED,$EE,$EF ; [$28]
                DB         $F2,$F3,$F4,$F5,$F6,$F7,    $F9,$FA,$FB,$FC,$FD,$FE,$FF ; [$32]

; DOS 3.3A left over temp assembly garbage "33 @3CE3 @3CE3..."
padBA69     DB $B3 ; "3"

; $BA6A
; DOS 3.3 Normally this lives at $B7B5..$B7C1
; But this was moved into RWTS $B800..$B8FF
DISKIO          PHP
                SEI                     ; Disable interrupts since accessing disk
                JSR RWTS
                BCS DiskErr
                PLP
                CLC
                RTS
DiskErr         PLP
                SEC
                RTS

; DOS 3.3A left over temp assembly garbage "33 @3CE3 @3CE3..."
padBA77     DB $A0, $E0, $B3    ; " @3"

; $BA7A IOB
; DOS 3.3A left over temp assembly garbage "3E* .33E* ,E33* <CtrlH> <CtrlB> E33*. ED30."
; NOTE: Copy2IOB @ BF43 copies the init IOB from $B7E8 to the new IOB $BA7A
IOB_TYPE        DB $B3   ; [0] #00  B7E8:   01
IOB_SLOT        DB $C5   ; [1] #01  B7E9:   60
IOB_DRIVE       DB $AA   ; [2] #02  B7EA:   01
IOB_VOL         DB $A0   ; [3] #03  B7EB:   FE
IOB_TRK         DB $82   ; [4] #04  B7EC:   00
IOB_SEC         DB $B3   ; [5] #05  B7ED:   01
IOB_DCT         DA $C5B3 ; [6] #06  B7EE:@B7FB  DCT_TYPE, DCT_PHASES, DCT_MOTOR
IOB_DST         DA $A0AA ; [7] #08  B7F0:@B700
IOB_LEN         DA $C582 ; [8] #0A  B7F2: 0000
IOB_CMD         DB $B3   ; [9] #0C  B7F4:   02
IOB_STATUS      DB $B3   ; [A] #0D  B7F5:   F8
IOB_MOD         DB $AA   ; [B] #0E  B7F6:   FE
IOB_PREVSLOT    DB $88   ; [C] #0F  B7F7:   60
IOB_PREVDRIVE   DB $82   ; [D] #10  B7F8:   01

LoadTrack       DB $C5
LoadSector      DB $B3
LoadAddress     DB $B3

; $BA8E left over temp assembly garbage "*..ED30."
; DOS 3.3A wastes $BA84..$BA95
padBA8E         DB $AA, $88, $82
                DB $C5, $C4, $B3, $B0
                DB $88


; $BA96 Crappy nondescript DOS 3.3 name "DNIBL"
;       **HOW** are the nibbles used? Is it encoding?? decoding???
;
; **NOTE:** This table should not cross a page boundary
;           since that will add +1 to the cycle count of the instruction
;
; <= $3F Decoded disk nibble
; >  $80 Invalid disk nibble (place holder)
;    !!  Technically $AA is a valid disk nibble but it is reserved for meta-data
;    @@  Techincally $D5 is a valid disk nibble but it is reserved for meta-data
;                   x0  x1  x2  x3  x4  x5  x6  x7  x8  x9  xA  xB  xC  xD  xE  xF
;                9x:--  --  --  --  --  --  00  01  --  --  02  03  --  04  05  06
;                Ax:--  --  --  --  --  --  07  08  --  --  !!  09  0A  0B  0C  0D
;                Bx:--  --  0E  0F  10  11  12  13  --  14  15  16  17  18  19  1A
;                Cx:--  --  --  --  --  --  --  --  --  --  --  1B  --  1C  1D  1E
;                Dx:--  --  --  1F  --  @@  20  21  --  22  23  24  25  26  27  28
;                Ex:--  --  --  --  --  29  2A  2B  --  2C  2D  2E  2F  30  31  32
;                Fx:--  --  33  34  35  36  37  38  --  39  3A  3B  3C  3D  3E  3F
Decode6n2       DB                         $00,$01,$98,$99,$02,$03,$9C,$04,$05,$06 ; [$96]
                DB $A0,$A1,$A2,$A3,$A4,$A5,$07,$08,$A8,$A9,$AA,$09,$0A,$0B,$0C,$0D ; [$A0]
                DB $B0,$B1,$0E,$0F,$10,$11,$12,$13,$B8,$14,$15,$16,$17,$18,$19,$1A ; [$B0]
                DB $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$1B,$CC,$1C,$1D,$1E ; [$C0]
                DB $D0,$D1,$D2,$1F,$D4,$D5,$20,$21,$D8,$22,$23,$24,$25,$26,$27,$28 ; [$D0]
                DB $E0,$E1,$E2,$E3,$E4,$29,$2A,$2B,$E8,$2C,$2D,$2E,$2F,$30,$31,$32 ; [$E0]
                DB $F0,$F1,$33,$34,$35,$36,$37,$38,$F8,$39,$3A,$3B,$3C,$3D,$3E,$3F ; [$F0]

; $BB00 NibbleCheck
; The Nibble Check/Nibble Count looks for this pattern
;
;    1x $?? Throw away byte from Sector $F
;  532+ $FF Padding
;    1x $?? LockType
;    3x $?? Key Values
;    1x $9E Optional (always missing)
;    1x $E7 Optional
;    1x $F9 Optional (always present)
;   16x $FF Sync nibbles
;    1x $D5 Start of Sector $0 Addr Prolog!)
;    1x $AA
;
;           PRE                           POST         EPILOG
;    Trk    512+   Lock    Key     Key4   16 sync bytes      Actual Expect
;    00: DF FF..FF  F7 [7] FF CF E7 -- F9 [FF] [FF x15] D5 AA $227 < $0227
;    01: FF FF..FF  F9 [2] EE FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    02: FF FF..FF  CF [5] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $228 < $022B
;    03: FF FF..FF  F3 [3] DC FF CF E7 F9 [FF] [FF x15] D5 AA $226 < $0229
;    04: DF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $228 < $022B
;    05: DF FF..FF  9E [6] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $227 < $0229
;    06: CF FF..FF  FC [1] F7 FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    07: DF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $228 < $022B
;    08: DF FF..FF  9E [6] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    09: FF FF..FF  F7 [7] FF CF E7 -- F9 [FF] [FF x15] D5 AA $226 < $0229
;    0A: DF FF..FF  F9 [2] EE FF CF E7 F9 [FF] [FF x15] D5 AA $226 < $0229
;    0B: FF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    0C: DF FF..FF  F3 [3] DC FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    0D: DF FF..FF  9E [6] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $227 < $0229
;    0E: DF FF..FF  F7 [7] FF CF E7 -- F9 [FF] [FF x15] D5 AA $228 < $022C
;    0F: FF FF..FF  9E [6] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    10: DF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    11: DF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $226 < $0229
;    12: DF FF..FF  F3 [3] DC FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    13: DF FF..FF  FC [1] F7 FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022B
;    14: DF FF..FF  F7 [7] FF CF  E7-- F9 [FF] [FF x15] D5 AA $226 < $022A
;    15: DF FF..FF  FE [0] F7 FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022B
;    16: DF FF..FF  CF [5] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $226 < $0228
;    17: DF FF..FF  9E [6] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $228 < $022A
;    18: DF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    19: FF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    1A: DF FF..FF  9E [6] E7 F9 9E E7 F9 [FF] [FF x15] D5 AA $228 < $022A
;    1B: DF FF..FF  FC [1] F7 FF CF E7 F9 [FF] [FF x15] D5 AA $226 < $022A
;    1C: DF FF..FF  FC [1] F7 FF CF E7 F9 [FF] [FF x15] D5 AA $226 < $0229
;    1D: DF FF..FF  F7 [7] FF CF E7 -- F9 [FF] [FF x15] D5 AA $226 < $022A
;    1E: FF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    1F: FF FF..FF  E7 [4] B9 FE CF E7 F9 [FF] [FF x15] D5 AA $227 < $022A
;    20: DF FF..FF  FE [0] F7 FF CF E7 F9 [FF] [FF x15] D5 AA $227 < $022B
;    21: DF FF..FF  F7 [7] FF CF E7 -- F9 [FF] [FF x15] D5 AA $228 < $022B
;    22: D7 FF..FF  F7 [7] FF CF E7 -- F9 [FF] [FF x15] D5 AA $227 < $022A

NibbleCheck     PHP
                BCC NibbleCheck1
BadRead         JMP TRYADR2
NibbleCheck1    LDA Q6L,X               ; D5 AA <xx> Read Epilog3 of Sector $F
                BPL NibbleCheck1        ;
                LDA zMetaSector         ; Only do nibble check on sector $F
                CMP #NIBBLE_CHECK_SECTOR
                BNE NoNibbleCheck
                PLP
                JSR NibbleCount
                PHP
                BCS BadRead
NoNibbleCheck   PLP
                JMP DoneNibbleCheck
NibbleCount     LDY #0
                STY zNibCount
                STY zNibCount+1
NibCountPreFF   LDA Q6L,X
                BPL NibCountPreFF
                CMP #NIBBLE_CHECK_PRE
                BNE IsNib9E
                INC zNibCount
                BNE NibCountPreFF
                INC zNibCount+1
                BNE NibCountPreFF       ; Always; The maximum number of disk nibbles on Track 0 is ~  $2000
IsNib9E         CMP #NIBBLE_CHECK_LOCK_6
                BEQ HasLock6
                CMP #NIBBLE_CHECK_LOCK_5
                BEQ HasLock5
                TAY
                LDA Nib2LockType-$E7,Y
                BMI NibCheckError
                TAY
NibKey1         LDA Q6L,X
                BPL NibKey1
                CMP aNibKey1,Y
                BNE NibCheckError
                NOP
                NOP
                NOP
NibKey2         LDA Q6L,X
                BPL NibKey2
                CMP aNibKey2,Y
                BNE NibCheckError
                NOP
                NOP
                NOP
NibKey3         LDA Q6L,X
                BPL NibKey3
                CMP aNibKey3,Y
                BNE NibCheckError
IsNibF9         LDA aNibSkipE7,Y
                BNE NibMidF9
                BEQ NibMidE7
HasLock5        LDY #5
                BNE NibKey1             ;^^ Always
HasLock6        LDY #6
                BNE NibKey1             ;^^ Always
NibCheckError   SEC
                RTS
; $BB77
; Look for optional Key4,5,6 <9E> <E7> <F9>
NibMid9E        LDA Q6L,X
                BPL NibMid9E
                CMP #NIBBLE_CHECK_OPT_1
                BNE NibCheckFF          ;Pseudo-reset state back to CheckFF

                INC zNibCount
                BNE NibMidE7
                INC zNibCount+1

NibMidE7        LDA Q6L,X
                BPL NibMidE7
                CMP #NIBBLE_CHECK_OPT_2
                BNE NibCheckError

                INC zNibCount
                BNE NibMidF9
                INC zNibCount+1

NibMidF9        LDA Q6L,X
                BPL NibMidF9
                CMP #NIBBLE_CHECK_OPT_3
                BNE NibCheckError

                INC zNibCount
                BNE NibMid9E            ;^^ Why 9E?
                INC zNibCount+1
                BNE NibMid9E            ;^^ Always

NibCheckFF      CMP #NIBBLE_CHECK_POST
                BNE NibCheckError
                LDY #0                  ; Read 15 sync bytes; previous was read in CheckFF
NibSyncFF       LDA Q6L,X
                BPL NibSyncFF
                CMP #NIBBLE_CHECK_POST  ; [FF..FF] D5 AA
                BNE NibCheckD5
                INY
                NOP
                NOP
                BNE NibSyncFF           ;^^ Always
NibCheckD5      CMP #NIBBLE_CHECK_EPI_1 ; $D5
                BNE NibCheckError
NibSync16       CPY #NIBBLE_COUNT_POST-1    ; NibMid9e -> NibCheckFF ate the first sync $FF
                BNE NibCheckError
NibCheckAA      LDA Q6L,X
                BPL NibCheckAA
                CMP #NIBBLE_CHECK_EPI_2 ; $AA
                BNE NibCheckError

NibCheckPass    LDA #NIBBLE_COUNT_POST+1    ; Include first Addr Header
                CLC
                ADC zNibCount
                STA zNibCount
                BCC NibCheckLen
                INC zNibCount+1

NibCheckLen     LDY #IOB_OFFSET_TRACK
                LDA (zDosIOB),Y
                TAY
                LDA NibbleCountMaxLo,Y
                SEC
                SBC zNibCount
                BMI NibCheckError

                CMP #NIBBLE_COUNT_SLACK
                BCS NibCheckError

                LDA NibbleCountMaxHi,Y
                CMP zNibCount+1
                BNE NibCheckError
                CLC
                RTS

; $BBE7
; Nib2LockType
; Convert a disk nibble to a lock type
;     <= $07 Which lock table to use
;     == $FF Invalid; bad read or error
Nib2LockType    DB $04 ; [E7]
                DB $FF ; [E8]
                DB $FF ; [E9]
                DB $FF ; [EA]
                DB $FF ; [EB]
                DB $FF ; [EC]
                DB $FF ; [ED]
                DB $FF ; [EE]
                DB $FF ; [EF]
                DB $FF ; [F0]
                DB $FF ; [F1]
                DB $FF ; [F2]
                DB $03 ; [F3]
                DB $FF ; [F4]
                DB $FF ; [F5]
                DB $FF ; [F6]
                DB $07 ; [F7] ; $BC00 DOS 3.3 NBUF2
                DB $FF ; [F8]
                DB $02 ; [F9]
                DB $FF ; [FA]
                DB $FF ; [FB]
                DB $01 ; [FC]
                DB $FF ; [FD]
                DB $00 ; [FE]
                DB $FF ; [FF]

; Expected disk nibbles for the 8 different lock types
;                  [0] [1] [2] [3] [4] [5] [6] [7]
aNibKey1        DB $F7,$F7,$EE,$DC,$B9,$E7,$E7,$FF
aNibKey2        DB $FF,$FF,$FF,$FF,$FE,$F9,$F9,$CF
aNibKey3        DB $CF,$CF,$CF,$CF,$CF,$9E,$9E,$E7
aNibSkipE7      DB $00,$00,$00,$00,$00,$00,$00,$01


; $BC29 Left-over unused garbage, no idea where this comes from; it certainly is not any remnants of DOS 3.3
; 
; This should have been padded with zero like this:
;padBC29         = *
;spcBC29         = $BC56 - padBC29
;                DS spcBC29,0
; Instead of this literal garbage
;     APOHAA@Z
;     PG ~ @@ 
;     @L@BDBPF
;     DAOU*@@@
                DB $01
                DB $10     ; 16 sectors???
                DB $0F
                DB $08
                DB $01
                DB $01
                DB $00     ; 16-bit pointer $1A00 ???
                DB $1A
                DB $10
                DB $07
                DB $7F,$FE ; This 3 bytes reminds me of DOS 3.3 OPTAB3 "Length Range"
                DB $FF     ;  but since it is in Big Endian who knows?
                DB $00
                DB $00
                DB $FF
                DB $00
                DB $0C
                DB $00
                DB $02
                DB $04
                DB $02
                DB $50
                DB $06
                DB $04
                DB $C1
                DB $0F
                DB $D5 ; BC44
                DB $AA ; BC45 
                DB $00
                DB $00
                DB $00
                DB $00
                DB $00
                DB $00
                DB $00
                DB $02
                DB $01
                DB $06
                DB $51
                DB $0A
                DB $20
                DB $26
                DB $4A
                DB $80

; $BC56 "WADR16" but hijacked to Boot Stage 3
;
; Why is this not in the boot sector???
BOOT_3          LDY #RESET_END-RESET_BEGIN - 1
CopyReset       LDA RESET_BEGIN,Y
                STA CTRL_RESET,Y
                DEY
                BPL CopyReset

; Load 3 files

; "File:" DINO.EGGS.T13
;    T13SD $0400
;    T13SC $0500
;    T13SB $0600 // WTF?! This loads into NBUF1 !?
;    T13SA $0700 // WTF?! This loads into NBUF2 !?
;    T13S9 $0800
;    T13S8 $0900
;    T13S7 $0A00
;    T13S6 $0B00
;    T13S5 $0C00
;    T13S4 $0D00
;    T13S3 $0E00
;    T13S2 $0F00
;    T13S1 $1000
;    T13S0 $1100
;    T14SF $1200
;    T14SE $1300
;    T14SD $1400
;    T14SC $1500
;    T14SB $1600
;    T14SA $1700
;    T14S9 $1800
;    T14S8 $1900
;    T14S7 $1A00
;    T14S6 $1B00
;    T14S5 $1C00
;    T14S4 $1D00
;    T14S3 $1E00
;    T14S2 $1F00
                LDA #$13 ; Track $13
                LDX #$0F ; Sector $F
                LDY #$04 ; Page  $04 --- Wait a minute... this straddles NBUF1 and NBUF2 !?
                JSR LoadFile

; "File:" DINO.EGGS.T15, "Orange Ground", Level 0, plus game code
;                   T16SF $6E00    T17SF $7E00    T18SF $8E00    T19SF $9E00    T1ASF $AE00
;                   T16SE $6F00    T17SE $7F00    T18SE $8F00    T19SE $9F00    T1ASE $AF00
;    T15SD $6000    T16SD $7000    T17SD $8000    T18SD $9000    T19SD $A000    T1ASD $B000
;    T15SC $6100    T16SC $7100    T17SC $8100    T18SC $9100    T19SC $A100    T1ASC $B100
;    T15SB $6200    T16SB $7200    T17SB $8200    T18SB $9200    T19SB $A200    T1ASB $B200
;    T15SA $6300    T16SA $7300    T17SA $8300    T18SA $9300    T19SA $A300    T1ASA $B300
;    T15S9 $6400    T16S9 $7400    T17S9 $8400    T18S9 $9400    T19S9 $A400    T1AS9 $B400
;    T15S8 $6500    T16S8 $7500    T17S8 $8500    T18S8 $9500    T19S8 $A500    T1AS8 $B500
;    T15S7 $6600    T16S7 $7600    T17S7 $8600    T18S7 $9600    T19S7 $A600    T1AS7 $B600
;    T15S6 $6700    T16S6 $7700    T17S6 $8700    T18S6 $9700    T19S6 $A700    T1AS6 $B700
;    T15S5 $6800    T16S5 $7800    T17S5 $8800    T18S5 $9800    T19S5 $A800
;    T15S4 $6900    T16S4 $7900    T17S4 $8900    T18S4 $9900    T19S4 $A900
;    T15S3 $6A00    T16S3 $7A00    T17S3 $8A00    T18S3 $9A00    T19S3 $AA00
;    T15S2 $6B00    T16S2 $7B00    T17S2 $8B00    T18S2 $9B00    T19S2 $AB00
;    T15S1 $6C00    T16S1 $7C00    T17S1 $8C00    T18S1 $9C00    T19S1 $AC00
;    T15S0 $6D00    T16S0 $7D00    T17S0 $8D00    T18S0 $9D00    T19S0 $AD00
                LDA #$15 ; Track $15
                LDX #$0F ; Sector $F
                LDY #$60 ; Page  $60
                JSR LoadFile

; "File": DINO.EGGS.T1B
;                   T1ASF $2D00
;                   T1ASE $2E00
;    T1BSD $2000    T1ASD $2F00
;    T1BSC $2100    T1ASC $3000
;    T1BSB $2200    T1ASB $3100
;    T1BSA $2300    T1ASA $3200
;    T1BS9 $2400    T1AS9 $3300
;    T1BS8 $2500    T1AS8 $3400
;    T1BS7 $2600    T1AS7 $3500
;    T1BS6 $2700    T1AS6 $3600
;    T1BS5 $2800    T1AS5 $3700
;    T1BS4 $2900    T1AS4 $3800
;    T1BS3 $2A00    T1AS3 $3900
;    T1BS2 $2B00    T1AS2 $3A00
;    T1BS1 $2C00
;    T1BS0 $2C00
                LDA #$1B ; Track $15
                LDX #$0F ; Sector $F
                LDY #$20 ; Page  $60
                JSR LoadFile

; $BC7C CopyHighScore
; Copy: [2000:200A] -> $A800 // @ BC7C
;                             0  1  2  3  4  5  6  7  8  9  A
;    Src T08S8 $2000 // 2000:04 10 10 04 60 04 60 00 00 00 07
;    Dst T19S5 $A000 // A800:04 04 04 04 87 04 87 87 00 00 07
;
; Why is this not read from Track $8, Sector $8 ???
; Since we have SaveHighScore = $BF12
                LDX #Level-Men
CopyHighScore
                LDA $2000,X
                STA Men,X
                DEX
                BPL CopyHighScore

                JMP Main

; $BC8A LoadFile
; On Entry:
;    A = Track
;    X = Sector
;    Y = Address
LoadFile        STA LoadTrack
                STX LoadSector
                STY LoadAddress

RetryRWTS       LDY #<IOB_TYPE
                LDA #>IOB_TYPE
                STY zDosIOB
                STA zDosIOB+1
SetupVolume     LDY #IOB_OFFSET_VOLUME  ; Wasted memory, should be INY and come after SetupTrack
                LDA #$0                 ; $00 == match any
                STA (zDosIOB),Y
SetupCommand    LDY #IOB_OFFSET_COMMAND
                LDA #RWTS_CMD_READ
                STA (zDosIOB),Y
SetupDest       LDY #IOB_OFFSET_BUFFER
                LDA #<FtocBuffer        ; Wasted memory, could reuse from SetVolume
                STA (zDosIOB),Y
                INY                     ; Page of Destination
                LDA #>FtocBuffer
                STA (zDosIOB),Y
SetupTrack      LDY #IOB_OFFSET_TRACK
                LDA LoadTrack
                STA (zDosIOB),Y
                INY                     ; Y = IOB_OFFSET_SECTOR
SetupSector     LDA LoadSector          ; Wasted memory, should be in preamble of LoadFile
                STA (zDosIOB),Y

ReadFTOC        LDY #<IOB_TYPE          ; Wasted memory; there is only ever one IOB
                LDA #>IOB_TYPE          ; so why push this burdeon onto the caller?
                JSR DISKIO              ;^^ $BA6A
                BCS RetryRWTS

SetupLoadAddr   LDY #IOB_OFFSET_BUFFER+1
                LDA LoadAddress
                STA (zDosIOB),Y         ; Reads are page-aligned

; Meta-data list of Track/Sector that belong to the file
; * DOS 3.3 calles this a File Directory
; * ProDOS calls this an Index Block
; * I call it a FTOC (File Table of Contents)
;
; DOS 3.3 FTOC has format:
;     x0       x1          x2           x3           x4              x5 and x6   x7
; 00: <unused> <LinkTrack> <LinkSector> <SectorSize> <LastSectorLen> <RelSector> <pad0>
;   : FDUCDE   FDLTRK      FDLSEC       FDNSA        FDLSDL          FDFRS       FSSPAR

;     x8     x9     xA     xB     xC   xD    xE   xf
; 08: <pad1> <pad2> <pad3> <pad4> <Trk><Sec> <Trk><Sec>
;                                 \________/ \________/
;                                 DataSec#1  DataSec#2

ProcessFTOC1    LDX #$E                 ; Skip first sector of file due to DOS 3.3 retarded design of
ProcessFTOC2    LDA FtocBuffer,X        ; putting 4 bytes meta-data Address,Lenght in the file itself instead of CATALOG
                BEQ LoadFile0
                LDY #IOB_OFFSET_TRACK
                STA (zDosIOB),Y
                LDA FtocBuffer+1,X
                INY                     ; Y = IOB_OFFSET_SECTOR
                STA (zDosIOB),Y
                TXA

                PHA                     ; Push Offset
                    LDY #<IOB_TYPE
                    LDA #>IOB_TYPE
                    JSR DISKIO
                PLA                     ; Pop Offset
                BCS ProcessFTOC1        ;^^ Start with first FTOC again
                TAX
                INX                     ; move past Track
                INX                     ; most past Sector
                LDY #IOB_OFFSET_BUFFER+1
                LDA (zDosIOB),Y
                ADC #1                  ; C=0 since if C=1 then branched back to ProcessFTOC1
                STA (zDosIOB),Y
                BNE ProcessFTOC2        ;^^ Always since we will stop long before DstAddr = $FF wrap-around
LoadFile0       RTS

; $BCFA
RESET_BEGIN
                DA  WipeMem
                DB {WipeMem/256} ! $A5  ; ROM $FA88 Powered Up
RESET_END = *

; DOS 3.3 wastes/padds $BCDF..$BCFF with zeroes
; Left over instructions?               ; "%E$" ???
padBCFD         DB $A5                  ; xxx $A5xx
                DB $85,$A4              ; STA $A4

; $BD00 RWTS
; On Entry:
;    A = DosIOB Addr High = $BA
;    Y = DosIOB Addr Low  =   $7A
;
RWTS            STY zDosIOB
                STA zDosIOB+1
                LDY #2
                STY aRecalibCount
                LDY #4
                STY aSeekCount

                LDY #IOB_OFFSET_SLOT
                LDA (zDosIOB),Y ; A = new slot*16
                TAX             ; X = new slot*16; Save new slot
                LDY #IOB_OFFSET_PREV_SLOT
                CMP (zDosIOB),Y
                BEQ SameSlot
; Different Slot
                TXA             ; Load new slot
                PHA             ; Push new slot
                    LDA (zDosIOB),Y
                    TAX         ; "Push" Old Slot
                PLA             ; Pop new slot
                PHA             ; Push new slot
                    STA (zDosIOB),Y   ; Update old slot
                    LDA Q7L,X
StillOn             LDY #8      ; Check if data is the same for 96 usec
                    LDA Q6L,X   ; To tell if motor is really off
NotSure             CMP Q6L,X
                    BNE StillOn
                    DEY
                    BNE NotSure
                PLA             ; Pop Old Slot
                TAX             ; Get New Slot

SameSlot        LDA Q7L,X
                LDA Q6L,X
                LDY #RWTS_MIN_NIBBLES_DELTA
CheckIfOn       LDA Q6L,X
                PHA
                PLA
                PHA
                PLA
                STX aReadSlot
                CMP Q6L,X
                BNE DriveIsOn
                DEY
                BNE CheckIfOn
DriveIsOn       PHP                     ; Push IsOn
                    LDA DRIVE_MOTOR_ON,X

                    LDY #IOB_OFFSET_DCT             ; $BD54
PTRMOV              LDA (zDosIOB),Y                 ; Copy 4 bytes from IOB[6] @ $BA80-$BA83 to $3C..$3F (zDosDCT, zBufferPtr)
                    STA zDosDCT-IOB_OFFSET_DCT,Y    ;   BA80: [6] IOB_OFFSET_DCT    => zDosDCT   3C: [0] -> $B7FB = DCT_OFFSET_TYPE
                    INY                             ;   BA82: [7] IOB_OFFSET_BUFFER => zBufferPtr3E: [1] -> $0200 = FtocBuffer
                    CPY #IOB_OFFSET_LEN             ;   BA84: [8] IOB_OFFSET_LEN
                    BNE PTRMOV

                    LDY #DCT_OFFSET_MOTOR+1
                    LDA (zDosDCT),Y                 ; zDosDCT was setup above
                    STA DCT_MOTOR_TIME+1            ; BUG: Motor On Time Low is initialized from DCT_MOTOR_TIME!
                    LDY #IOB_OFFSET_DRIVE
                    LDA (zDosIOB),Y
                    LDY #IOB_OFFSET_PREV_DRIVE
                    CMP (zDosIOB),Y
                    BEQ SameDrive
                    STA (zDosIOB),Y
                PLP                     ; Pop IsOn
                LDY #$00                ; 6502 doesn't have one byte CLZ
                PHP                     ; Pop IsOn
SameDrive           ROR                 ; Crappy original DOS label "SD"
                    BCC SelectDrive2
                    LDA DRIVE_SELECT1,X
                    BCS DriveSelect
SelectDrive2        LDA DRIVE_SELECT2,X
DriveSelect         ROR zDriveNo        ; BUG: This is used before initialized @MYSEEK2 
                PLP                     ; Pop IsOn
                PHP                     ; Push IsOn
                    BNE NOWAIT
                    LDY #7                  ; Delay 150 ms
SEEKW               JSR MSWAIT
                    DEY
                    BNE SEEKW
                    LDX aReadSlot
NOWAIT              LDY #IOB_OFFSET_TRACK
                    LDA (zDosIOB),Y
                    JSR MYSEEK
                PLP                     ; Pop IsOn
                BNE TryTrack

                LDY DCT_MOTOR_TIME+1
                BPL MOTORUP
MOTOF           LDY #$12                ; delay 100 usec
CONWAIT         DEY
                BNE CONWAIT
                INC DCT_MOTOR_TIME      ; NOTE: DCT_MOTOR_TIME+0 is never initialized, only DCT_MOTOR_TIME+1!
                BNE MOTOF
                INC DCT_MOTOR_TIME+1
                BNE MOTOF               ; Count up to $0000
MOTORUP
TryTrack        LDY #IOB_OFFSET_COMMAND
                LDA (zDosIOB),Y
                BEQ GoAllDone          ;vv
                CMP #RWTS_CMD_FORMAT
                BEQ FormatDisk
                ROR                    ; **ASSUMES** RWTS_CMD_READ = 1
                PHP             
                BCS TRYTRK2            ; C=0 Writing...

                JSR PreNibble
TRYTRK2         LDY #48                ;
                STY aRetryCount
TRYADR          LDX aReadSlot
                JSR RDADR16
                BCC ReadRight

TRYADR2         DEC aRetryCount
                BPL TRYADR
Recalibrate     LDA aTrack
                PHA
                    LDA #RWTS_RECALIB_MAX_TRACK   ; Pretend to be on Track 96 so when we seek to Track 0
                    JSR SetTrack                  ; this will bang the drive head against the drive chasis housing
                    DEC aRecalibCount             ; because that will not cause any disk head alignment issues over time! /s
                    BEQ DriveError
                    LDA #RWTS_RECALIB_SEEK_TRY
                    STA aSeekCount
                    LDA #RWTS_RECALIB_MIN_TRACK
                    JSR MYSEEK
                PLA
ReSeek          JSR MYSEEK
                JMP TRYTRK2
ReadRight       LDY zMetaTrack
                CPY aTrack
                BEQ RightTrack
                LDA aTrack
                PHA
                    TYA
                    JSR SetTrack
                PLA
                DEC aSeekCount
                BNE ReSeek
                BEQ Recalibrate
DriveError      PLA
                LDA #$40
JumpTo1         PLP
                JMP HandleError
GoAllDone       BEQ AllDone
FormatDisk      JMP DiskFormat  ; $BEAF
RightTrack      LDY #IOB_OFFSET_VOLUME
                LDA (zDosIOB),Y
                PHA
                    LDA zMetaVolume
                    LDY #IOB_OFFSET_MOD
                    STA (zDosIOB),Y
                PLA
                BEQ CorrectVolume
                CMP zMetaVolume
                BEQ CorrectVolume
                LDA #ERR_VOL_MISMATCH   ; IOB Volume MisMatch Error
                BNE JumpTo1
CorrectVolume   LDY #IOB_OFFSET_SECTOR
                LDA (zDosIOB),Y
                TAY
                LDA INTERLEAVE,Y
                CMP zMetaSector
                BNE TRYADR2
                PLP                     ; Restore WAY back from TRYTRK
                BCC WRIT                ; C=1 write
                JSR READ16

; --- Custom DOS 3.3 Copy Protection
                JMP NibbleCheck
; --- Custom DOS 3.3 Copy Protection
                PLP
DoneNibbleCheck LDX #0
                STX zPromDst
                JSR PostNib16           ; A=?? writes trash to IOB_ERROR
                LDX aReadSlot
AllDone         CLC
                DB $24                  ; Skip next one-byte instruction SEC via BIT $zp, could also use LDY #
HandleError     SEC
                LDY #IOB_OFFSET_ERROR
                STA (zDosIOB),Y
                LDA DRIVE_MOTOR_OFF,X
                RTS

; $BE51 WRIT
WRIT            JSR WRITE16
                BCC AllDone
                LDA #ERR_WRITE_PROT     ; IOB Write Protected Error
                BCS HandleError         ;^^ Always

; $BE5A MYSEEK
; On Entry:
;    A = Track
MYSEEK          PHA                     ; Push Track
                    LDY #DCT_OFFSET_PHASE
                    LDA (zDosDCT),Y
                    ROR                 ; C=1 A=0
                PLA                     ; Pop Track
                BCC MYSEEK2             ; Did Apple _ever_ ship a drive with 1 phase/track? NO!
                ASL                     ; Two Phases/Track
                JSR MYSEEK2
                LSR aTrack              ; Fixup
                RTS

; $BE6B MYSEEK2
MYSEEK2         STA zSeekTrack
                JSR XtoY
                LDA Drive1Track,Y
                BIT zDriveNo            ; Original DOS 3.3 name DRIVNO = $35,
                BMI WasDrive0
                LDA Drive2Track,Y
WasDrive0       STA aTrack              ; Slot 0 = Destination Track
                LDA zSeekTrack
                BIT zDriveNo
                BMI IsDrive1
                STA Drive2Track,Y
                BPL GOSEEK
IsDrive1        STA Drive1Track,Y
GOSEEK          JMP SEEK

; $BE8E XTOY XtoY
; On Entry:
;    X =
;    Y = 
XtoY            TXA
                LSR
                LSR
                LSR
                LSR
                TAY
                RTS


; $BE95 SETTRK SetTrack
; On Entry:
;    A = Track
;    X = Slot*16
SetTrack        PHA                         ; Wasted memory, drives never switched
                    LDY #IOB_OFFSET_DRIVE   ; Wasted memory
                    LDA (zDosIOB),Y         ; Wasted memory
                    ROR
                    ROR zDriveNo
                    JSR XtoY
                PLA
                ASL
_SetTrack2      BIT zDriveNo
                BMI _OnDrive1
                STA Drive2Track,Y
                BPL _SetTrack0
_OnDrive1       STA Drive1Track,Y
_SetTrack0      RTS

; $BEAF DSKFORM DiskFormat
DiskFormat      LDY #IOB_OFFSET_VOLUME
                LDA (zDosIOB),Y
                STA zPromVolume
                LDA #$AA                ; For 4&4 encoding
                STA WRITE_NIB_AA
                LDY #<NIBBLES_PER_SECTOR
                LDA #0
                STA zWriteTrack

ClearNibBuf2    STA OrgBuf2-1,Y
                DEY
                BNE ClearNibBuf2
ClearNibBuf1    STA OrgBuf1,Y
                DEY
                BNE ClearNibBuf1

                LDA #80                 ; Pretend we're on track on 80
                JSR SetTrack            ; 
                LDA #RWTS_SYNC_NIBBLES
                STA zWriteNumSync
FormatTrack     LDA zWriteTrack
                JSR MYSEEK
                JSR OrgWriteTrack16     ; Original WTRACK16; now middle of WipeMem!
FormatError     LDA #ERR_FORMAT         ; "UNABLE TO FORMAT"
                BCS OrgFormatError
                LDA #RWTS_RETRY_SECTORS
                STA aRetryCount
FindSector0     SEC
                DEC aRetryCount
                BEQ OrgFormatError
                JSR RDADR16
                BCS FindSector0

                LDA zMetaSector
                BNE FindSector0
                JSR READ16
                BCS FindSector0
                INC zWriteTrack
                LDA zWriteTrack
                CMP #RWTS_LAST_TRACK
; Left over instruction -- middle of BCS!
padBEFF         DB $90

; $BF00
WipeMem         LDA #0
WipeMem2        STA $B400       ; Why not $BE00???
                DEC WipeMem2+1  ; Wipe entire page
                BNE WipeMem2    ; From    $B4FF
                DEC WipeMem2+2  ; Down to $0000
                BNE WipeMem2
                JMP $C600       ; Hard-coded firmware of disk drive; Assumes slot 6!

; $BF12
SaveHighScore   LDY #<IOB_TYPE
                LDA #>IOB_TYPE
                STY zDosIOB
                STA zDosIOB+1

HighVolume      LDY #IOB_OFFSET_VOLUME
                LDA #0          ; $00 = Any Volume
                STA (zDosIOB),Y

HighTrack       LDY #IOB_OFFSET_TRACK   ; Wasted memory; should by INY
                LDA #HIGH_SCORE_TRACK
                STA (zDosIOB),Y
                INY                     ;== IOB_OFFSET_SECTOR
HighSector      LDA #HIGH_SCORE_SECTOR
                STA (zDosIOB),Y

HighBuffLo      LDY #IOB_OFFSET_BUFFER
                LDA #<Men               ; Does/Should this need to be page-aligned?
                STA (zDosIOB),Y
                INY
HighBuffHi      LDA #>Men               ;
                STA (zDosIOB),Y

HighCmd         LDY #IOB_OFFSET_COMMAND
                LDA #RWTS_CMD_WRITE
                STA (zDosIOB),Y

                LDY #<IOB_TYPE
                LDA #>IOB_TYPE
                JMP DISKIO

; $BF43
; 
; Dino Eggs has DOS 3.3A IOB in a different location
; This entire routine is wasted memory along with reading T0S0 - T0S7 since $BA00 is also read
Copy2IOB        LDX #IOB_OFFSET_PREV_DRIVE-IOB_OFFSET_TYPE
Copy2IOB2       LDA ORG_TYPE,X
                STA IOB_TYPE,X
                DEX
                BPL Copy2IOB2
                RTS

; Resume unused VTRACK
; Middle of instruction!
paddBF4F        DB $2D          ; LDA zMetaSector

; Resume VTRACK $BF50
                BEQ VDATA
                LDA #RWTS_NUM_SYNC_NIBBLES
                CMP zWriteNumSync
                LDA zWriteNumSync
                SBC #1
                STA zWriteNumSync
                CMP #RWTS_MIN_SYNC_NIBBLES
                BCS S15LOC
VERR            SEC
                RTS
VSECT           JSR RDADR16
                BCS VERR1
VDATA           JSR READ16
                BCC SECTOK
VERR1           DEC aRetryCount
                BNE VSECT
S15LOC          JSR RDADR16
                BCS OrgNotSector15
                LDA zMetaSector
                CMP #$F
                BNE OrgNotSector15

                JSR READ16
                BCC OrgWriteTrack16     ; Middle of WipeMem!
                DEC aRetryCount
                BNE S15LOC
                SEC
WEXIT2          RTS

; $BF88 SECTOK
SECTOK          LDY zMetaSector
                LDA OrgFound,Y
                BMI VERR1
                LDA #RWTS_FLAG_NO_SECTOR
                STA OrgFound,Y
                DEC zNumSector
                BPL VSECT
                LDA zWriteTrack
                BNE WEXIT1
                LDA zWriteNumSync
                CMP #RWTS_NUM_SYNC_NIBBLES
                BCC WEXIT2
                DEC zWriteNumSync
                DEC zWriteNumSync
WEXIT1          CLC
                RTS

; $BFA8
; Logical to Physical Sector Mapping
; NOTE: 
;       DOS3.3A FOUND      = $3FA8..$3FB7
;               INTERLEAVE = $3FB8..$3FC7
;       But NibbleCount was crammed in here which moved INTERLEAVE up
;       This is safe since VerifyTrack (VTRACK) is never called
INTERLEAVE      DB $0 ; [0]
                DB $D ; [1]
                DB $B ; [2]
                DB $9 ; [3]
                DB $7 ; [4]
                DB $5 ; [5]
                DB $3 ; [6]
                DB $1 ; [7]
                DB $E ; [8]
                DB $C ; [9]
                DB $A ; [A]
                DB $8 ; [B]
                DB $6 ; [C]
                DB $4 ; [D]
                DB $2 ; [E]
                DB $F ; [F]

; $BFB8 Expected nibble count length
NibbleCountMaxLo        ; Trk
                DB  $27 ; [00]
                DB  $2A ; [01]
                DB  $2B ; [02]
                DB  $29 ; [03]
                DB  $2B ; [04]
                DB  $29 ; [05]
                DB  $2A ; [06]
                DB  $2B ; [07]
                DB  $2A ; [08]
                DB  $29 ; [09]
                DB  $29 ; [0A]
                DB  $2A ; [0B]
                DB  $2A ; [0C]
                DB  $29 ; [0D]
                DB  $2C ; [0E]
                DB  $2A ; [0F]
                DB  $2A ; [10]
                DB  $29 ; [11]
                DB  $2A ; [12]
                DB  $2B ; [13]
                DB  $2A ; [14]
                DB  $2B ; [15]
                DB  $28 ; [16]
                DB  $2A ; [17]
                DB  $2A ; [18]
                DB  $2A ; [19]
                DB  $2A ; [1A]
                DB  $2A ; [1B]
                DB  $29 ; [1C]
                DB  $2A ; [1D]
                DB  $2A ; [1E]
                DB  $2A ; [1F]
                DB  $2B ; [20]
                DB  $2B ; [21]
                DB  $2A ; [22]
                DB  $29 ; [23] Never used

; $BFDC
NibbleCountMaxHi        ; Trk
                DB  $02 ; [00]
                DB  $02 ; [01]
                DB  $02 ; [02]
                DB  $02 ; [03]
                DB  $02 ; [04]
                DB  $02 ; [05]
                DB  $02 ; [06]
                DB  $02 ; [07]
                DB  $02 ; [08]
                DB  $02 ; [09]
                DB  $02 ; [0A]
                DB  $02 ; [0B]
                DB  $02 ; [0C]
                DB  $02 ; [0D]
                DB  $02 ; [0E]
                DB  $02 ; [0F]
                DB  $02 ; [10]
                DB  $02 ; [11]
                DB  $02 ; [12]
                DB  $02 ; [13]
                DB  $02 ; [14]
                DB  $02 ; [15]
                DB  $02 ; [16]
                DB  $02 ; [17]
                DB  $02 ; [18]
                DB  $02 ; [19]
                DB  $02 ; [1A]
                DB  $02 ; [1B]
                DB  $02 ; [1C]
                DB  $02 ; [1D]
                DB  $02 ; [1E]
                DB  $02 ; [1F]
                DB  $02 ; [20]
                DB  $02 ; [21]
                DB  $02 ; [22]
                DB  $20 ; [23] Never used
