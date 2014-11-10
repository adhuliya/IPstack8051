; SW asm\isr.asm
; estk_isr serial interrupt handling routine
;----------------------------------------------------------------
; An interrupt routine that handles incoming and outgoing byte
; streams through the stack.
; User has a choice to handle the incoming and outgoing byte using
; the stack or use his own custom handling of bytes. To custom
; handle the byte clear the bit variable 'estk_on' and call a routine
; from the space provided in lables ending with 'isr_custom'. You can
; also disable receive or transmit selectively by clearing the bit
; variables estkr_on and estkt_on respectively.
;----------------------------------------------------------------

estk_isr:
	push	a
	push	psw
;----RECEIVE-----------RECEIVE---------------------RECEIVE--------------
estkr_isr:
	jnb	ri,	estkt_isr
	jnb	estk_on,	estkr_isr_custom 	; if estack is disabled skip receiving by stack
	jnb	estkr_on,	estkr_isr_custom 	; if estack receive disabled, skip receiving by stack
	jb	estkr_buff_full,	estkr_isr_end	; if receive buff is full, drop the byte.	

	;clr	p1.0 		;delit
	call	estkr_iapi 	; a standard API to receive byte stream by stack

	;mov	p1,	estkr_errs	;delit
	ljmp	estkr_isr_end
estkr_isr_custom:
	; USER CODE GOES HERE 
	; Should call a function from here, or jump and retrun back to 'estkr_isr_end'
	; This space is to handle the incoming byte in a custom way.
	; Ensure that the exit point is always the label 'estkr_isr_end'
	
	; mov	p1,	sbuf
estkr_isr_end:
	clr	ri ; cleared to receive next byte
;----RECEIVE-----------RECEIVE---------------------RECEIVE--------------

;----TRANSMIT----------TRANSMIT--------------TRANSMIT-------------------
estkt_isr:
	jnb	ti, 	estkt_isr_ret
	clr	ti				; clear ti bit before writing the next byte to sbuf
	jnb	estk_on,	estkt_isr_custom
	jnb	estkt_on,	estkt_isr_custom
	jnb	estkt_buff_full,	estkt_isr_ret	; when buff is full, transmit.

	call 	estkt_iapi

	jmp	estkt_isr_ret
estkt_isr_custom:
	; USER CODE GOES HERE : User can disable the whole stack or the transmit and use
	; his own transmit functionality here.
	; mov	sbuf,	#'T'
estkt_isr_ret:
	pop	psw
	pop	a
	reti
;----TRANSMIT----------TRANSMIT--------------TRANSMIT-------------------
