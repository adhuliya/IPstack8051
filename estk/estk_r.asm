; This file defines all that is needed to implement a receiving of UDP packet
; successfully. Except for the variables and the main serial interrupt handling routine.

; estkr_iapi: this is a routine hence it should be called using 'call'
; estkr_iapi = estack's receive interface api
; r5 is a temporary location that holds current received byte
;-----estkr_iapi------------------estkr_iapi---------------------estkr_iapi--------------->
estkr_iapi:
	orl	psw,	#estkr_reg_bank	; 3,2 select register bank 3 (default)
	mov	a,	sbuf 	; first copy the byte to register A
	;clr	p1.1 		;delit

; SLIP filters out the relevant data by removing the byte stuffing
; slipr = slip receive
;-----SLIPr---------------SLIPr------------------SLIPr----------->
estkr_slip:
	cjne	a,	#estk_slip_end,	estkr_sync_slip_L
	ljmp	estkr_slip_start_init
	
estkr_sync_slip_L:
	jb	estkr_sync_slip,	estkr_iapi_ret ; skips all the data coming untill slip END is received

estkr_slip_chk_prev_esc:
	jb	estkr_slip_esc_set,	estkr_slip_chk_esc_end

estkr_slip_chk_esc:
	cjne	a,	#estk_slip_esc,	estkr_slip_data
	setb	estkr_slip_esc_set
	jmp	estkr_iapi_ret

estkr_slip_chk_esc_end:
	cjne	a, 	#estk_slip_esc_end,	estkr_slip_chk_esc_esc
	mov	a,	#estk_slip_end
	clr	estkr_slip_esc_set
	jmp	estkr_slip_data

estkr_slip_chk_esc_esc:
	cjne	a, 	#estk_slip_esc_esc,	estkr_slip_err
	mov	a,	#estk_slip_esc
	clr	estkr_slip_esc_set
	jmp	estkr_slip_data

estkr_slip_err:
	setb	estkr_sync_slip
	clr	estkr_receiving		;definitely not receiving a valid packet
	setb	estkr_err

estkr_slip_data:
	mov	r5,	a
	inc	estkr_byte_count
	; data is being transmitted in register A further to IP layer
;-----SLIPr---------------SLIPr------------------SLIPr-----------<

; If control comes here, then it is part of IP or UDP data.

; This section of code is to speed up the byte processing
; by jumping directly to the portions where the byte belongs.
; The portions could be IP header, UDP header or UDP data
; For a new packet the initial portion is IP header.
;-----IP_UDPr-------------IP_UDPr-----------------IP_UDPr-------->
	jnb	estkr_in_ip_h,	estkr_after_ip_h
	ljmp	estkr_ip_h
estkr_after_ip_h:
	jnb	estkr_in_udp_h,	estkr_after_udp_h
	ljmp	estkr_udp_h
estkr_after_udp_h:
	jnb	estkr_in_udp_data,	estkr_inconsistent
	ljmp	estkr_udp_data
estkr_inconsistent:
	setb	estkr_sync_slip
	clr	estkr_receiving		;definitely not receiving a valid packet
	setb	estkr_err
	clr	estkr_buff_full
;-----IP_UDPr-------------IP_UDPr-----------------IP_UDPr--------<

estkr_iapi_ret:
	ret
;-----estkr_iapi------------------estkr_iapi---------------------estkr_iapi---------------<

; Initialize to receive a new IP packet when received a SLIP END byte
;---------------------------------------------------------------->
estkr_slip_start_init:
	; clear all error flags and other relevant flags
	; and set appropriate flags for proper start state 
	
	; ip/udp stack initialization
	mov	estkr_errs,	#00h	; no errors initially Duh!
	mov	estkr_state,	#00h	; most initial states are zeros
	setb	estkr_in_ip_h 		; by default a fresh new data byte captured by SLIP should be in IP header

	mov	estkr_byte_count,	#00h 	; start counting from zero

	; Checksum initialization
	call	estkr_chksum_init		; initialize the checksum variables

	ljmp	estkr_iapi_ret
;----------------------------------------------------------------<

; Skeleton code to handle IP header bytes
; Maximum length IP packet = 255 bytes
;----------------------------------------------------------------
estkr_ip_h:
	call	estkr_chksum_calculate			; Cheksum Calculation
	mov	a, 	estkr_byte_count		; The current byte position

	cjne	a,	#01h, 	estkr_ip_h_b2
	ljmp	estkr_ip_h_process_b1
estkr_ip_h_b2:
estkr_ip_h_b3:
	cjne	a,	#03h,	estkr_ip_h_b4
	ljmp	estkr_ip_h_process_b3
estkr_ip_h_b4:
	cjne	a,	#04h,	estkr_ip_h_b5
	ljmp	estkr_ip_h_process_b4
