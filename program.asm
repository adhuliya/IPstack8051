	CHIP 8052
	.list on

	ljmp	main_start ; important - have to skip the isr table

	org	0003h
	include estkasm\isr_tab.asm	

main_start:
	include	estkdata\equ.asm
	include	estkdata\reg.asm
	
	mov	sp,	#estk_top_of_stack ; an IMPORTANT first step


; initialize the system timers and uart in the system
;----------------------------------------------------------------
	call	init_main
;----------------------------------------------------------------
	
	;mov	sbuf,	#'R'
	;call	estk_init_halfduplex ; an api to initialize the stack to begin operation in full duplex mode
	;call	estk_init_tran_only
	;call	estk_init_rec_only
	call	estk_init	; full duplex initialization

	mov	app_data_b1,	#30h
	mov	app_data_b2,	#31h
	mov	app_data_b3,	#32h
	mov	app_data_b4,	#33h
	
g_main:

	mov	p1,	app_data_b1

	; Code to receive a packet
	; the estkr_buff_full has to be cleared to receive another packet
	;--------------------------------	
	jnb	estkr_buff_full,	hop1
	mov	app_data_b1,	estkr_data_b1
	mov	app_data_b2,	estkr_data_b2
	mov	app_data_b3,	estkr_data_b3
	mov	app_data_b4,	estkr_data_b4
	clr	estkr_buff_full
	;--------------------------------	
hop1:
	; Code to send the packet
	;--------------------------------	
	mov	estkt_data_ptr,	#app_data_b1
	mov	estkt_data_len,	#04h

	mov	estkt_ip_dest_b1,	#ACh
	mov	estkt_ip_dest_b2,	#10h
	mov	estkt_ip_dest_b3,	#01h
	mov	estkt_ip_dest_b4,	#01h

	mov	estkt_port_dest_H,	#67h
	mov	estkt_port_dest_L,	#89h
	
	call	estkt_start_slip
	;--------------------------------	

	call	wait_1sec
	jmp	g_main
	
	include	util\util.asm
	include	estkasm\init.asm
	include	estkasm\isr.asm
	include	estk\estk_r.asm
	include	estk\estkinit.asm
	include estk\chksm_r.asm
	include estk\chksm_t.asm
	include	estk\estk_t.asm

	end
