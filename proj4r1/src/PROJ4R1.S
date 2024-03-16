/*
	program: PROJ4R1 - sends a single bit to the vitis terminal emulator (hopefully ...)
	author: Henry Shaw
*/

.text

.extern uart1_config
.extern uart1_put_char
.extern dbg_led_en
.extern dbg_led_12b
.extern ttc0_config_intvpoll
.extern ttc0_check_intv

.global main

main:
	mov r9, #1		@ status LED states

	mov r0, r9
	bl dbg_led_12b

	mov r0, #0		@ timer used
	mov r1, #15		@ prescale (ttc clock is 100Mhz / 2^16)
	mov r2, #763	@ this should get down to about 2 Hz
	bl ttc0_config_intvpoll

	bl uart1_config

poop_loop:
poop_stink_loop:
	mov r0, #0
	bl ttc0_check_intv
	tst r0, #1
	beq poop_stink_loop

	mov r0, #0x48	@ send an H to the terminal
	bl uart1_put_char

	eor r9, r9, #2	@ toggle second LED
	mov r0, r9
	bl dbg_led_12b
	b poop_loop

end_loop: b end_loop

.end
