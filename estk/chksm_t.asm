; Introduction
; This file defines the 16 bit internet checksum
;----------------------------------------------------------------
;estkt_chksum_init --- part of api
;estkt_chksum_calculate --- part of api
;estkt_chksum_finalize --- part of api
;estkt_chksum_common --- for internal use only - a private function

; Variable/ Data locations used
; register a, flag affected : c
; estkt_chksum_L byte, ip_estkt_chksum_H byte, estkt_chksum_odd flag
;----------------------------------------------------------------

; Prepares the checksum state to start from scratch.
; by initializing the data structures used.
;----------------------------------------------------------------
estkt_chksum_init:
	mov	estkt_chksum_L,	#00h
	mov	estkt_chksum_H,	#00h
	setb	estkt_chksum_odd			; the first byte is odd
	ret
;----------------------------------------------------------------

; This procedure takes care of the even or odd length streams
;----------------------------------------------------------------
estkt_chksum_finalize:
	jb	estkt_chksum_odd, estkt_chksum_finalize_ret
	call	estkt_chksum_common	; calls estkt_chksum_common when num of bytes was odd
estkt_chksum_finalize_ret:
	xrl	estkt_chksum_L,	#FFh
	xrl	estkt_chksum_H,	#FFh
	ret
;----------------------------------------------------------------

; The main checksum routine that incrementaly calcuates the checksum
; given one byte at a time
;----------------------------------------------------------------
estkt_chksum_calculate:
	clr	c ; clear the carry flag
	jnb	estkt_chksum_odd,	estkt_chksum_even_byte
	mov	estkt_chksum_buff,	a
	clr	estkt_chksum_odd ; next byte will be even
	ret
estkt_chksum_even_byte:
	add	a,	estkt_chksum_L
	mov	estkt_chksum_L,	a
	call	estkt_chksum_common
	setb	estkt_chksum_odd	; next byte will be odd
	ret
;----------------------------------------------------------------

; A common routine that adds the higher byte with the buffer byte,
; and propogates the carry back if it happens.
;----------------------------------------------------------------
estkt_chksum_common:
	mov	a,	estkt_chksum_buff
	addc	a,	estkt_chksum_H
	mov	estkt_chksum_H,	a
	jnc	estkt_chksum_common_ret
	mov	a,	estkt_chksum_L
	addc	a,	#00h
	mov	estkt_chksum_L,	a
	jnc	estkt_chksum_common_ret
	inc	estkt_chksum_H
estkt_chksum_common_ret:
	ret
;----------------------------------------------------------------
