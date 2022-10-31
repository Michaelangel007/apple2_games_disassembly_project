; CONFIG: Which half of tiles to display
FIRST_HALF = 0

zSrc  = $C4   ; Tiles
zDst  = $C6   ; HGR
zRow  = $C8
zCol  = $CA

; Tiles = $95F0:9D8F
; Tiles are hard-coded dimensions:
;   width  = 2 bytes
;   height = 8 scanlines
; 
;   width  = 14 px
;   height =  8 px
;
;   Bytes/Tile = $10
;
    DO FIRST_HALF   ; First Half of tiles
Tiles   = $95F0     ; Addr : $95F0:986F
END_ROW = 17        ; Tiles: 00 .. 3F

    ELSE            ;Second Half of tiles
Tiles   = $99F0     ; Addr : $95F0 + 2*8*$40 = 
END_ROW = 17        ; Tiles: 40 .. 7F
    FIN



; Room  = $9D90 ; $0803 -> $9D90

        ORG $100

ViewTiles
        LDX #>Tiles     ; High
        LDY #<Tiles     ; Low
        STX zSrc+1
        STY zSrc+0

        LDY #01         ; Start Row 1
NextRow
        STY zRow

        LDA #0
        STA zCol
NextCol
        LDX TEXT_TO_HGR_Y_LO,Y
            INX
            INX
            INX
            INX
            STX zDst+0
            LDA TEXT_TO_HGR_Y_HI,Y
            STA zDst+1

            LDA zCol
            ASL
            ASL
            CLC
            ADC zDst
            STA zDst

            LDY #0 ; 
            LDX #8 ; 8 scanlines per tile
DrawTile        LDA (zSrc),Y
                STA (zDst),y
                INY
                LDA (zSrc),Y
                STA (zDst),y
                DEY
        
                INC zSrc+0
                INC zSrc+0
                BNE SamePage
                INC zSrc+1
SamePage        LDA zDst+1
                CLC
                ADC #4
                STA zDst+1
                DEX
                BNE DrawTile

            LDY zRow
            INC zCol
            LDA zCol
            CMP #$8
            BNE NextCol
        INY
        INY
        CPY #END_ROW        ; Alt. #$19 to maximize screeen usage: $00..$5F
        BNE NextRow
        RTS

TEXT_TO_HGR_Y_LO
    ;    0  1  2  3  4  5  6  7
    HEX 00,80,00,80,00,80,00,80
    HEX 28,A8,28,A8,28,A8,28,A8
    HEX 50,D0,50,D0,50,D0,50,D0

TEXT_TO_HGR_Y_HI
    ;    0  1  2  3  4  5  6  7
    HEX 20,20,21,21,22,22,23,23
    HEX 20,20,21,21,22,22,23,23
    HEX 20,20,21,21,22,22,23,23
