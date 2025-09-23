Dragon Wars

File: MUSIC

```asm
4E00-   4C 6B 4E    JMP   $4E6B
4E03-   AC AA 50    LDY   $50AA
4E06-   AE AB 50    LDX   $50AB
4E09-   AD A9 50    LDA   $50A9
4E0C-   48          PHA
4E0D-   68          PLA
4E0E-   CA          DEX
4E0F-   D0 02       BNE   $4E13
4E11-   F0 06       BEQ   $4E19
4E13-   E0 00       CPX   #$00
4E15-   F0 04       BEQ   $4E1B
4E17-   D0 04       BNE   $4E1D
4E19-   A6 F1       LDX   $F1
4E1B-   49 80       EOR   #$80
4E1D-   70 03       BVS   $4E22
4E1F-   EA          NOP
4E20-   50 03       BVC   $4E25
4E22-   CD 30 C0    CMP   $C030    rw:SPKR
4E25-   09 00       ORA   #$00
4E27-   30 03       BMI   $4E2C
4E29-   EA          NOP
4E2A-   10 03       BPL   $4E2F
4E2C-   CD 30 C0    CMP   $C030    rw:SPKR
4E2F-   85 F3       STA   $F3
4E31-   88          DEY
4E32-   D0 02       BNE   $4E36
4E34-   F0 06       BEQ   $4E3C
4E36-   C0 00       CPY   #$00
4E38-   F0 04       BEQ   $4E3E
4E3A-   D0 04       BNE   $4E40
4E3C-   A4 F2       LDY   $F2
4E3E-   49 40       EOR   #$40
4E40-   24 F3       BIT   $F3
4E42-   50 07       BVC   $4E4B
4E44-   70 00       BVS   $4E46
4E46-   10 09       BPL   $4E51
4E48-   EA          NOP
4E49-   30 09       BMI   $4E54
4E4B-   EA          NOP
4E4C-   30 03       BMI   $4E51
4E4E-   EA          NOP
4E4F-   10 03       BPL   $4E54
4E51-   CD 30 C0    CMP   $C030    rw:SPKR
4E54-   C6 F6       DEC   $F6
4E56-   D0 0E       BNE   $4E66
4E58-   C6 F4       DEC   $F4
4E5A-   D0 B2       BNE   $4E0E
4E5C-   8D A9 50    STA   $50A9
4E5F-   8E AB 50    STX   $50AB
4E62-   8C AA 50    STY   $50AA
4E65-   60          RTS
4E66-   EA          NOP
4E67-   EA          NOP
4E68-   4C 0E 4E    JMP   $4E0E
4E6B-   AD 36 C0    LDA   $C036    rw:CYAREG
4E6E-   48          PHA
4E6F-   29 7F       AND   #$7F
4E71-   8D 36 C0    STA   $C036    rw:CYAREG
4E74-   A9 80       LDA   #$80
4E76-   85 F0       STA   $F0
4E78-   20 91 4E    JSR   $4E91
4E7B-   A9 84       LDA   #$84
4E7D-   85 F0       STA   $F0
4E7F-   20 91 4E    JSR   $4E91
4E82-   AD 00 C0    LDA   $C000    r:KBD  w:CLR80COL
4E85-   10 F8       BPL   $4E7F
4E87-   2C 10 C0    BIT   $C010    r:KBDSTRB
4E8A-   AA          TAX
4E8B-   68          PLA
4E8C-   8D 36 C0    STA   $C036    rw:CYAREG
4E8F-   8A          TXA
4E90-   60          RTS
4E91-   08          PHP
4E92-   78          SEI
4E93-   BA          TSX
4E94-   8E AC 50    STX   $50AC
4E97-   A5 F0       LDA   $F0
4E99-   30 03       BMI   $4E9E
4E9B-   4C AC 4E    JMP   $4EAC
4E9E-   29 7F       AND   #$7F
4EA0-   85 F0       STA   $F0
4EA2-   D0 05       BNE   $4EA9
4EA4-   A9 00       LDA   #$00
4EA6-   8D 98 50    STA   $5098
4EA9-   20 BA 4E    JSR   $4EBA
4EAC-   A5 F0       LDA   $F0
4EAE-   F0 03       BEQ   $4EB3
4EB0-   20 E7 4E    JSR   $4EE7
4EB3-   AE AC 50    LDX   $50AC
4EB6-   9A          TXS
4EB7-   28          PLP
4EB8-   18          CLC
4EB9-   60          RTS
4EBA-   A5 F0       LDA   $F0
4EBC-   0A          ASL
4EBD-   AA          TAX
4EBE-   F0 04       BEQ   $4EC4
4EC0-   C9 02       CMP   #$02
4EC2-   D0 01       BNE   $4EC5
4EC4-   60          RTS
4EC5-   A9 01       LDA   #$01
4EC7-   8D B9 50    STA   $50B9
4ECA-   8D BA 50    STA   $50BA
4ECD-   A9 00       LDA   #$00
4ECF-   8D A9 50    STA   $50A9
4ED2-   8D AB 50    STA   $50AB
4ED5-   8D AA 50    STA   $50AA
4ED8-   BD DD 4E    LDA   $4EDD,X
4EDB-   8D 8D 50    STA   $508D
4EDE-   BD DE 4E    LDA   $4EDE,X
4EE1-   8D 8E 50    STA   $508E
4EE4-   60          RTS
4EE5-   BB          ???
4EE6-   50 20       BVC   $4F08
4EE8-   8C 50 C9    STY   $C950
4EEB-   00          BRK
4EEC-   D0 05       BNE   $4EF3
4EEE-   A9 80       LDA   #$80
4EF0-   85 F0       STA   $F0
4EF2-   60          RTS
4EF3-   C9 01       CMP   #$01
4EF5-   D0 10       BNE   $4F07
4EF7-   A2 00       LDX   #$00
4EF9-   20 8C 50    JSR   $508C
4EFC-   9D AE 50    STA   $50AE,X
4EFF-   E8          INX
4F00-   E0 0B       CPX   #$0B
4F02-   90 F5       BCC   $4EF9
4F04-   4C E7 4E    JMP   $4EE7
4F07-   C9 02       CMP   #$02
4F09-   D0 10       BNE   $4F1B
4F0B-   20 8C 50    JSR   $508C
4F0E-   AA          TAX
4F0F-   20 8C 50    JSR   $508C
4F12-   8D 8E 50    STA   $508E
4F15-   8E 8D 50    STX   $508D
4F18-   4C E7 4E    JMP   $4EE7
4F1B-   C9 03       CMP   #$03
4F1D-   D0 27       BNE   $4F46
4F1F-   20 8C 50    JSR   $508C
4F22-   48          PHA
4F23-   20 8C 50    JSR   $508C
4F26-   48          PHA
4F27-   AE 98 50    LDX   $5098
4F2A-   AD 8E 50    LDA   $508E
4F2D-   9D 99 50    STA   $5099,X
4F30-   AD 8D 50    LDA   $508D
4F33-   9D 9A 50    STA   $509A,X
4F36-   E8          INX
4F37-   E8          INX
4F38-   8E 98 50    STX   $5098
4F3B-   68          PLA
4F3C-   8D 8E 50    STA   $508E
4F3F-   68          PLA
4F40-   8D 8D 50    STA   $508D
4F43-   4C E7 4E    JMP   $4EE7
4F46-   C9 04       CMP   #$04
4F48-   D0 17       BNE   $4F61
4F4A-   AE 98 50    LDX   $5098
4F4D-   CA          DEX
4F4E-   CA          DEX
4F4F-   8E 98 50    STX   $5098
4F52-   BD 9A 50    LDA   $509A,X
4F55-   8D 8D 50    STA   $508D
4F58-   BD 99 50    LDA   $5099,X
4F5B-   8D 8E 50    STA   $508E
4F5E-   4C E7 4E    JMP   $4EE7
4F61-   C9 05       CMP   #$05
4F63-   D0 20       BNE   $4F85
4F65-   20 8C 50    JSR   $508C
4F68-   48          PHA
4F69-   AE 98 50    LDX   $5098
4F6C-   AD 8E 50    LDA   $508E
4F6F-   9D 99 50    STA   $5099,X
4F72-   AD 8D 50    LDA   $508D
4F75-   9D 9A 50    STA   $509A,X
4F78-   68          PLA
4F79-   9D 9B 50    STA   $509B,X
4F7C-   E8          INX
4F7D-   E8          INX
4F7E-   E8          INX
4F7F-   8E 98 50    STX   $5098
4F82-   4C E7 4E    JMP   $4EE7
4F85-   C9 06       CMP   #$06
4F87-   D0 20       BNE   $4FA9
4F89-   AE 98 50    LDX   $5098
4F8C-   CA          DEX
4F8D-   CA          DEX
4F8E-   CA          DEX
4F8F-   DE 9B 50    DEC   $509B,X
4F92-   F0 0F       BEQ   $4FA3
4F94-   BD 99 50    LDA   $5099,X
4F97-   8D 8E 50    STA   $508E
4F9A-   BD 9A 50    LDA   $509A,X
4F9D-   8D 8D 50    STA   $508D
4FA0-   4C E7 4E    JMP   $4EE7
4FA3-   8E 98 50    STX   $5098
4FA6-   4C E7 4E    JMP   $4EE7
4FA9-   C9 07       CMP   #$07
4FAB-   D0 14       BNE   $4FC1
4FAD-   20 8C 50    JSR   $508C
4FB0-   48          PHA
4FB1-   4A          LSR
4FB2-   4A          LSR
4FB3-   4A          LSR
4FB4-   4A          LSR
4FB5-   8D B9 50    STA   $50B9
4FB8-   68          PLA
4FB9-   29 0F       AND   #$0F
4FBB-   8D BA 50    STA   $50BA
4FBE-   4C E7 4E    JMP   $4EE7
4FC1-   C9 13       CMP   #$13
4FC3-   B0 12       BCS   $4FD7
4FC5-   38          SEC
4FC6-   E9 08       SBC   #$08
4FC8-   8D AD 50    STA   $50AD
4FCB-   A9 0A       LDA   #$0A
4FCD-   38          SEC
4FCE-   ED AD 50    SBC   $50AD
4FD1-   8D AD 50    STA   $50AD
4FD4-   4C E7 4E    JMP   $4EE7
4FD7-   AE AD 50    LDX   $50AD
4FDA-   BC AE 50    LDY   $50AE,X
4FDD-   84 F4       STY   $F4
4FDF-   48          PHA
4FE0-   29 3F       AND   #$3F
4FE2-   A2 49       LDX   #$49
4FE4-   A8          TAY
4FE5-   D0 02       BNE   $4FE9
4FE7-   A2 C9       LDX   #$C9
4FE9-   8E 3E 4E    STX   $4E3E
4FEC-   B9 44 50    LDA   $5044,Y
4FEF-   85 F2       STA   $F2
4FF1-   AE B9 50    LDX   $50B9
4FF4-   4A          LSR
4FF5-   CA          DEX
4FF6-   D0 FC       BNE   $4FF4
4FF8-   8D 37 4E    STA   $4E37
4FFB-   68          PLA
4FFC-   29 C0       AND   #$C0
4FFE-   49 40       EOR   #$40
5000-   F0 03       BEQ   $5005
5002-   20 8C 50    JSR   $508C
5005-   A2 49       LDX   #$49
5007-   A8          TAY
5008-   D0 02       BNE   $500C
500A-   A2 C9       LDX   #$C9
500C-   8E 1B 4E    STX   $4E1B
500F-   B9 44 50    LDA   $5044,Y
5012-   85 F1       STA   $F1
5014-   AE BA 50    LDX   $50BA
5017-   4A          LSR
5018-   CA          DEX
5019-   D0 FC       BNE   $5017
501B-   8D 14 4E    STA   $4E14
501E-   A5 F4       LDA   $F4
5020-   18          CLC
5021-   65 F5       ADC   $F5
5023-   90 02       BCC   $5027
5025-   A9 FF       LDA   #$FF
5027-   85 F5       STA   $F5
5029-   4C 03 4E    JMP   $4E03
502C-   FF          ???
502D-   FF          ???
502E-   FF          ???
502F-   FF          ???
5030-   FF          ???
5031-   FF          ???
5032-   FF          ???
5033-   FF          ???
5034-   FF          ???
5035-   FF          ???
5036-   FF          ???
5037-   FF          ???
5038-   FF          ???
5039-   FF          ???
503A-   FF          ???
503B-   FF          ???
503C-   FF          ???
503D-   FF          ???
503E-   FF          ???
503F-   FF          ???
5040-   FF          ???
5041-   FF          ???
5042-   FE F0 E2    INC   $E2F0,X
5045-   D6 CA       DEC   $CA,X
5047-   BE B4 AA    LDX   $AAB4,Y
504A-   A0 97       LDY   #$97
504C-   8F          ???
504D-   87          ???
504E-   7F          ???
504F-   78          SEI
5050-   71 6B       ADC   ($6B),Y
5052-   65 5F       ADC   $5F
5054-   5A          PHY
5055-   55 50       EOR   $50,X
5057-   4C 47 43    JMP   $4347
505A-   40          RTI
505B-   3C 39 35    BIT   $3539,X
505E-   32 30       AND   ($30)
5060-   2D 2A 28    AND   $282A
5063-   26 24       ROL   $24
5065-   22          ???
5066-   20 1E 1C    JSR   $1C1E
5069-   1B          ???
506A-   19 18 16    ORA   $1618,Y
506D-   15 14       ORA   $14,X
506F-   13          ???
5070-   12 11       ORA   ($11)
5072-   10 0F       BPL   $5083
5074-   0E 0D 0D    ASL   $0D0D
5077-   0C 0B 0B    TSB   $0B0B
507A-   0A          ASL
507B-   09 09       ORA   #$09
507D-   08          PHP
507E-   08          PHP
507F-   07          ???
5080-   07          ???
5081-   07          ???
5082-   06 06       ASL   $06
5084-   06 05       ASL   $05
5086-   05 05       ORA   $05
5088-   04 04       TSB   $04
508A-   04 04       TSB   $04
508C-   AD FF FF    LDA   $FFFF
508F-   EE 8D 50    INC   $508D
5092-   D0 03       BNE   $5097
5094-   EE 8E 50    INC   $508E
5097-   60          RTS
5098-   00          BRK
5099-   00          BRK
509A-   00          BRK
509B-   00          BRK
509C-   00          BRK
509D-   00          BRK
509E-   00          BRK
509F-   00          BRK
50A0-   00          BRK
50A1-   00          BRK
50A2-   00          BRK
50A3-   00          BRK
50A4-   00          BRK
50A5-   00          BRK
50A6-   00          BRK
50A7-   00          BRK
50A8-   00          BRK
50A9-   00          BRK
50AA-   00          BRK
50AB-   00          BRK
50AC-   00          BRK
50AD-   00          BRK
50AE-   00          BRK
50AF-   00          BRK
50B0-   00          BRK
50B1-   00          BRK
50B2-   00          BRK
50B3-   00          BRK
50B4-   00          BRK
50B5-   00          BRK
50B6-   00          BRK
50B7-   00          BRK
50B8-   00          BRK
50B9-   00          BRK
50BA-   00          BRK
50BB-   01 02       ORA   ($02,X)
50BD-   03          ???
50BE-   04 06       TSB   $06
50C0-   09 0D       ORA   #$0D
50C2-   12 18       ORA   ($18)
50C4-   24 36       BIT   $36
50C6-   49 07       EOR   #$07
50C8-   11 0E       ORA   ($0E),Y
50CA-   A4 2D       LDY   $2D
50CC-   A1 2D       LDA   ($2D,X)
50CE-   0C 9C 28    TSB   $289C
50D1-   9C 2B 0E    STZ   $0E2B
50D4-   69 68       ADC   #$68
50D6-   0C 9F 26    TSB   $269F
50D9-   9A          TXS
50DA-   23          ???
50DB-   93          ???
50DC-   1F          ???
50DD-   0E 9C 21    ASL   $219C
50E0-   9C 23 0C    STZ   $0C23
50E3-   9C 24 A4    STZ   $A424
50E6-   21 0E       AND   ($0E,X)
50E8-   9C 24 9A    STZ   $9A24
50EB-   23          ???
50EC-   98          TYA
50ED-   21 9A       AND   ($9A,X)
50EF-   24 0C       BIT   $0C
50F1-   A3          ???
50F2-   1C A8 20    TRB   $20A8
50F5-   0E AC 1C    ASL   $1CAC
50F8-   AC 21 64    LDY   $6421
50FB-   68          PLA
50FC-   A1 2D       LDA   ($2D,X)
50FE-   A1 2D       LDA   ($2D,X)
5100-   A3          ???
5101-   2F          ???
5102-   A3          ???
5103-   2F          ???
5104-   A4 30       LDY   $30
5106-   A4 30       LDY   $30
5108-   A8          TAY
5109-   2D A8 2D    AND   $2DA8
510C-   A6 2C       LDX   $2C
510E-   A6 2C       LDX   $2C
5110-   A6 2D       LDX   $2D
5112-   A6 2D       LDX   $2D
5114-   A8          TAY
5115-   2F          ???
5116-   A8          TAY
5117-   2F          ???
5118-   A3          ???
5119-   2B          ???
511A-   A3          ???
511B-   2B          ???
511C-   0C 61 0E    TSB   $0E61
511F-   68          PLA
5120-   68          PLA
5121-   68          PLA
5122-   68          PLA
5123-   0C A4 21    TSB   $21A4
5126-   0E 9C 23    ASL   $239C
5129-   9C 23 9C    STZ   $9C23
512C-   23          ???
512D-   9C 23 0A    STZ   $0A23
5130-   9C 23 0E    STZ   $0E23
5133-   AD 21 AD    LDA   $AD21
5136-   21 A4       AND   ($A4,X)
5138-   21 A4       AND   ($A4,X)
513A-   21 AF       AND   ($AF,X)
513C-   21 AF       AND   ($AF,X)
513E-   21 A4       AND   ($A4,X)
5140-   21 A4       AND   ($A4,X)
5142-   21 B0       AND   ($B0,X)
5144-   28          PLP
5145-   B0 28       BCS   $516F
5147-   AB          ???
5148-   28          PLP
5149-   AB          ???
514A-   28          PLP
514B-   AD 23 AD    LDA   $AD23
514E-   23          ???
514F-   63          ???
5150-   63          ???
5151-   AF          ???
5152-   21 A4       AND   ($A4,X)
5154-   21 AD       AND   ($AD,X)
5156-   21 A4       AND   ($A4,X)
5158-   21 AB       AND   ($AB,X)
515A-   21 A4       AND   ($A4,X)
515C-   21 A9       AND   ($A9,X)
515E-   21 A4       AND   ($A4,X)
5160-   21 A8       AND   ($A8,X)
5162-   1D A4 1D    ORA   $1DA4,X
5165-   A4 1D       LDY   $1D
5167-   A4 1D       LDY   $1D
5169-   5C          ???
516A-   A0 1C       LDY   #$1C
516C-   A0 1C       LDY   #$1C
516E-   A0 1C       LDY   #$1C
5170-   55 55       EOR   $55,X
5172-   A1 15       LDA   ($15,X)
5174-   A1 15       LDA   ($15,X)
5176-   A4 15       LDY   $15
5178-   A4 15       LDY   $15
517A-   A8          TAY
517B-   15 55       ORA   $55,X
517D-   A9 15       LDA   #$15
517F-   A9 15       LDA   #$15
5181-   A9 15       LDA   #$15
5183-   A9 15       LDA   #$15
5185-   A8          TAY
5186-   15 A8       ORA   $A8,X
5188-   15 A8       ORA   $A8,X
518A-   15 A8       ORA   $A8,X
518C-   15 AC       ORA   $AC,X
518E-   1C AC 1C    TRB   $1CAC
5191-   AD 1C AD    LDA   $AD1C
5194-   1C AF 1C    TRB   $1CAF
5197-   AF          ???
5198-   1C 5C AD    TRB   $AD5C
519B-   1C AC 1C    TRB   $1CAC
519E-   AC 1C 5C    LDY   $5C1C
51A1-   5C          ???
51A2-   5C          ???
51A3-   5C          ???
51A4-   0C AD 21    TSB   $21AD
51A7-   A8          TAY
51A8-   1C A1 15    TRB   $15A1
51AB-   0E 63 64    ASL   $6463
51AE-   0C A1 26    TSB   $26A1
51B1-   55 A1       EOR   $A1,X
51B3-   24 55       BIT   $55
51B5-   9C 23 0E    STZ   $0E23
51B8-   68          PLA
51B9-   68          PLA
51BA-   0C 9C 23    TSB   $239C
51BD-   0E 68 68    ASL   $6868
51C0-   0C 9C 23    TSB   $239C
51C3-   0E 68 66    ASL   $6668
51C6-   0C 64 63    TSB   $6364
51C9-   61 0E       ADC   ($0E,X)
51CB-   64 68       STZ   $68
51CD-   A1 2D       LDA   ($2D,X)
51CF-   A1 2D       LDA   ($2D,X)
51D1-   A3          ???
51D2-   2F          ???
51D3-   A3          ???
51D4-   2F          ???
51D5-   A4 30       LDY   $30
51D7-   A4 30       LDY   $30
51D9-   A8          TAY
51DA-   2D A8 2D    AND   $2DA8
51DD-   A6 2C       LDX   $2C
51DF-   A6 2C       LDX   $2C
51E1-   A6 2D       LDX   $2D
51E3-   A6 2D       LDX   $2D
51E5-   A8          TAY
51E6-   2F          ???
51E7-   A8          TAY
51E8-   2F          ???
51E9-   A3          ???
51EA-   2B          ???
51EB-   A3          ???
51EC-   2B          ???
51ED-   0C 61 0E    TSB   $0E61
51F0-   6D 69 0C    ADC   $0C69
51F3-   A1 28       LDA   ($28,X)
51F5-   A0 24       LDY   #$24
51F7-   02          ???
51F8-   C9 50       CMP   #$50
```