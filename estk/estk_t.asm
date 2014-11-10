; contains the total transmit code
; 


; Start a new transmit - it is initiated by a call from application.
; The application should (prior to this call) copy all the relevant 
; data to the transmit buffers.
; It sends the first byte SLIP END to start transmitting
;----------------------------------------------------------------
estkt_start_slip:
	jnb	estkt_buff_full,	estkt_start_chk_halfdup	;3,2
	ret	;1,2	a tranmission is already going on
estkt_start_chk_halfdup:
	jnb	estk_halfdup,	estkt_not_halfdup_start
	setb	estkt_on	; switch on transmission
	clr	estkr_on	; switch off receiving (at whatever stage it was at)
estkt_not_halfdup_start:
	jb	estkt_on,	estkt_start_slip_LL		;3,2
	ret	;1,2
estkt_start_slip_LL:
	setb	estkt_buff_full		; locks the transmit buffer for use

	mov	estkt_state,	#00h
	setb	estkt_in_ip_h		; slip end char already being sent, next byte is of ip_h
	inc	estkt_ip_id		; increment the IP identifier
	mov	estkt_byte_count,	#00h

	push	a
	push	psw

	call	estkt_chksm_ip		; calculate the complete chksm for udp and ip 
	call	estkt_chksm_udp

	pop	psw
	pop	a

	clr	ti
	mov	sbuf,	#estk_slip_end	; this will force to generate an interrupt next time
	ret
;----------------------------------------------------------------

; This routine ends the transmission of a packet finally
;----------------------------------------------------------------
estkt_end_slip:
	mov	sbuf,	#estk_slip_end		; SLIP END char - the last character
	jnb	estk_halfdup,	estkt_not_halfdup_end
	clr	estkt_on	; switch off transmission
	setb	estkr_on	; switch on receiving
estkt_not_halfdup_end:
	clr	estkt_buff_full
	setb	estkt_stop	; stop after this last char transmission (which is SLIP END char)
	ret
;----------------------------------------------------------------

; the main transmit routine
;----------------------------------------------------------------
estkt_iapi:
;-----BRANCH---------------BRANCH----------------BRANCH----------
	jnb	estkt_stop,	estkt_chk_esc
	clr	estkt_buff_full		; whole packet sent, so buffer is free
	clr	estkt_stop
	ret
estkt_chk_esc:
	jnb	estkt_slip_esc_set,	estkt_chk_ip_h
	ljmp	estkt_slip
estkt_chk_ip_h:
	jnb	estkt_in_ip_h,	estkt_chk_udp_h
	ljmp	estkt_ip_h
estkt_chk_udp_h:
	jnb	estkt_in_udp_h,	estkt_chk_udp_data
	ljmp	estkt_udp_h
estkt_chk_udp_data:
	jnb	estkt_in_udp_data,	estkt_send_slip_end
	ljmp	estkt_udp_data
estkt_send_slip_end:
	call	estkt_end_slip		; ends slip with proper state for estkt
	ret
;-----BRANCH---------------BRANCH----------------BRANCH----------

; it expects the byte to be transmitted is in register 'a'
;-----SLIPt----------------SLIPt-----------------SLIPt-----------
estkt_slip:
	cjne	a,	#estk_slip_end,	estkt_slip_chk_esc
	setb	estkt_slip_esc_set
	setb	estkt_slip_end_escaped
	mov	a,	#estk_slip_esc
	jmp	estkt_slip_send
estkt_slip_chk_esc:
	cjne	a,	#estk_slip_esc,	estkt_slip_chk_esc_flag
	setb	estkt_slip_esc_set
	clr	estkt_slip_end_escaped		; 0 = esc was escaped
	mov	a,	#estk_slip_esc
	jmp	estkt_slip_send
estkt_slip_chk_esc_flag:
	jnb	estkt_slip_esc_set,	estkt_slip_send
	clr	estkt_slip_esc_set
	jnb	estkt_slip_end_escaped,	estkt_slip_esc_esc_L
	mov	a,	#estk_slip_esc_end
	jmp	estkt_slip_send
estkt_slip_esc_esc_L:
	mov	a,	#estk_slip_esc_esc
estkt_slip_send:
;-----SLIPt----------------SLIPt-----------------SLIPt-----------

	; sends whatever is in register a
	mov	sbuf,	a
	ret
;----------------------------------------------------------------

