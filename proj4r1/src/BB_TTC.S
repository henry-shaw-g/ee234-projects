/*
	module: BB_TTC (Blackboard Triple Time Counter) - uh handles the TTC ig
	note: only uses first TTC module (TTC0)
	author: Henry Shaw
	version: 0.2
*/

.text

.global ttc0_config_intvpoll
.global ttc0_check_intv
.global ttc0_set_intv
.global ttc0_set_prescale

@ note: each of the 3 timers has respective fields offset by 0-2 words from address for first timer
@ (except for match values because 3 matchers per timer)
.equ TTC0_BASE, 	0x0f8001000
.equ TTC_CLK_CTRL,	0x00			@ below are offsets from ttc0 base (or ttc1 for some insane reason later)
.equ TTC_CNT_CTRL,  0x0c
.equ TTC_CNT_VAL,	0x18
.equ TTC_INT_VAL,	0x24
.equ TTC_MATCH_VAL,	0x30
.equ TTC_ISR,		0x54
.equ TTC_IER,		0x60

@ description: configure a TTC timer for interval polling
@ inputs: r0 - the timer to use [0, 2], r1 - prescale value, r2 - interval value
@ outputs: r0 - preserved
@ note: choosing a timer that is not [0, 2] will for sure break things
ttc0_config_intvpoll:
	push {r4, r5, r6}

	ldr r4, =TTC0_BASE

	add r5, r4, #TTC_CLK_CTRL
	lsl r6, r1, #0x01 	@ position prescale bits
	orr r6, r6, #0x01	@ enable prescale
	and r6, r6, #0x1f	@ use internal clock and set some other stuff to zero ...?
	strb r6, [r5, r0, lsl #2]

	add r5, r4, #TTC_CNT_CTRL
	mov r6, #0x22		@ use interval mode only?
	strb r6, [r5, r0, lsl #2]

	add r5, r4, #TTC_INT_VAL
	str r2, [r5, r0, lsl #2]

	add r5, r4, #TTC_IER
	mov r6, #0xff		@ idk, might use all of them later ...?
	str r6, [r5, r0, lsl #2]

	pop {r4, r5, r6}
	bx lr

@ inputs: r0 - the timer to check
@ outputs: r0 - 1 if interval was reached, 0 if not
@ note: dont have multiple systems attempting to check the same interval since the status register gets cleared upon read
ttc0_check_intv:
	ldr r1, =(TTC0_BASE + TTC_ISR)
	ldrb r2, [r1, r0, lsl #2]	@ load from TTC_0BASE + TTC_ISR + r0 * 4 (only does a byte load if that is less strain on the bus or something ...?)
	and r0, r2, #1				@ only consider 0th I bit
	bx lr

@ inputs: r0 - the timer to use, r1 - interval value
@ outputs: r0:r1 - preserved
ttc0_set_intv:
	ldr r2, =(TTC0_BASE + TTC_ISR)
	str r1, [r2, r0, lsl #2]
	bx lr

@ inputs: r0 - the timer to use, r1 - prescale value
ttc0_set_prescale:
	ldr r2, =(TTC0_BASE + TTC_CLK_CTRL)
	ldr r3, [r2, r0, lsl #2]
	and r3, r3, #0x61			@ only preserve bits 0, 6, 5 (beyond 6 are unused according to docs)
	orr r3, r1, lsl #1
	str r3, [r2, r0, lsl #2]
	bx lr
.end