estkr_ip_h_b5:
estkr_ip_h_b6:
estkr_ip_h_b7:
	cjne	a,	#07h,	estkr_ip_h_b8
	ljmp	estkr_ip_h_process_b7
estkr_ip_h_b8:
estkr_ip_h_b9:
estkr_ip_h_b10:
	cjne	a,	#0Ah,	estkr_ip_h_b11
	ljmp	estkr_ip_h_process_b10
estkr_ip_h_b11:
estkr_ip_h_b12:
estkr_ip_h_b13:
	cjne	a,	#0Dh,	estkr_ip_h_b14
	mov	estkr_ip_src_ipb1,	r5
	ljmp	estkr_ip_h_ret
estkr_ip_h_b14:
	cjne	a,	#0Eh,	estkr_ip_h_b15
	mov	estkr_ip_src_ipb2,	r5
	ljmp	estkr_ip_h_ret
estkr_ip_h_b15:
	cjne	a,	#0Fh,	estkr_ip_h_b16
	mov	estkr_ip_src_ipb3,	r5
	ljmp	estkr_ip_h_ret
estkr_ip_h_b16:
	cjne	a,	#10h,	estkr_ip_h_b17
	mov	estkr_ip_src_ipb4,	r5
	ljmp	estkr_ip_h_ret
estkr_ip_h_b17:		; mostly the first two to three bytes are netwrok or subnet address and they are mostly correct
estkr_ip_h_b18:		; hence their checking is skipped
estkr_ip_h_b19:
estkr_ip_h_b20:
	cjne	a,	#14h,	estkr_ip_h_blast
	mov	a,	r5
	cjne	a,	#estk_ip_b4,	estkr_ip_h_20_err
	mov	a,	estkr_byte_count
	ljmp	estkr_ip_h_process_blast
estkr_ip_h_20_err:
	setb	estkr_ip_addr_err
	ljmp	estkr_inconsistent
estkr_ip_h_blast:
	ljmp	estkr_ip_h_process_blast
	
estkr_ip_h_ret:
	ret
;----------------------------------------------------------------

; Handling each byte of IP header
;----------------------------------------------------------------
; Byte 1 : IP version and IP header length (4 bit each)
;----------------
estkr_ip_h_process_b1:
	mov	a,	r5
	anl	a,	#F0h
	cjne	a,	#40h,	estkr_ip_err_ver
	mov	a, 	r5
	anl	a,	#0Fh
	mov	b,	#04h
	mul	ab
	mov	estkr_ip_h_len,	a
	setb	estkr_receiving		; started receiving a valid packet
	ljmp	estkr_ip_h_ret
estkr_ip_err_ver:
	setb	estkr_ip_ver_err
	ljmp	estkr_inconsistent
;----------------

; Byte 3: The higher byte of length field. Should be zero in our case
;----------------
estkr_ip_h_process_b3:
	mov	a,	r5
	cjne	a,	#00h,	estkr_ip_err_len
	ljmp	estkr_ip_h_ret
estkr_ip_err_len:
	setb	estkr_ip_len_err
	ljmp	estkr_inconsistent

estkr_ip_h_process_b4:
	mov	estkr_ip_len, 	r5		; store the total length of the packet
	ljmp	estkr_ip_h_ret
;----------------

; Byte 7: Its higher nibble should be either 4 or 5 (ensures the packet is not a fragment)
;----------------
estkr_ip_h_process_b7:
	mov	a,	r5
	anl	a,	#E0h
	cjne	a,	#40h,	estkr_ip_err_frag
	ljmp	estkr_ip_h_ret
estkr_ip_err_frag:
	setb	estkr_ip_frag_err
	ljmp	estkr_inconsistent
;----------------

; Byte 10: The protocol should always be a UDP
;----------------
estkr_ip_h_process_b10:
	mov	a,	r5
	cjne	a,	#estk_udp_prot,	estkr_prot_err_L
	mov	estkr_prot,	a
	ljmp	estkr_ip_h_ret
estkr_prot_err_L:
	setb	estkr_ip_prot_err
	ljmp	estkr_inconsistent
;----------------
; From 20th ip header byte to the last byte of the optional field
; is handled here
;----------------
estkr_ip_h_process_blast:
	cjne	a,	estkr_ip_h_len,	estkr_ip_h_next
	call	estkr_chksum_finalize
	mov	a,	r2
	orl	a,	r3
	jz	estkr_ip_h_good
	setb	estkr_ip_chksm_err
	ljmp	estkr_inconsistent
estkr_ip_h_good:
	clr	estkr_in_ip_h
	setb	estkr_in_udp_h
	mov	estkr_byte_count,	#00h
	call	estkr_udp_psudo_chksum