; the skeleton code for IP
;-----IPt------------------IPt-------------------IPt-------------
estkt_ip_h:
	inc	estkt_byte_count
	mov	a,	estkt_byte_count
	
	cjne	a,	#01h,	estkt_ip_h_b2_L
	mov	a,	#45h
	ljmp	estkt_slip
estkt_ip_h_b2_L:
	cjne	a,	#02h,	estkt_ip_h_b3_L
	ljmp	estkt_send_zero
estkt_ip_h_b3_L:
	cjne	a,	#03h,	estkt_ip_h_b4_L
	ljmp	estkt_send_zero
estkt_ip_h_b4_L:
	cjne	a,	#04h,	estkt_ip_h_b5_L
	mov	a,	estkt_data_len
	add	a,	#1Ch	; add len of udp and ip header
	ljmp	estkt_slip
estkt_ip_h_b5_L:
	cjne	a,	#05h,	estkt_ip_h_b6_L
	ljmp	estkt_send_zero
estkt_ip_h_b6_L:
	cjne	a,	#06h,	estkt_ip_h_b7_L
	mov	a,	estkt_ip_id
	ljmp	estkt_slip
estkt_ip_h_b7_L:
	cjne	a,	#07h,	estkt_ip_h_b8_L
	mov	a,	#40h
	ljmp	estkt_slip
estkt_ip_h_b8_L:
	cjne	a,	#08h,	estkt_ip_h_b9_L
	ljmp	estkt_send_zero
estkt_ip_h_b9_L:
	cjne	a,	#09h,	estkt_ip_h_b10_L
	mov	a,	#FFh
	ljmp	estkt_slip
estkt_ip_h_b10_L:
	cjne	a,	#0Ah,	estkt_ip_h_b11_L
	mov	a,	#estk_udp_prot
	ljmp	estkt_slip
estkt_ip_h_b11_L:
	cjne	a,	#0Bh,	estkt_ip_h_b12_L
	mov	a,	estkt_ip_chksm_H
	ljmp	estkt_slip
estkt_ip_h_b12_L:
	cjne	a,	#0Ch,	estkt_ip_h_b13_L
	mov	a,	estkt_ip_chksm_L
	ljmp	estkt_slip
estkt_ip_h_b13_L:
	cjne	a,	#0Dh,	estkt_ip_h_b14_L
	mov	a,	#estk_ip_b1
	ljmp	estkt_slip
estkt_ip_h_b14_L:
	cjne	a,	#0Eh,	estkt_ip_h_b15_L
	mov	a,	#estk_ip_b2
	ljmp	estkt_slip
estkt_ip_h_b15_L:
	cjne	a,	#0Fh,	estkt_ip_h_b16_L
	mov	a,	#estk_ip_b3
	ljmp	estkt_slip
estkt_ip_h_b16_L:
	cjne	a,	#10h,	estkt_ip_h_b17_L
	mov	a,	#estk_ip_b4
	ljmp	estkt_slip
estkt_ip_h_b17_L:
	cjne	a,	#11h,	estkt_ip_h_b18_L
	mov	a,	estkt_ip_dest_b1
	ljmp	estkt_slip
estkt_ip_h_b18_L:
	cjne	a,	#12h,	estkt_ip_h_b19_L
	mov	a,	estkt_ip_dest_b2
	ljmp	estkt_slip
estkt_ip_h_b19_L:
	cjne	a,	#13h,	estkt_ip_h_b20_L
	mov	a,	estkt_ip_dest_b3
	ljmp	estkt_slip
estkt_ip_h_b20_L:
	clr	estkt_in_ip_h
	setb	estkt_in_udp_h
	mov	estkt_byte_count,	#00h
	mov	a,	estkt_ip_dest_b4
	ljmp	estkt_slip
estkt_send_zero:
	mov	a,	#00h
	ljmp	estkt_slip
	
;-----IPt------------------IPt-------------------IPt-------------

; the skeleton code for UDP
;-----UDPt-----------------UDPt------------------UDPt------------
estkt_udp_h:
	inc	estkt_byte_count
	mov	a,	estkt_byte_count
	
	cjne	a,	#01h,	estkt_udp_h_b2_L
	mov	a,	#estk_port_H
	ljmp	estkt_slip
estkt_udp_h_b2_L:
	cjne	a,	#02h,	estkt_udp_h_b3_L
	mov	a,	#estk_port_L
	ljmp	estkt_slip
estkt_udp_h_b3_L:
	cjne	a,	#03h,	estkt_udp_h_b4_L
	mov	a,	estkt_port_dest_H
	ljmp	estkt_slip
