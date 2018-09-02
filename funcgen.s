; Arduino Uno (atmega328p) based function generator
;
; License: GPL3
;
; TODO:
; * use pots to control the parameters, since i forgot to order pots :-)
; * finish implementing sawwave
; * fix reading over 1024 samples at sine routine
;
; pins 6-13 - 8bit DAC, 6 MSB, 13 LSB
; pin 5 high - square
; pin 4 high - sine
; pin 3 high - saw

.nolist
.include "./m328Pdef.inc"
.list

.def tmp = r16
.def freq = r17
.def duty = r18
.def ampl = r20
.def i = r21
.def val = r22

.org $0000 ; reset vector
rjmp Reset

.org $0012 ;timer2 overflow vector
rjmp TimerOverflow

SineTable1024:
.db 127, 128, 129, 130, 130, 131, 132, 133
.db 134, 134, 135, 136, 137, 137, 138, 139
.db 140, 140, 141, 142, 143, 144, 144, 145
.db 146, 147, 147, 148, 149, 150, 151, 151
.db 152, 153, 154, 154, 155, 156, 157, 157
.db 158, 159, 160, 160, 161, 162, 163, 163
.db 164, 165, 166, 166, 167, 168, 169, 169
.db 170, 171, 171, 172, 173, 174, 174, 175
.db 176, 177, 177, 178, 179, 179, 180, 181
.db 182, 182, 183, 184, 184, 185, 186, 186
.db 187, 188, 188, 189, 190, 190, 191, 192
.db 192, 193, 194, 194, 195, 196, 196, 197
.db 198, 198, 199, 200, 200, 201, 202, 202
.db 203, 203, 204, 205, 205, 206, 206, 207
.db 208, 208, 209, 209, 210, 211, 211, 212
.db 212, 213, 214, 214, 215, 215, 216, 216
.db 217, 217, 218, 218, 219, 220, 220, 221
.db 221, 222, 222, 223, 223, 224, 224, 225
.db 225, 226, 226, 227, 227, 228, 228, 229
.db 229, 229, 230, 230, 231, 231, 232, 232
.db 233, 233, 233, 234, 234, 235, 235, 235
.db 236, 236, 237, 237, 237, 238, 238, 239
.db 239, 239, 240, 240, 240, 241, 241, 241
.db 242, 242, 242, 243, 243, 243, 244, 244
.db 244, 244, 245, 245, 245, 246, 246, 246
.db 246, 247, 247, 247, 247, 248, 248, 248
.db 248, 248, 249, 249, 249, 249, 250, 250
.db 250, 250, 250, 250, 251, 251, 251, 251
.db 251, 251, 251, 252, 252, 252, 252, 252
.db 252, 252, 252, 253, 253, 253, 253, 253
.db 253, 253, 253, 253, 253, 253, 253, 253
.db 253, 253, 253, 253, 253, 253, 253, 254
.db 253, 253, 253, 253, 253, 253, 253, 253
.db 253, 253, 253, 253, 253, 253, 253, 253
.db 253, 253, 253, 253, 252, 252, 252, 252
.db 252, 252, 252, 252, 251, 251, 251, 251
.db 251, 251, 251, 250, 250, 250, 250, 250
.db 250, 249, 249, 249, 249, 248, 248, 248
.db 248, 248, 247, 247, 247, 247, 246, 246
.db 246, 246, 245, 245, 245, 244, 244, 244
.db 244, 243, 243, 243, 242, 242, 242, 241
.db 241, 241, 240, 240, 240, 239, 239, 239
.db 238, 238, 237, 237, 237, 236, 236, 235
.db 235, 235, 234, 234, 233, 233, 233, 232
.db 232, 231, 231, 230, 230, 229, 229, 229
.db 228, 228, 227, 227, 226, 226, 225, 225
.db 224, 224, 223, 223, 222, 222, 221, 221
.db 220, 220, 219, 218, 218, 217, 217, 216
.db 216, 215, 215, 214, 214, 213, 212, 212
.db 211, 211, 210, 209, 209, 208, 208, 207
.db 206, 206, 205, 205, 204, 203, 203, 202
.db 202, 201, 200, 200, 199, 198, 198, 197
.db 196, 196, 195, 194, 194, 193, 192, 192
.db 191, 190, 190, 189, 188, 188, 187, 186
.db 186, 185, 184, 184, 183, 182, 182, 181
.db 180, 179, 179, 178, 177, 177, 176, 175
.db 174, 174, 173, 172, 171, 171, 170, 169
.db 169, 168, 167, 166, 166, 165, 164, 163
.db 163, 162, 161, 160, 160, 159, 158, 157
.db 157, 156, 155, 154, 154, 153, 152, 151
.db 151, 150, 149, 148, 147, 147, 146, 145
.db 144, 144, 143, 142, 141, 140, 140, 139
.db 138, 137, 137, 136, 135, 134, 134, 133
.db 132, 131, 130, 130, 129, 128, 127, 126
.db 126, 125, 124, 123, 123, 122, 121, 120
.db 119, 119, 118, 117, 116, 116, 115, 114
.db 113, 113, 112, 111, 110, 109, 109, 108
.db 107, 106, 106, 105, 104, 103, 102, 102
.db 101, 100, 99, 99, 98, 97, 96, 96
.db 95, 94, 93, 93, 92, 91, 90, 90
.db 89, 88, 87, 87, 86, 85, 84, 84
.db 83, 82, 82, 81, 80, 79, 79, 78
.db 77, 76, 76, 75, 74, 74, 73, 72
.db 71, 71, 70, 69, 69, 68, 67, 67
.db 66, 65, 65, 64, 63, 63, 62, 61
.db 61, 60, 59, 59, 58, 57, 57, 56
.db 55, 55, 54, 53, 53, 52, 51, 51
.db 50, 50, 49, 48, 48, 47, 47, 46
.db 45, 45, 44, 44, 43, 42, 42, 41
.db 41, 40, 39, 39, 38, 38, 37, 37
.db 36, 36, 35, 35, 34, 33, 33, 32
.db 32, 31, 31, 30, 30, 29, 29, 28
.db 28, 27, 27, 26, 26, 25, 25, 24
.db 24, 24, 23, 23, 22, 22, 21, 21
.db 20, 20, 20, 19, 19, 18, 18, 18
.db 17, 17, 16, 16, 16, 15, 15, 14
.db 14, 14, 13, 13, 13, 12, 12, 12
.db 11, 11, 11, 10, 10, 10, 9, 9
.db 9, 9, 8, 8, 8, 7, 7, 7
.db 7, 6, 6, 6, 6, 5, 5, 5
.db 5, 5, 4, 4, 4, 4, 3, 3
.db 3, 3, 3, 3, 2, 2, 2, 2
.db 2, 2, 2, 1, 1, 1, 1, 1
.db 1, 1, 1, 0, 0, 0, 0, 0
.db 0, 0, 0, 0, 0, 0, 0, 0
.db 0, 0, 0, 0, 0, 0, 0, 0
.db 0, 0, 0, 0, 0, 0, 0, 0
.db 0, 0, 0, 0, 0, 0, 0, 0
.db 0, 0, 0, 0, 1, 1, 1, 1
.db 1, 1, 1, 1, 2, 2, 2, 2
.db 2, 2, 2, 3, 3, 3, 3, 3
.db 3, 4, 4, 4, 4, 5, 5, 5
.db 5, 5, 6, 6, 6, 6, 7, 7
.db 7, 7, 8, 8, 8, 9, 9, 9
.db 9, 10, 10, 10, 11, 11, 11, 12
.db 12, 12, 13, 13, 13, 14, 14, 14
.db 15, 15, 16, 16, 16, 17, 17, 18
.db 18, 18, 19, 19, 20, 20, 20, 21
.db 21, 22, 22, 23, 23, 24, 24, 24
.db 25, 25, 26, 26, 27, 27, 28, 28
.db 29, 29, 30, 30, 31, 31, 32, 32
.db 33, 33, 34, 35, 35, 36, 36, 37
.db 37, 38, 38, 39, 39, 40, 41, 41
.db 42, 42, 43, 44, 44, 45, 45, 46
.db 47, 47, 48, 48, 49, 50, 50, 51
.db 51, 52, 53, 53, 54, 55, 55, 56
.db 57, 57, 58, 59, 59, 60, 61, 61
.db 62, 63, 63, 64, 65, 65, 66, 67
.db 67, 68, 69, 69, 70, 71, 71, 72
.db 73, 74, 74, 75, 76, 76, 77, 78
.db 79, 79, 80, 81, 82, 82, 83, 84
.db 84, 85, 86, 87, 87, 88, 89, 90
.db 90, 91, 92, 93, 93, 94, 95, 96
.db 96, 97, 98, 99, 99, 100, 101, 102
.db 102, 103, 104, 105, 106, 106, 107, 108
.db 109, 109, 110, 111, 112, 113, 113, 114
.db 115, 116, 116, 117, 118, 119, 119, 120
.db 121, 122, 123, 123, 124, 125, 126, 127
.db 127, 127, 127, 127, 127, 127, 0, 0 ; reads over 1024, lazy temporary fix

