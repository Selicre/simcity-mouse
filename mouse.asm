; Controller data format:
; $00, Nothing:    00000000 00000000 00000000 00000000
; $01, Joypad:     byetUDLR axlr0000 11111111 11111111
; $02, Mouse:      00000000 rlss0001 Yyyyyyyy Xxxxxxxx
; $03, SuperScope: fctp00on 11111111 11111111 11111111
; funky layout so active_controller_port can be used to index both the data_buf and controller_type

; $00 = port 1, $05 = port 2
; can be used as LDX RAM_active_controller_port : LDA RAM_port1_data_buf,x
base $7E1F00	; base of the stack
;RAM_active_controller_port: skip 1
;RAM_port1_controller_type: skip 1
;RAM_port1_data_buf: skip 4
RAM_port2_controller_type: skip 1
RAM_port2_data_buf: skip 4
RAM_mouse_pos_x: skip 1
RAM_mouse_pos_y: skip 1
base off

; Updates controller data. Leaves active controller port in X.
ReadControllers:
    ;LDA #$01  ;\ latch both controllers
    ;STA $4016 ;/
    ;NOP       ;\ not sure if this is necessary
    ;STZ $4016 ;/ (it's not)
    LDX #$00
--      LDY #$08
-           ;LDA $4016
            ;LSR ; low bit to C
            ;ROL RAM_port1_data_buf,x ; C into low bit
            LDA $4017
            LSR
            ROL RAM_port2_data_buf,x
        DEY
        BNE -
    INX
    CPX #$02
    BNE --

    ;STZ RAM_active_controller_port
    ;LDX #$00
    ;JSR DetectControllerType
    ;STA RAM_port1_controller_type
    ;BNE +
    ;LDX #$05
    ;STX RAM_active_controller_port
    ;JSR DetectControllerType
    ;STA RAM_port2_controller_type
;+   
    ; LDX RAM_active_controller_port
    ; X already has that number
    ;LDA RAM_port1_controller_type,x
    ;BEQ .return
    ;CMP #$02
    ;BEQ .mouse
    ;CMP #$03
    ;BEQ .superscope
    ; no need to specifically handle joypad - gamemode code can just use the first 2 bytes of the data1 buf
;.return:
    ;RTS


.mouse:
    LDA RAM_port2_data_buf+1 ; load the change in X direction
    ; if the high bit is set, the mouse moved left
    BMI ++
; moved right:
    AND #$7F ; mask out the direction bit
    CLC : ADC RAM_mouse_pos_x
    BCC + ; no carry = didn't overflow, just store it
    LDA #$FF ; if overflowed, limit at rightmost pixel
+   STA RAM_mouse_pos_x
    BRA ..handle_y
; moved left:
++  AND #$7F
    EOR #$FF ; negate A - the INC is included in the SEC (since ADC=accum+data+carry)
    SEC : ADC RAM_mouse_pos_x ; add the pos thing
    ; if it didn't overflow, the result was <0, so limit to left edge
    BCS + ; no carry = didn't overflow
    LDA #$00 ; underflowed, limit at leftmost pixel
+   STA RAM_mouse_pos_x

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
+   LDA #223
++  STA RAM_mouse_pos_y
    RTS
; moved up:
+++ AND #$7F
    ; similar to moving left
    EOR #$FF
    SEC : ADC RAM_mouse_pos_y
    BCS +
    LDA #$00
+   STA RAM_mouse_pos_y
    RTS

;.superscope:
;    RTS


;DetectControllerType:
;    LDA RAM_port2_data_buf+1
;    ORA RAM_port2_data_buf+2
;    BNE +
;    LDA #$00
;    RTS
;+   LDA RAM_port1_data_buf+1,x
;    AND #$0F
;    TAY
;    LDA .controller_type_tbl,y
;    RTS

;.controller_type_tbl:
;    db $01,$02,$00,$00
;    db $00,$00,$00,$00
;    db $00,$00,$00,$00
;    ;db $00,$00,$04,$03
;    db $00,$00,$00,$03
