; Initializations for the estack
;----------------------------------------------------------------
; This file holds the initialization code for the hole stack
; There are many initializations possible
;----------------------------------------------------------------

; List of routines here
;----------------------------------------------------------------
; estk_init
; estk_init_halfduplex
; estk_init_rec_only	
; estk_init_tran_only
; estkr_init	--- not to be called by user
; estkt_init	--- not to be called by user
;----------------------------------------------------------------

; Function that gives the maximum power to the api
; Initialization that enables a full-duplex stack
;----------------------------------------------------------------
estk_init:
	mov	estk_ctrl,	#00h
	setb	estk_on			; enable estack
	
	call	estkt_init
	call	estkr_init

	ret
;----------------------------------------------------------------
;----------------------------------------------------------------
estk_init_rec_only:	
	mov	estk_ctrl,	#00h
	setb	estk_on			; enable estack
	call	estkr_init
	ret
;----------------------------------------------------------------
;----------------------------------------------------------------
estk_init_tran_only:	
	mov	estk_ctrl,	#00h
	setb	estk_on			; enable estack
	call	estkt_init
	ret
;----------------------------------------------------------------

;----------------------------------------------------------------
estk_init_halfduplex:	
	mov	estk_ctrl,	#00h
	setb	estk_on			; enable estack
	setb	estk_halfdup

	call	estkt_init
	call	estkr_init
	
	clr	estkt_on	; switch off transmission (it is switched on only when required)
	ret

estk_disable:
	clr	estk_on
	ret
;----------------------------------------------------------------

; initialize the receive module
; this initialization should be called only once (at the very start)
;----------------------------------------------------------------
estkr_init:
	setb	estkr_on		; enable estack receive
	mov	estkr_data_ptr,	#estkr_data_ptr_default
	mov	estkr_data_len,	#estkr_data_len_max
	mov	estkr_errs,	#00h	; set to no initial receiving errors
	mov	estkr_state,	#00h	; set to default states
	setb	estkr_sync_slip		; skip bytes untill a slip end is received
	ret
;----------------------------------------------------------------

; initialize the transmit module
; this initialization should be called only once (at the very start)
;----------------------------------------------------------------
estkt_init:
	setb	estkt_on		; enable estack	transmit
	mov	estkt_state,	#00h
	mov	estkt_ip_id,	#00h	; the id of first IP packet starts from 1
	ret
;----------------------------------------------------------------

