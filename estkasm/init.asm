;keydisp\asm\init.asm
;--------------------------------------------------------------------
;init
;init_timer0
;init_timer1
;init_uart
;init_delay_1sec
;--------------------------------------------------------------------

;--------------------------------------------------------------------
init_main:

	call	init_timer0		;for 1ms interrupt

	call	init_timer1		;for baud rate clock

	call	init_uart		;to receive a byte at a time

	setb	ea ; enable all interrupts

	ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;(89h)
;TMOD-->GATE, C/T, M1,	M0, GATE, C/T, M1, M0, T/C (timer1,timer0)
;init timer 0  for 1msec
;Takes 12 Machine cycles
init_timer0:			;2
	orl	tmod,#01h	;2	;t0 in 16 bit timer mode.
	mov	tl0,#66h	;2	;Init timer0 with count for 1msec.
	mov	th0,#0fch	;2	;count=0fc66h for 1msec.
	setb	tr0		;1	;start timer 0.
	setb	et0		;1	;enable timer 0 Interrupt.
	ret 			;2
;--------------------------------------------------------------------

;--------------------------------------------------------------------
init_timer1:
	orl	tmod,	#20h  		;t1 in 8 bit auto reload mode.
	mov     th1,	#0fdh       	;init. TH1 with count for
					;9600 baud (11.059MHz)
	setb    tr1                     ;Start timer 1 (baud rate)
	ret 
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Code to initialise serial port.
init_uart:
	mov     scon,#01000000b            ;Init. serial control ie mode 1 ( 8 bit uart)
					   ;8 bit UART mode(variable).
	clr     ri                         ;Clear Receive Interrupt
	clr	ti                         ;Clear Transmit Interrupt
	setb    ren                        ;enable receiver
	setb    es                  	   ;Enable serial interrupt
	ret
;--------------------------------------------------------------------
