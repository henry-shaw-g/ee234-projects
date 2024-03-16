/*
	program: PROJ2R4 - send a string over uart to vitis terminal emulator
	author: Henry Shaw
*/

@ IMPORTS
.extern uart1_config
.extern uart1_put_char
.extern dbg_led_en
.extern dbg_led_12b
.extern ttc0_config_intvpoll
.extern ttc0_check_intv

@ EXPORTS
.global main

.data

name_str: .byte 0x68, 0x65, 0x6E, 0x72, 0x79, 0xA, 0x00

.text

main:
	mov r9, #5		@ status LED states

	mov r0, r9
	bl dbg_led_12b

	mov r0, #0		@ timer used
	mov r1, #15		@ prescale (ttc clock is 100Mhz / 2^16)
	mov r2, #763	@ this should get down to about 2 Hz
	bl ttc0_config_intvpoll

	bl uart1_config

send_loop0:
send_loop1:
	mov r0, #0
	bl ttc0_check_intv
	tst r0, #1
	beq send_loop1

	ldr r0, =name_str	@ send string to terminal
	bl uart1_put_str

	eor r9, r9, #6	@ toggle second LED
	mov r0, r9
	bl dbg_led_12b
	b send_loop0

done: b done		@ note: this should never be reached

.end
