/*
	module: UART
	description: provides functions for using the Zynq / Blackboard UART hardware
	author: Henry Shaw
	version: 0.2
*/

.equ UART0, 0xE0000000		@ probably wont use this but idky
.equ UART1, 0xE0001000

.equ UART_CR_OFFS, 			0x00
.equ UART_MR_OFFS,			0x04
.equ UART_BAUDGEN_OFFS,		0x18
.equ UART_BAUDRATED_OFFS,	0x34
.equ UART_SR_OFFS,			0x2c
.equ UART_FIFO_OFFS,		0x30

.equ BAUDGEN,				0x7c	@ configured for 115200 baud
.equ BAUD_RATE_D,			6

.text

.global uart1_reset
.global uart1_config
.global uart1_put_char
.global uart1_put_str


@ desc: forces reset on the uart1 controller, yields until the reset is confirmed complete
@ inputs: none
@ outputs: r0:r1 - garbage
uart1_reset:
	ldr r0, =(UART1 + UART_CR_OFFS)
	ldr r1, [r0]
	orr r1, #3
	str r1, [r0]
uart1_reset_loop:
	ldr r1, [r0]
	tst r1, #3
	bne uart1_reset_loop
	bx lr

@ desc: does a default config for the uart controller for interfacing with the vitis terminal ig ...
@ note: atm, most of the configurations are hard coded in he
uart1_config:
	push {lr}

	bl uart1_reset

	ldr r0, =(UART1 + UART_CR_OFFS)
	mov r1, #0x14		@ set tx en, rx en bits
	str r1, [r0]

	ldr r0, =(UART1 + UART_MR_OFFS)
	mov r1, #0x038		@ set channel mode = normal, stop? bits = 1, parity = none, ch. length = 8 bits, clock = master (100Mhz)

	ldr r0, =(UART1 + UART_BAUDGEN_OFFS)
	ldr r1, =BAUDGEN
	str r1, [r0]

	ldr r0, =(UART1 + UART_BAUDRATED_OFFS)
	ldr r1, =BAUD_RATE_D
	str r1, [r0]

	pop {lr}
	bx lr

@ desc: synchronously sends out a single char on the UART tx line
@ note: waits until FIFO is completely empty before putting char, blocks processor during that time
@ args: r0, the byte to send
uart1_put_char:
	@ first wait for fifo to empty
	ldr r1, =(UART1 + UART_SR_OFFS)
uart1_put_char_loop:
	ldr r2, [r1]
	tst r2, #2	@ check RFS status
	beq uart1_put_char_loop

	@ put char into fifo
	ldr r1, =(UART1 + UART_FIFO_OFFS)
	strb r0, [r1]

	bx lr

@desc: synchronously sends out a null-terminated string on UART tx line
@ input: r0 - ptr to string
@ output: r0:r3 - GARBAGE
uart1_put_str:
	push {r4}

	ldr r1, =(UART1 + UART_SR_OFFS)
	ldr r4, =(UART1 + UART_FIFO_OFFS)

	uart1_put_str_loop0:
	ldrb r3, [r0], #1
	cmp r3, #0
	beq uart1_put_str_break

	uart1_put_str_loop1:
	ldr r2, [r1]
	tst r2, #2	@ check RFS status
	beq uart1_put_str_loop1

	@ put char into fifo
	strb r3, [r4]
	b uart1_put_str_loop0

	uart1_put_str_break:
	pop {r4}
	bx lr

.end
