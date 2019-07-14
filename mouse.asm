; Controller data format:
; $00, Nothing:    00000000 00000000 00000000 00000000
; $01, Joypad:	   byetUDLR axlr0000 11111111 11111111
; $02, Mouse:	   00000000 rlss0001 Yyyyyyyy Xxxxxxxx
; $03, SuperScope: fctp00on 11111111 11111111 11111111

base $7E1F00	; base of the stack
RAM_port2_controller_type: skip 1
RAM_port2_data_buf: skip 2
base $1EB
RAM_mouse_pos_x: skip 1
base $1ED
RAM_mouse_pos_y: skip 1
base off

ReadControllers:
	LDX #$00
--	LDY #$08
-	LDA $4017
	LSR
	ROL RAM_port2_data_buf,x
	DEY
	BNE -
	INX
	CPX #$02
	BNE --

	JSR DetectSnesMouse
	STA RAM_port2_controller_type
	BNE .mouse
	RTS

.mouse:
	LDA RAM_port2_data_buf+1 ; load the change in X direction
	; if the high bit is set, the mouse moved left
	BMI ++
; moved right:
	AND #$7F ; mask out the direction bit
	CLC : ADC RAM_mouse_pos_x
	BCC + ; no carry = didn't overflow, just store it
	LDA #$FF ; if overflowed, limit at rightmost pixel
+	STA RAM_mouse_pos_x
	BRA ..handle_y
; moved left:
++	AND #$7F
	EOR #$FF ; negate A - the INC is included in the SEC (since ADC=accum+data+carry)
	SEC : ADC RAM_mouse_pos_x ; add the pos thing
	; if it didn't overflow, the result was <0, so limit to left edge
	BCS + ; no carry = didn't overflow
	LDA #$00 ; underflowed, limit at leftmost pixel
+	STA RAM_mouse_pos_x

..handle_y:
	LDA RAM_port2_data_buf ; load change in Y direction
	; if high bit set, moved up
	BMI +++
; moved down:
	AND #$7F
	CLC : ADC RAM_mouse_pos_y
	BCS + ; if carry set, overflowed a byte - thus, limit to lowest position
	CMP.b #224
	BCC ++ ; if carry clear, A < 224, so no need to limit
+	LDA #223
++	STA RAM_mouse_pos_y
	RTS
; moved up:
+++	AND #$7F
	; similar to moving left
	EOR #$FF
	SEC : ADC RAM_mouse_pos_y
	BCS +
	LDA #$00
+	STA RAM_mouse_pos_y
	RTS


DetectSnesMouse:
	LDA $421A ;RAM_port2_data_buf+1
	ORA RAM_port2_data_buf
	BNE +
-	LDA #$00
	RTS
+	LDA $421A ;RAM_port1_data_buf+1,x
	AND #$0F
	CMP #$01
	BNE -
	LDA #$01
	RTS