; preload timer so we get ~100kHz
.macro TimerReset
	cli
	ldi tmp, 159
	sts TCNT2, tmp
	sei
.endmacro

; write value stored in register val into DAC
.macro ValueOut
	mov tmp, val
	ror tmp
	ror tmp
	andi tmp, 0b00111111
	out PORTB, tmp
	mov tmp, val
	swap tmp
	rol tmp
	rol tmp
	andi tmp, 0b11000000
	out PORTD, tmp
.endmacro

Reset: ; reset function -------------------------------------------------------
	; init stack pointer
	ldi tmp, low(RAMEND)
	out SPL, tmp
	ldi tmp, high(RAMEND)
	out SPH, tmp
	; init timer 2 with no prescaler and interrupt on overflow
	ldi tmp, 0b00000001  ;0b00000010
	sts TCCR2B, tmp
	ldi tmp, 0b00000001
	sts TIMSK2, tmp
	TimerReset
	; init arduino pins 13-7 for output
	ldi tmp, 0b00111111
	out DDRB, tmp
	ldi tmp, 0b11000000
	out DDRD, tmp
	; init parameters
	ldi duty, 128
	ldi freq, 64 ; 18 is 18 us
	clr i
	clr tmp
	clr XH
	clr XL

Loop: ; main loop -------------------------------------------------------------

	rjmp Loop

