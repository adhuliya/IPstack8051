; Introduction
; This file defines the 16 bit internet checksum
;----------------------------------------------------------------
; To use it, call estkr_chksum_init first
; then keep calling estkr_chksum_calculate by passing a byte in register a
; then call estkr_chksum_finalize to give the final checksum,
; at the prespecified locations given below.

;estkr_chksum_init --- part of api
;estkr_chksum_calculate --- part of api
;estkr_chksum_finalize --- part of api
;estkr_chksum_common --- for internal use only - a private function

; Variable/ Data locations used
; register a, flag affected : c
; estkr_chksum_L byte, ip_estkr_chksum_H byte, estkr_chksum_odd flag
;----------------------------------------------------------------

; Prepares the checksum state to start from scratch.
; by initializing the data structures used.
;	r2 = estkr_chksum_H
;	r3 = estkr_chksum_L
;	r4 = estkr_chksum_buff
;----------------------------------------------------------------
estkr_chksum_init:
	clr	a	;1,1
	mov	r2,	a	;1,1
	mov	r3,	a	;1,1
	setb	estkr_chksum_odd	;2,1		; the first byte is odd
	ret	;1,2
;----------------------------------------------------------------

; This procedure takes care of the even or odd length streams
;----------------------------------------------------------------
estkr_chksum_finalize:
	jb	estkr_chksum_odd, estkr_chksum_finalize_ret	;3,2
	call	estkr_chksum_common	;3,2 calls estkr_chksum_common when num of bytes was odd
estkr_chksum_finalize_ret:
	mov	a,	#FFh	;2,1
	xrl	a,	r2	;1,1
	mov	r2,	a	;1,1
	mov	a,	#FFh	;2,1
	xrl	a,	r3	;1,1
	mov	r3,	a	;1,1
	;xrl	1Bh,	#FFh	;3,2	1Bh is R3 in register bank 3
	;xrl	1Ah,	#FFh	;3,2	1Ah is R2 in register bank 3
	ret	;1,2
;----------------------------------------------------------------

; The main checksum routine that incrementaly calcuates the checksum
; given one byte at a time
;----------------------------------------------------------------
estkr_chksum_calculate:
	clr	c	;1,1 clear the carry flag
	jnb	estkr_chksum_odd,	estkr_chksum_even_byte	;3,2
	mov	r4,	a	;1,1
	clr	estkr_chksum_odd ;2,1 next byte will be even
	ret	;1,2
estkr_chksum_even_byte:
	add	a,	r3	;1,1
	mov	r3,	a	;1,1
	call	estkr_chksum_common	;3,2
	setb	estkr_chksum_odd	;2,1 next byte will be odd
	ret
;----------------------------------------------------------------

; A common routine that adds the higher byte with the buffer byte,
; and propogates the carry back if it happens.
;----------------------------------------------------------------
estkr_chksum_common:
	mov	a,	r4	;1,1
	addc	a,	r2	;1,1
	mov	r2,	a	;1,1
	jnc	estkr_chksum_common_ret	;2,2
	mov	a,	r3	;1,1
	addc	a,	#00h	;2,1
	mov	r3,	a	;1,1
	jnc	estkr_chksum_common_ret	;2,2
	inc	r2		;1,1
estkr_chksum_common_ret:
	ret			;1,2
;----------------------------------------------------------------
