; Declares the named bit variables : reg.asm 
;----------------------------------------------------------------
; This file defines named bit variables. There are 128 user bit
; variables available to user from 00h to 80h. They can 
; be named and used accordingly. 

; An example naming of a bit variable. Here A.0 (LSB of reg A) has
; been given a name A0.
; A0:	REG	A.0

; flag1:	REG	00h ; a user one bit flag
;----------------------------------------------------------------

; estack flag variables (total 30 variables (4 bytes) preferably at byte boundary)
;----------------------------------------------------------------
; Variables visible/used by mostly the outside world
; Collectively referred to as 'estk_ctrl' byte variable
;------------------------------------------------
estk_on:		REG	00h ; 1 = stack is enabled
estk_halfdup:		REG	01h ; 1 = stack as half duplex
estkr_on:		REG	02h ; 1 = can receive
estkt_on:		REG	03h ; 1 = can transmit
estkr_buff_full:	REG	04h ; 1 = a packet received, not read by application
estkt_buff_full:	REG	05h ; 1 = a packet is being sent by stack (apps shouldnot write untill this bit is set)
estkr_receiving:		REG	06h ; 1 = a packet is being received (halfdup - single buffer mode)
estk_err:		REG	07h ; 1 = some error occured somewhere
;------------------------------------------------

; Variables for mostly internal use
; Collectively referred to as 'estkr_err' byte variable
;------------------------------------------------
estkr_err:		REG	08h ; 1 = some error occured while receiving
estkr_ip_ver_err:	REG	09h ; 1 = wrong/unsupported IP version packet received
estkr_ip_len_err:	REG	0Ah ; 1 = IP packet length is more than 255
estkr_ip_frag_err:	REG	0Bh ; 1 = IP fragment received (fragments are not handled)
estkr_ip_prot_err:	REG	0Ch ; 1 = unsupported protocol packet received
estkr_ip_addr_err:	REG	0Dh ; 1 = dest IP not mine in received packet
estkr_ip_chksm_err:	REG	0Eh ; 1 = ip checksum error occured in received packet
estkr_udp_chksm_err:	REG	0Fh ; 1 = udp cheksum error occured in received packet
;------------------------------------------------

; Some utility variables that speed up the stack etc
; Collectively referred to as 'estkr_state' byte variable
;------------------------------------------------
estkr_sync_slip:	REG	10h ; 1 = sync with the next SLIP END character (except first time, initial = 0)
estkr_slip_esc_set:	REG	11h ; 1 =  prev byte was esc character (initial = 0)
estkr_in_ip_h:		REG	12h ; 1 = current received byte belongs in IP header (initial = 1)
estkr_in_udp_h:		REG	13h ; 1 = current received byte belongs in UDP header (initial = 0)
estkr_in_udp_data:	REG	14h ; 1 = current received byte belongs in UDP data field (initial = 0)
estkr_data_stored:	REG	15h ; 1 = the maximum data that can be stored is stored (intital =0)
estkr_chksum_odd:	REG	16h ; 1 = next byte is odd (used in estkr checksum calc routine)
; last one bit unused here
;------------------------------------------------

; Transmit bit variables
; Collectively referred to as 'estkt_state' byte varaible
;------------------------------------------------
estkt_err:		REG	18h ; 1 = some error occured while sending/transmitting
estkt_stop:		REG	19h ; 1 = clear ti and don't send anything
estkt_in_ip_h:		REG	1Ah ; 1 = to be sent byte belongs to IP header
estkt_in_udp_h:		REG	1Bh ; 1 = to be sent byte belongs to UDP header
estkt_in_udp_data:	REG	1Ch ; 1 = to be sent byte belongs to UDP data
estkt_slip_esc_set:	REG	1Dh ; 1 = last character was an escape, so this one has to be handled specially
estkt_slip_end_escaped:	REG	1Eh ; 1 = send escaped end , 0 = send escaped escape (last char sent was esc)
estkt_chksum_odd:	REG	1Fh ; 1 = next byte is odd (used in estkt checksum calc routine)
;------------------------------------------------
;----------------------------------------------------------------
