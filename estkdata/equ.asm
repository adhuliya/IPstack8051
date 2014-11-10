; data file equ.asm
;----------------------------------------------------------------
; This file contains the named byte memory locations and constants
; used thoughout the code or at specific locations. Their purpose is
; commented with them.
;----------------------------------------------------------------

; define byte variable...
;------VARIABLES---------VARIABLES--------------VARIABLES--------
; Variables used by wait_Xsec routines to give an approximate 
; software delay
; CAN BE REMOVED WHEN INTEGRATING WITH AN EXISTING PROJECT
;------------------------------------------------
dcount_1:		EQU	30h ; used by 'call wait_1sec'
dcount_2:		EQU	31h ; used by 'call wait_1sec'
dcount_3:		EQU	32h ; used by 'call wait_1sec'
;------------------------------------------------

; Section for estack declarations (defined in bit space)
;------ESTACK------ESTACK---------ESTACK---------
; The control bits of the whole stack
; These bits make the stack very configurable
; Their location depends on the location in 'reg.asm' file
;--------------------------------
estk_ctrl:		EQU	20h ; the overall control bits of estack (00 to 07h bit positions)
estkr_errs:		EQU	21h ; the location of the eight bit variables (08 to 0F bit positions)
estkr_state:		EQU	22h ; the location of the eight bit variables (10 to 17 bit positions)
estkt_state:		EQU	23h ; the location of the eight bit variable (18 to 1F)
;--------------------------------

; For checksum calculation
;--------------------------------
estkr_chksum_L:		EQU	33h ; the lower byte of checksum
estkr_chksum_H:		EQU	34h ; the higher byte of checksum
estkr_chksum_buff:	EQU	35h ; the odd buffer byte of checksum
;--------------------------------

; For IP header
;--------------------------------
estkr_byte_count:	EQU	36h ; count the position of byte in a particular header
estkr_ip_h_len:		EQU	37h ; 
estkr_tmp_byte:		EQU	38h ; a tmp location

estkr_ip_src_ipb1:	EQU	39h ; source ip address first most significant byte
estkr_ip_src_ipb2:	EQU	3Ah
estkr_ip_src_ipb3:	EQU	3Bh
estkr_ip_src_ipb4:	EQU	3Ch

estkr_ip_src_port_H:	EQU	3Dh
estkr_ip_src_port_L:	EQU	3Eh

estkr_ip_len:		EQU	3Fh ; the total length of the ip packet (max length can be 255)
estkr_prot:		EQU	40h ; the protocol field given in IP packet
;--------------------------------

; Data buffer - received from the receive module
; This buffer can be as long as required
; This space should be enough to accomodate the number of bytes
; set in the variable 'estkr_data_len_max'
; also the constant 'estkr_data_ptr_default' should point to the first byte of this buffer
; i.e. at esktr_data_b1
;------------------------------------------------
estkr_data_len:		EQU	41h	; max length that should be received
estkr_data_ptr:		EQU	42h	; the pointer from where to start storing the data
estkr_data_b1:		EQU	43h	; START OF RECEIVE BUFFER
estkr_data_b2:		EQU	44h
estkr_data_b3:		EQU	45h
estkr_data_b4:		EQU	46h
estkr_data_b5:		EQU	47h
estkr_data_b6:		EQU	48h
estkr_data_b7:		EQU	49h
estkr_data_b8:		EQU	4Ah
estkr_data_b9:		EQU	4Bh
estkr_data_b10:		EQU	4Ch
estkr_data_b11:		EQU	4Dh
estkr_data_b12:		EQU	4Eh
estkr_data_b13:		EQU	4Fh
;------------------------------------------------

; transmit related variables
; 15 bytes required in total
;------------------------------------------------
estkt_byte_count:	EQU	50h	; the position of current byte being sent
estkt_data_len:		EQU	51h	; variable to store the length of data given
estkt_data_ptr:		EQU	52h 	; pointer to the data

estkt_ip_dest_b1:	EQU	53h	; destination IP address Most Significant Byte
estkt_ip_dest_b2:	EQU	54h
estkt_ip_dest_b3:	EQU	55h
estkt_ip_dest_b4:	EQU	56h	; destination IP address Least Significant Byte

estkt_port_dest_H:	EQU	57h	; destination port number higher byte
estkt_port_dest_L:	EQU	58h	; destination port number lower byte

estkt_chksum_L:		EQU	59h	; the lower byte of checksum
estkt_chksum_H:		EQU	5Ah	; the higher byte of checksum
estkt_chksum_buff:	EQU	5Bh	; the odd buffer byte of checksum

estkt_ip_chksm_L:	EQU	5Ch	; the lower byte of checksum of ip header
estkt_ip_chksm_H:	EQU	5Dh	; the higher byte of checksum of ip header

estkt_ip_id:		EQU	5Eh	; the lower byte of identifier field of IP packet sent
;------------------------------------------------
;------ESTACK------ESTACK---------ESTACK---------
; User Program data
; This space can also be shared with the transmit routine to send a message
;------------------------------------------------
app_data_b1:		EQU	60h
app_data_b2:		EQU	61h
app_data_b3:		EQU	62h
app_data_b4:		EQU	63h
app_data_b5:		EQU	64h
app_data_b6:		EQU	65h
app_data_b7:		EQU	66h
app_data_b8:		EQU	67h
app_data_b9:		EQU	68h
app_data_b10:		EQU	69h
app_data_b11:		EQU	6Ah
app_data_b12:		EQU	6Bh
app_data_b13:		EQU	6Ch
app_data_b14:		EQU	6Dh
app_data_b15:		EQU	6Eh
app_data_b16:		EQU	6Fh
;------------------------------------------------

;------VARIABLES---------VARIABLES--------------VARIABLES--------

;------CONSTANTS---------CONSTANTS--------------CONSTANTS--------
;------------------------------------------------
estk_top_of_stack:	EQU	70h	
;------------------------------------------------

; Section for estack declarations
;------ESTACK------ESTACK---------ESTACK---------
estk_slip_end:		EQU	C0h
estk_slip_esc:		EQU	DBh
estk_slip_esc_end:	EQU	DCh
estk_slip_esc_esc:	EQU	DDh

estk_ip_b1:	EQU	ACh ; defines the ip address of this device as 172.16.1.2
estk_ip_b2:	EQU	10h
estk_ip_b3:	EQU	01h
estk_ip_b4:	EQU	02h

estk_port_H:	EQU	23h
estk_port_L:	EQU	45h

estk_udp_prot:	EQU	11h

estkr_data_len_max:		EQU	13h	;maximum udp data length that can be received
estkr_data_ptr_default:		EQU	43h

estkr_reg_bank:			EQU	18h	; default reg bank 3 (ORed with PSW)
;------ESTACK------ESTACK---------ESTACK---------
;------CONSTANTS---------CONSTANTS--------------CONSTANTS--------
