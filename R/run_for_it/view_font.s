; Run For It
; Glyph Viewer
; Michaelangel007

zCol    = $CA
zCharX  = $CF	; Used by PutChar
zCharY  = $D0	; Used by PutChar
zCharA  = $D1	; Which glyph to draw

Font    = $918E	; Data
PutChar = $0FB1 ; Code

			ORG $100
ViewGlyphs
			LDY #0
			STY zCharY
			LDA #$A0
			STA zCharA
NextRow			LDA #16		; 8 glyphs/row
				STA zCol
				LDX #0
				STX zCharX
NextGlyph			LDA zCharA
					CMP #$DB	; Last glyph is #$DA 'Z'
					BEQ Done
					JSR PutChar
					INC zCharA
					DEC zCol
					LDA zCol
				BNE NextGlyph
			LDA zCharY
			CLC
			ADC #$10
			STA zCharY
			BPL NextRow
Done
			RTS