estkr_ip_h_next:
	ljmp	estkr_ip_h_ret
;----------------
;----------------------------------------------------------------

; The UDP layer header skeleton code
; Reusing some variables used for IP header purposes:
; 1. estkr_byte_count - to again count the bytes from one
; 2. estkr_ip_h_len - to store the length of the udp packet
; 3. estkr_prot - to store lower byte of length field
;----------------------------------------------------------------
estkr_udp_h:
	call	estkr_chksum_calculate

	mov	a,	estkr_byte_count

estkr_udp_h_b1:
	cjne	a,	#01h,	estkr_udp_h_b2
	mov	estkr_ip_src_port_H,	r5	; store the source port address
	ret
estkr_udp_h_b2:
	cjne	a,	#02h,	estkr_udp_h_b3
	mov	estkr_ip_src_port_L,	r5	; store the source port address
	ret
estkr_udp_h_b3:					;skip
estkr_udp_h_b4:					;skip
estkr_udp_h_b5:
	cjne	a,	#05h,	estkr_udp_h_b6
	mov	a,	r5
	jnz	estkr_udp_h_len_err_L
	ret
estkr_udp_h_len_err_L:
	ljmp	estkr_inconsistent
estkr_udp_h_b6:
	cjne	a,	#06h,	estkr_udp_h_b7
	mov	a,	#00h
	call	estkr_chksum_calculate
	mov	a,	r5
	call	estkr_chksum_calculate
	clr	c
	mov	a,	r5
	subb	a,	#08h		; the number of data bytes in udp calculated
	mov	estkr_ip_h_len,	a
	ret
estkr_udp_h_b7:					;skip
estkr_udp_h_b8:
	cjne	a,	#08h,	estkr_udp_h_ret
	clr	estkr_in_udp_h
	setb	estkr_in_udp_data
	mov	estkr_byte_count,	#00h
	mov	r0,	estkr_data_ptr	; initialize the point to store data from
	ret
estkr_udp_h_err_L:
	ljmp	estkr_inconsistent

estkr_udp_h_ret:
	ret
;----------------------------------------------------------------

; The UDP data processing layer byte wise handling
;----------------------------------------------------------------
estkr_udp_data:
	call	estkr_chksum_calculate
	
	mov	a,	estkr_byte_count
	
	jb	estkr_data_stored,	estkr_udp_data_done
	cjne	a,	#estkr_data_len_max,	estkr_udp_data_store
	setb	estkr_data_stored	; maximum data possible is stored - buff full now
estkr_udp_data_store:
	mov	b,	a	; temporary store byte count in register b
	mov	a,	r5
	mov	@r0,	a	; store the data
	mov	a,	b	; recover byte count from register b
	inc	r0
estkr_udp_data_done:
	cjne	a,	estkr_ip_h_len,	estkr_udp_data_ret
	jnb	estkr_data_stored,	estkr_udp_data_less
	mov	estkr_data_len,	#estkr_data_len_max
	jmp	estkr_udp_data_chk

estkr_udp_data_less:
	mov	estkr_data_len,	estkr_ip_h_len

estkr_udp_data_chk:
	call	estkr_chksum_finalize
	mov	a,	r3
	orl	a,	r2
	jz	estkr_udp_good
	setb	estkr_udp_chksm_err	; udp checksum error
	ljmp	estkr_inconsistent
	
estkr_udp_good:
	setb	estkr_buff_full		; the buffer will be made unful by the application
	setb	estkr_sync_slip
	clr	estkr_receiving		; receiving stopped after a good packet
	
	jmp	estkr_udp_data_ret
	
estkr_udp_data_err_L:
	ljmp	estkr_inconsistent
estkr_udp_data_ret:
	ret
;----------------------------------------------------------------

; The UDP pseudo cheksum calculation
;----------------------------------------------------------------
estkr_udp_psudo_chksum:
	call	estkr_chksum_init

	mov	a,	estkr_ip_src_ipb1
	call	estkr_chksum_calculate
	mov	a,	estkr_ip_src_ipb2
	call	estkr_chksum_calculate
	mov	a,	estkr_ip_src_ipb3
	call	estkr_chksum_calculate
	mov	a,	estkr_ip_src_ipb4
	call	estkr_chksum_calculate

	mov	a,	#estk_ip_b1
	call	estkr_chksum_calculate
	mov	a,	#estk_ip_b2
	call	estkr_chksum_calculate
	mov	a,	#estk_ip_b3
	call	estkr_chksum_calculate
	mov	a,	#estk_ip_b4
	call	estkr_chksum_calculate

	mov	a,	#00h
	call	estkr_chksum_calculate
	
	mov	a,	estkr_prot
	call	estkr_chksum_calculate

	ret
;----------------------------------------------------------------
