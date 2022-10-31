; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                Run For It               
; Map Viewer
; Michaelangel007
; =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

TEST = 0

; Usage:
;   Start AppleWin
;   Start "Run For It"
;   Select Keyboard
;   Start a game
;   <F7>
;   SYM GameLoop = 8A1
;   BPX GameLoop
;   G
;   E0A:4C 46 01 // 8D 10 C0
;   BLOAD "mapviewer",100
;   G
;  Press TAB to exit map viewer

	DO TEST
			ORG $300	;
	ELSE
			ORG $100	; Yes, the stack
	FIN

; Keyboard
KEY_DOWN	EQU $8A	; Ctrl-J
KEY_LEFT	EQU $88	; Ctrl-H
KEY_RIGHT	EQU $95	; Ctrl-U
KEY_UP		EQU $8B	; Ctrl-K
KEY_TAB		EQU $89 ; Ctrk-I Enter/Exit map mode

; I/O
KEYBOARD	EQU $C000
KEYSTROBE	EQU $C010

; ROM 
COUT		EQU $FDED	; putchar( A-reg )
CROUT		EQU $FD8E	; putchar( '\n' )
PRHEX		EQU $FDE3

; Game Variables
PlayerRoom	EQU $A0
PlayerZone	EQU $A1
Temp		EQU $FF

; Game Functions
	DO TEST

Init		LDX #0
			STX PlayerRoom
			STX PlayerZone
			BEQ NextRoom

NewRoom		LDA PlayerRoom
			PHA
			AND #$3C		; Using original clamp value @0F94
			LSR
			LSR
			STA Temp
			LDA PlayerZone
			ASL
			ADC PlayerZone
			ADC Temp
			ADC #'A' + $80	; $C1
			JSR COUT
			PLA
			AND #3
			CLC
			ADC #'1' + $80	; $B1 = one based, not zero based
			JSR COUT
			JMP CROUT
ReadZone
			LDA #'-' + $80
			JSR COUT
			LDA #'z' + $80
			JSR COUT
			LDA PlayerZone
			JSR PRHEX
			LDA #'-' + $80
			JSR COUT
			JMP CROUT
DrawLifts
DrawMobsOnly
PageFlip
PatchExit
ResetMobs
			RTS
	ELSE
DrawLifts		EQU $13FE
;DrawMobs		EQU $09E0
DrawMobsOnly	EQU $09F9	; Normal entry point @09E0 but skip player via 9F9
NewRoom			EQU $0F12
PageFlip		EQU	$1A49
PatchExit		EQU $0E0D
ReadZone		EQU $15CA
ResetMobs		EQU $10A0
	FIN

UpdateRoomNum
			STA AddSub+1
			LDA PlayerRoom
			CLC
AddSub		ADC #00
			TAX				; Psuedo-push player room
			STA PlayerRoom

; Level / Room / Zone
; Lev R Z   Lev R Z   Lev R Z   Lev R Z   Lev R Z   Lev R Z   Binary
;  A1 0 0    D1 0 1    G1 0 2    J1 0 3    M1 0 4    P1 0 5     0000
;  A2 1 0    D2 1 1    G2 1 2    J2 1 3    M2 1 4    P2 1 5     0001
;  A3 2 0    D3 2 1    G3 2 2    J3 2 3    M3 2 4    P3 2 5     0010
;  A4 3 0    D4 3 1    G4 3 2    J4 3 3    M4 3 4    P4 3 5     0011
;  B1 4 0    E1 4 1    H1 4 2    K1 4 3    N1 4 4    Q1 4 5     0100
;  B2 5 0    E2 5 1    H2 5 2    K2 5 3    N2 5 4    Q2 5 5     0101
;  B3 6 0    E3 6 1    H3 6 2    K3 6 3    N3 6 4    Q3 6 5     0110
;  B4 7 0    E4 7 1    H4 7 2    K4 7 3    N4 7 4    Q4 7 5     0111
;  C1 8 0    F1 8 1    I1 8 2    L1 8 3    O1 8 4    R1 8 5     1000
;  C2 9 0    F2 9 1    I2 9 2    L2 9 3    O2 9 4    R2 9 5     1001
;  C3 A 0    F3 A 1    I3 A 2    L3 A 3    O3 A 4    R3 A 5     1010
;  C4 B 0    F4 B 1    I4 B 2    L4 B 3    O4 B 4    R4 B 5     1011

UnderOver	BMI Underflow		; Q1. Room < 0 ?
			CMP #$0C			; Clamp 
			BCC NextRoom		; Q2. Room < $0C ?
Overflow	    AND #3			; A2. No
			    STA PlayerRoom
			    LDY PlayerZone
			    INY
			    CPY #6			; Q3. Zone < STU ?
			    BNE UpdateZone	; A4. Yes
			    LDY #0			; A4. No, Zone: R# -> A#
			    BEQ UpdateZone	; Always
Underflow	CLC					; 0-4=FC   1-4=FD   2-4=FE   3-4=FF
			    ADC #$0C		;  +C=08    +C=09    +C=0A    +C=0B
			    AND #%00001111
			    STA PlayerRoom
			    DEC PlayerZone
			    BPL ChangeZone
			    LDY #5			; Zone: A# -> R#
UpdateZone	STY PlayerZone
ChangeZone	JSR ReadZone

NextRoom	JSR ResetMobs
			JSR NewRoom
			JSR DrawLifts
			JSR DrawMobsOnly

			STA $C054			; For saving HGR1 if 5E:20 ; Alt. JSR PageFlip
MapViewer
			LDA KEYBOARD
			BPL MapViewer
Patch
			STA KEYSTROBE
CheckUp
			CMP #KEY_UP
			BNE CheckDown
			LDA #$04			; +4
			BNE UpdateRoomNum
CheckDown
			CMP #KEY_DOWN
			BNE CheckLeft
			LDA #$100-4			; -4
			BNE UpdateRoomNum
CheckLeft
			CMP #KEY_LEFT
			BNE CheckRight
			LDA #$100-1			; -1
			BNE UpdateRoomNum
		
CheckRight
			CMP #KEY_RIGHT
			BNE CheckExit
			LDA #1				; +1
			BNE UpdateRoomNum
CheckExit
			CMP #KEY_TAB	; C=?
			BNE MapViewer
			LDA bActive
			EOR #$01
			STA bActive
			BNE MapViewer
PatchDone
			JMP PatchExit	; Interjection done

bActive		DB 1
