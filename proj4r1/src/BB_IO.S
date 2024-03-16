/*
	module: BBIO (blackboard IO) utility module for using the IO features of the RealDigital blackboard from PS
	author: Henry Shaw
	version: 0.4
	notes:
		Im pretty sure debouncing the push-buttons in software is useless
*/

.text

.global main
.global dbg_led_en
.global dbg_led_12b
.global ld_sw_data
.global ld_pb_data
.global update_pb_db
.global check_pb_db
.global get_pb_rise
.global sd7_en
.global sd7_write

.equ LED_CTL,	0x41210000
.equ SW_DATA,	0x41220000
.equ PB_DATA, 	0x41200000
.equ SD7_CTRL, 	0x43c10000
.equ SD7_DATA, 	0x43c10004

.equ PB_DB_THRESHOLD, 0x0ff @ 256 and sign bit (always keep that first 8 there mk)

@ desc: just turns on some pattern of LEDs to check that board is running program
dbg_led_en:
	ldr r0, =LED_CTL
	mov r1, #0x55
	str r1, [r0]
	bx lr

@desc: displays 12 bits of argument in leds (useful for real time displaying of a reg or something
@inputs: r0 - the data you would like to display
@outputs: preserves all registers
dbg_led_12b:
	push {r1}
	ldr r1, =LED_CTL
	str r0, [r1]
	pop {r1}
	bx lr

@ returns r0 - the switch state
ld_sw_data:
	ldr r0, =SW_DATA
	ldr r0, [r0]
	bx lr

@ returns r0 - the pushbutton state, r2:3 preserved
ld_pb_data:
	ldr r0, =PB_DATA
	ldr r0, [r0]
	bx lr

@ inputs: r0 - pushbutton state, r1 - *[button db data]
@ outputs: ...
@ note: when a button is counting, its sign bit is set to 0 and then it is incremented
@	so that overflow can automatically be handled
update_pb_db:
	@ update first button
	ldrsh r2, [r1]
	tst r0, #1
	moveq r2, #0
	addnes r2, #1
	movvs r2, #0xffff
	strh r2, [r1]

	@ TODO: implement the other buttons if i need them ...

	bx lr

@ inputs: r0 - pushbutton state, r1 - *[button db state]
@ outputs: r0 - pbs post db, r1:r3 - garbage
check_pb_db:
	ldr r3, =PB_DB_THRESHOLD

	@ check first button
	ldrh r2, [r1]
	cmp r2, r3
	mov r1, #0
	orrge r1, r1, #1

	@ TODO: implement the other buttons as needed

	mov r0, r1
	bx lr

@ inputs: r0 - present button state, r1 - previous button state
@ outputs: r0 - buttons that were presed in this cycle
@ note: you need to store the button states yourself ...
get_pb_rise:
	mvn r1, r1
	and r0, r0, r1
	bx lr


@ returns: r0 - garbage, r1 - garbage
sd7_en:
	ldr r0, =SD7_CTRL
	mov r1, #0x1
	str r1, [r0]
	bx lr

@ args: r0 - digit to be displayed (0-3), r1 - value to display on digit (0x0 - 0xf)
@ returns: [r0-r2] - garbage
@ todo: maybe bail if the digit value is too large ...
sd7_write:
	push {r3, r4}

	ldr r3, =SD7_DATA
	ldr r4, [r3]
	and r0, #3	@ only accept bottom 2 bits of r0
	lsl r0, r0, #3 	@ r0 *= 8
	mov r2, #0xf
	and r1, #0xf	@ only accept bottom 4
	lsl r1, r1, r0
	lsl r2, r2, r0
	mvn r2, r2
	and r4, r2		@ set digit bcd data to 0s
	orr r4, r1		@ set digit bcd data to value
	str r4, [r3]

	pop {r3, r4}
	bx lr

.end
