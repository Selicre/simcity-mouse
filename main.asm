org $0080B2
NMIOriginal:

org $00FC00
NMICustom:
	PEA.w NMICustomFar>>8
	PEA.w ((NMICustomFar<<8)&$FF00)+$20
	;NOP #4
	JMP NMIOriginal

org $00FFEA
	dw NMICustom


org $0FDB00
print pc
incsrc "mouse.asm"

print pc
NMICustomFar:
	PHX
	PHY
	SEP #$30
	JSR ReadControllers
	REP #$30
	PLY
	PLX
	RTI