TimerOverflow: ; timer overflow function --------------------------------------
	rjmp Sine
	;rjmp Saw
	;rjmp Square
	reti

	; floating here until the pots i ordered arrive, untested
	; check pins and branch to appropriate function
	sbic PIND, 3
	brcs Square
	sbic PIND, 4
	brcs Sine
	sbic PIND, 5
	brcs Saw
	reti

Sine: ; sinewave gen ----------------------------------------------------------
	; increment value is freq. multiplier, TODO: tie it to a pot
	adiw X, 8 ; increment table index, 2 - 500hz, 16 - 2kHz  etc
	;adiw X, 63 ; we can just add twice to get horrible blocky sines at 50kHz
	; check if X == 1024
	cpi XH, 4
	brlo Under1024
	cpi XL, 5
	brlo Under1024
	; if is then zero it
	clr XH
	clr XL
Under1024:
	ldi ZH, high(SineTable1024 * 2) ; load pointers for table into Z
	ldi ZL, low(SineTable1024 * 2)
	add ZL, XL ; add offsets to pointers
	adc ZH, XH
	lpm val, Z ; load value into val
	ValueOut
	TimerReset
	reti ; sinewave finish

Saw: ; sawwave gen ------------------------------------------------------------
; TODO: finish implemnting it
	inc i
	cp i, freq
	brge SawNull ; if frequency == i, then zero value and index
	mov val, i
	rjmp SawFin
SawNull:
	clr val
	clr i
SawFin:
	ValueOut
	TimerReset
	reti ; sawwave gen finish

Square: ; squarewave gen begin ------------------------------------------------

	inc i
	cpi duty, 255 ;check if duty is 100%
	breq SquareHigh ; if 100% then output always high
	cp i, duty ; if duty > i, then wave HIGH, else wave LOW
	brlo SquareHigh
SquareLow:
	clr val ; set value as 0x00
	rjmp SqFin
SquareHigh:
	ser val ; set value as 0xff

SqFin: ; end wave by writing out and resetting timer
	ValueOut
	TimerReset
	reti ; squarewave gen finish