estkt_udp_h_b4_L:
	cjne	a,	#04h,	estkt_udp_h_b5_L
	mov	a,	estkt_port_dest_L
	ljmp	estkt_slip
estkt_udp_h_b5_L:
	cjne	a,	#05h,	estkt_udp_h_b6_L
	ljmp	estkt_send_zero
estkt_udp_h_b6_L:
	cjne	a,	#06h,	estkt_udp_h_b7_L
	mov	a,	estkt_data_len
	add	a,	#08h
	ljmp	estkt_slip
estkt_udp_h_b7_L:
	cjne	a,	#07h,	estkt_udp_h_b8_L
	mov	a,	estkt_chksum_H
	ljmp	estkt_slip
estkt_udp_h_b8_L:
	clr	estkt_in_udp_h
	setb	estkt_in_udp_data
	mov	estkt_byte_count,	#00h
	mov	a,	estkt_chksum_L
	ljmp	estkt_slip

; send the udp data
;------------------------------------------------
estkt_udp_data:
	mov	a,	estkt_byte_count
	cjne	a,	estkt_data_len,	estkt_udp_data_nxt
	clr	estkt_in_udp_data
	ljmp	estkt_send_slip_end
estkt_udp_data_nxt:
	mov	r0,	estkt_data_ptr
	add	a,	r0
	mov	r0,	a
	
	mov	a,	@r0

	inc	estkt_byte_count
	ljmp	estkt_slip
;------------------------------------------------
;-----UDPt-----------------UDPt------------------UDPt------------

;----------------------------------------------------------------
estkt_chksm_ip:
	call	estkt_chksum_init
	
	mov	a,	#45h
	call	estkt_chksum_calculate

	mov	a,	#00h
	call	estkt_chksum_calculate

	mov	a,	#00h
	call	estkt_chksum_calculate

	mov	a,	estkt_data_len
	add	a,	#1Ch		; add 28 for the IP(20) + UDP(8) header len
	call	estkt_chksum_calculate
	
	mov	a,	#00h
	call	estkt_chksum_calculate
	
	mov	a,	estkt_ip_id
	call	estkt_chksum_calculate

	mov	a,	#40h
	call	estkt_chksum_calculate

	mov	a,	#00h
	call	estkt_chksum_calculate

	mov	a,	#FFh
	call	estkt_chksum_calculate
	
	mov	a,	#estk_udp_prot
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b1
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b2
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b3
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b4
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b1
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b2
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b3
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b4
	call	estkt_chksum_calculate

	call	estkt_chksum_finalize
	
	mov	estkt_ip_chksm_H, estkt_chksum_H
	mov	estkt_ip_chksm_L, estkt_chksum_L

	ret	
;----------------------------------------------------------------

; calculate the UDP checksum
; uses register a and r0
;----------------------------------------------------------------
estkt_chksm_udp:
	call	estkt_chksum_init

	mov	a,	#estk_ip_b1
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b2
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b3
	call	estkt_chksum_calculate

	mov	a,	#estk_ip_b4
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b1
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b2
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b3
	call	estkt_chksum_calculate

	mov	a,	estkt_ip_dest_b4
	call	estkt_chksum_calculate

	mov	a,	#00h
	call	estkt_chksum_calculate

	mov	a,	#estk_udp_prot
	call	estkt_chksum_calculate

	; include the length field twice in the checksum calculation
	;----------------------------
	mov	a,	#00h
	call	estkt_chksum_calculate

	mov	a,	estkt_data_len
	add	a,	#08h		; add the length of udp header
	call	estkt_chksum_calculate

	mov	a,	#00h
	call	estkt_chksum_calculate
	
	mov	a,	estkt_data_len
	add	a,	#08h		; add the length of udp header
	call	estkt_chksum_calculate
	;----------------------------

	mov	a,	#estk_port_H
	call	estkt_chksum_calculate

	mov	a,	#estk_port_L
	call	estkt_chksum_calculate

	mov	a,	estkt_port_dest_H
	call	estkt_chksum_calculate

	mov	a,	estkt_port_dest_L
	call	estkt_chksum_calculate
	
	; checksum the data too
	;----------------------------
	mov	r0,	estkt_data_ptr
	mov	b,	estkt_data_len
estkt_chksm_udp_data:
	mov	a,	@r0
	call	estkt_chksum_calculate
	
	inc	r0
	djnz	b,	estkt_chksm_udp_data
	;----------------------------

	call	estkt_chksum_finalize	;final checksum

	ret
;----------------------------------------------------------------
