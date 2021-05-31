%define page_table_base_address  0x100000   
%define e1000_desc_size 16 ; Size of a Transmit/Receive Descriptor
%define e1000_desc_array_count 0x800 ; Number of Descriptor in Ring Buffer (2048)
%define e1000_desc_array_size 0x8000 ; Size of Ring Buffer (2048 x 16)
%define e1000_packet_area_size 0x400000 ; Size of Packets in Transmit/Receive Buffer (2048*2048)
%define e1000_bar0_mem_size 0x200000 ; Size of MMIO -> 128KB (From the Data Sheet)
%define e1000_packet_size 0x800 ; Size in bytes reserved for a network packet (2048)
%define E1000_CTRL_PHY_RST 0x80000000
%define FCAL 0x0028
%define FCAH 0x002C
%define FCT 0x0030
%define FCTT 0x0170
%define THROT 0x00C4
%define MULTICAST_VT 0x5200
%define REG_CTRL 0x0000
%define REG_STATUS 0x0008
%define REG_EEPROM 0x0014
%define REG_CTRL_EXT 0x0018
%define REG_ICR 0x00C0
%define REG_IMASK 0x00D0
%define REG_RCTRL 0x0100
%define REG_RXDESCLO 0x2800
%define REG_RXDESCHI 0x2804
%define REG_RXDESCLEN 0x2808
%define REG_RXDESCHEAD 0x2810
%define REG_RXDESCTAIL 0x2818
%define REG_TCTRL 0x0400
%define REG_TXDESCLO 0x3800
%define REG_TXDESCHI 0x3804
%define REG_TXDESCLEN 0x3808
%define REG_TXDESCHEAD 0x3810
%define REG_TXDESCTAIL 0x3818
%define REG_RDTR 0x2820 ; RX Delay Timer Register
%define REG_RXDCTL 0x3828 ; RX Descriptor Control
%define REG_RADV 0x282C ; RX Int. Absolute Delay Timer
%define REG_RSRPD 0x2C00 ; RX Small Packet Detect Interrupt
%define REG_TIPG 0x0410 ; Transmit Inter Packet Gap
%define ECTRL_ASDE 0x20 ;auto speed enable
%define ECTRL_FD 0x01 ;FULL DUPLEX
%define ECTRL_SLU 0x40 ;set link up
%define ECTRL_100M 0x100 ;set speed to 100 Mb/sec
%define ECTRL_1000M 0x200 ;set speed to 1000 Mb/sec
%define ECTRL_FRCSPD 0x800 ;Force Speed
%define RCTL_EN (1 << 1) ; Receiver Enable
%define RCTL_SBP (1 << 2) ; Store Bad Packets
%define RCTL_UPE (1 << 3) ; Unicast Promiscuous Enabled
%define RCTL_MPE (1 << 4) ; Multicast Promiscuous Enabled
%define RCTL_LPE (1 << 5) ; Long Packet Reception Enable
%define RCTL_LBM_NONE (0 << 6) ; No Loopback
%define RCTL_LBM_PHY (3 << 6) ; PHY or external SerDesc loopback
%define RTCL_RDMTS_HALF (0 << 8) ; Free Buffer Threshold is 1/2 of RDLEN
%define RTCL_RDMTS_QUARTER (1 << 8) ; Free Buffer Threshold is 1/4 of RDLEN
%define RTCL_RDMTS_EIGHTH (2 << 8) ; Free Buffer Threshold is 1/8 of RDLEN
%define RCTL_MO_36 (0 << 12) ; Multicast Offset - bits 47:36
%define RCTL_MO_35 (1 << 12) ; Multicast Offset - bits 46:35
%define RCTL_MO_34 (2 << 12) ; Multicast Offset - bits 45:34
%define RCTL_MO_32 (3 << 12) ; Multicast Offset - bits 43:32
%define RCTL_BAM (1 << 15) ; Broadcast Accept Mode
%define RCTL_VFE (1 << 18) ; VLAN Filter Enable
%define RCTL_CFIEN (1 << 19) ; Canonical Form Indicator Enable
%define RCTL_CFI (1 << 20) ; Canonical Form Indicator Bit Value
%define RCTL_DPF (1 << 22) ; Discard Pause Frames
%define RCTL_PMCF (1 << 23) ; Pass MAC Control Frames
%define RCTL_SECRC (1 << 26) ; Strip Ethernet CRC
; Buffer Sizes
%define RCTL_BSIZE_256 (3 << 16)
%define RCTL_BSIZE_512 (2 << 16)
%define RCTL_BSIZE_1024 (1 << 16)
%define RCTL_BSIZE_2048 (0 << 16)
%define RCTL_BSIZE_4096 ((3 << 16) | (1 << 25))
%define RCTL_BSIZE_8192 ((2 << 16) | (1 << 25))
%define RCTL_BSIZE_16384 ((1 << 16) | (1 << 25))
; Transmit Command
%define CMD_EOP (1 << 0) ; End of Packet
%define CMD_IFCS (1 << 1) ; Insert FCS
%define CMD_IC (1 << 2) ; Insert Checksum
%define CMD_RS (1 << 3) ; Report Status
%define CMD_RPS (1 << 4) ; Report Packet Sent
%define CMD_VLE (1 << 6) ; VLAN Packet Enable
%define CMD_IDE (1 << 7) ; Interrupt Delay Enable
; TCTL Register
%define TCTL_EN (1 << 1) ; Transmit Enable
%define TCTL_PSP (1 << 3) ; Pad Short Packets
%define TCTL_CT_SHIFT 4 ; Collision Threshold
%define TCTL_COLD_SHIFT 12 ; Collision Distance
%define TCTL_SWXOFF (1 << 22) ; Software XOFF Transmission
%define TCTL_RTLC (1 << 24) ; Re-transmit on Late Collision
%define TSTA_DD (1 << 0) ; Descriptor Done
%define TSTA_EC (1 << 1) ; Excess Collisions
%define TSTA_LC (1 << 2) ; Late Collision
%define LSTA_TU (1 << 3) ; Transmit Underrun

struc e1000_rx_desc					; Struct for receiving RBD 
 .addr resq 1 
 .length resw 1
 .checksum resw 1 
 .status resb 1 
 .errors resb 1
 .special resw 1 
endstruc	
struc e1000_tx_desc					; struct for transmitting RBD
 .addr resq 1 
 .length resw 1 
 .cso resb 1  
 .cmd resb 1 
 .status resb 1 
 .css resb 1 
 .special resw 1 
endstruc


;****************************************starting point*******************************************
e1000_init:									; call all necessery functions I will need for e1000
 pushaq
 cmp byte[e1000_flag],0x0 					; if it is zero, then we did not configure e1000 	
 je .quit
 mov rsi,e1000_configure_msg 				
 call video_print
 call e1000_map_mem 						; mapping e1000

 call e1000_init_mem 						
 call e1000_bus_master 						; Enabling bus_master for "firing interrupts"
 call e1000_detect_eeprom 					
 cmp byte [e1000_eeprom_flag],0x1 			; Check whether the e1000_eeporn_flag 
 jne .quit 
 call e1000_read_mac_address 				; Read the MAC address 
 call e1000_startlink 
 call e1000_setup_interrupt_throttling 		; Setupt the interrupt throttling 
 call e1000_clear_multicast_table			; clear the multicast 
 call e1000_rx_init 						; Configure the receiving ring-buffer
 call e1000_tx_init 						; configuring the transmitted ring-buffer
 call e1000_enable_interrupts				; Enable the interrupts 
 .quit:
 popaq
ret



;********************************** Memory Map MMIO Physical Frames ******************************
e1000_map_mem:
 pushaq
 mov r9,0x0 						; i for counter 
 .loop:
 mov rax,[e1000_vaddress] 			; Virtual address
 add rax,r9 						; incrementing rax by virtual address 
 mov [vaddress],rax 				; Parameter containing virtual address 
 mov rax,[e1000_mem_base] 			; address for MIMO 
 add rax,r9 						; incrementing rax by virtual address  again 
 mov [paddress],rax 				; The physical parameter for mapping 
 call map_page 						; MAP now in PTE 
 add r9,0x1000 						; Increment counter by 4KB
 cmp r9,e1000_bar0_mem_size 		; reacing the max size? 
 jl .loop 
 call reload_page_table				; Needed for reloading CR3
 mov rsi,e1000_map_memio_msg 		; printing a message to make sure it is mapped without any problem 
 call video_print	
 popaq
ret



;************************* Ring Buffers Initialization*****************************
e1000_init_mem:
 pushaq				
; This part is gonna build the receiving and transimitting ring buffers 
 	 add qword[current_memory_address],0x10000 		;add extra space after page table end
	 mov rax,[current_memory_address]
	 mov [e1000_rx_desc_ptr],rax 							
	 add rax,e1000_desc_array_size 
	 mov [e1000_tx_desc_ptr],rax 
	 add rax,e1000_desc_array_size 
	 mov [e1000_rx_packets_ptr],rax 
	 add rax,e1000_packet_area_size
	 mov [e1000_tx_packets_ptr],rax 
	 add rax,e1000_packet_area_size 
	 mov [e1000_recv_packet],rax
	 add rax,e1000_packet_size 
	 mov [e1000_send_packet],rax 
	 add rax,e1000_packet_size 
	 mov [current_memory_address],rax 
	 

	 mov r8,[e1000_rx_desc_ptr]
	 mov r9,[e1000_rx_packets_ptr]
	 mov rcx,e1000_desc_array_count
	 .rx_loop:									; Loop with receiving ring buffer for initialization 

	 mov [r8+e1000_rx_desc.addr],r9
	 mov byte[r8+e1000_rx_desc.status],0x0
	 add r8,e1000_desc_size
	 add r9,e1000_packet_size
	 dec rcx
	 cmp rcx,0x0
	 jg .rx_loop
	 
	 mov r8,[e1000_tx_desc_ptr]
	 mov r9,[e1000_tx_packets_ptr]
	 mov rcx,e1000_desc_array_count
	 .tx_loop:									; Loop with transimitting ring buffer for initialization 

	 mov [r8+e1000_tx_desc.addr],r9
	 mov byte[r8+e1000_tx_desc.cmd],0x0
	 mov byte[r8+e1000_tx_desc.status],TSTA_DD 	; Descriptor Done
	 add r8,e1000_desc_size
	 add r9,e1000_packet_size
	 dec rcx
	 cmp rcx,0x0
	 jg .tx_loop
	 mov rsi,e1000_mem_init_msg
	 call video_print 							; Print a message indicating the memory buffer reservation and setup has been done
 popaq
ret




;************************ PCI BUS Mastering *************************
pci_bus_master:
 pushaq
 ; Load the current bus/device/function with offset 0x4 which is the Command register
	 xor rbx,rbx ;((bus << 16)
	 mov bl,[bus]
	 shl ebx,16
	 or eax,ebx
	 xor rbx,rbx ;|(device << 11)
	 mov bl,[device]
	 shl ebx,11
	 or eax,ebx
	 xor rbx,rbx ;| (function << 8)
	 mov bl,[function]
	 shl ebx,8
	 or eax,ebx
	 or eax,0x80000000 ;| ( 0x80000000)
	 mov rsi,0x4
	 or rax,rsi
	 and al,0xfc 											; This ensures the the last 2 bits are zeros
	 mov rsi,start_bus_mastering_msg
	 call video_print
	 mov rdi,rax
	 call bios_print_hexa
	 mov rsi,newline
	 call video_print
	 push rax 												; Save the Config value for future use
	 mov dx,CONFIG_ADDRESS 									; Read the Command Register
	 out dx,eax
	 xor rax,rax
	 mov dx,CONFIG_DATA
	 in eax,dx
	 mov rcx,rax 											; Copy the current value of the command register
	 or rcx,0x06 											; Set the Bus-Master bits (2 and 3)
	 pop rax 												; Restore the Config value from the stack
	 push rax 												; Save the Config value for future use
	 mov dx,CONFIG_ADDRESS									; Write the new Command register with Bus-Master Enabled
	 out dx,eax
	 mov dx,CONFIG_DATA
	 mov rax,rcx
	 out dx,eax
	 pop rax 												; Restore the Config value from the stack
	 mov dx,CONFIG_ADDRESS 									; Read the Command Register to verify it was written successfully
	 out dx,eax
	 xor rax,rax
	 mov dx,CONFIG_DATA
	 in eax,dx
	 mov rdi,rax
	 call bios_print_hexa
	 mov rsi,newline
	 call video_print
	 cmp rax,rcx 											; Compare the intended Command register value with the stored one
	 jne .quit
	 mov rsi,bus_mastering_msg 								; If Bus-Mastering is enabled print a message indicating that
	 call video_print
 .quit:
 popaq
 ret


e1000_bus_master:
 pushaq
 ; Reload saved bus/device/function during the PCI scan
	 mov al,[e1000_bus]
	 mov [bus],al
	 mov al,[e1000_device]
	 mov [device],al
	 mov al,[e1000_function]
	 mov [function],al
	 call pci_bus_master 									; Do the bus mastering by calling pci_bus_master
 popaq
ret


;***************** Read command routine ***********
e1000_read_command: 										; This routine reads a value from the card address space
 pushaq
 cmp byte[e1000_ioport_flag],0x1 							; Check if card is PortIO based
 je .use_ports ; If not use MMIO
 	xor rax,rax
 	mov ax,word[e1000_rw_address] 							; Use e1000_vaddress as the base addres
 	add rax,[e1000_vaddress] 								; and use e1000_rw_address as offset
 	xor rbx,rbx
 	mov ebx,[rax]
 	mov [e1000_rw_data],ebx 								; read into e1000_rw_data from the MMIO address
 jmp .quit
 .use_ports:
 	mov dx,[e1000_io_base] 									; Use e1000_io_base to write the address
 	add ax,[e1000_rw_address] 								; you want to read from
 	out dx,eax
 	mov dx,[e1000_io_base+0x4] 								; read value ofrom port address e1000_io_base+0x4
 	in eax,dx ; to e1000_rw_data
 	add [e1000_rw_data],eax
 .quit:
 popaq
ret


;**************** Write command routine **************
e1000_write_command: 										; This routine writes a value to the card address space
 pushaq
 cmp byte[e1000_ioport_flag],0x1 							; Check if card is PortIO based
 	je .use_ports ; If not use MMIO
 		xor rax,rax
 		mov ax,word[e1000_rw_address] 						; Use e1000_vaddress as the base address
 		add rax,[e1000_vaddress] 							; and use e1000_rw_address as offset
 		xor rbx,rbx
 		mov ebx,[e1000_rw_data] 							; write e1000_rw_data to the MMIO address
 		mov [rax],ebx
 jmp .quit
 .use_ports:
 		mov dx,[e1000_io_base] 								; Use e1000_io_base to write the address
 		add ax,[e1000_rw_address] 							; you want to write to
 		out dx,eax
 		mov dx,[e1000_io_base+0x4] 							; write the value of e1000_rw_data to e1000_io_base+0x4
 		add eax,[e1000_rw_data]
 		out dx,eax
 .quit:
 popaq
ret

;********************Detecting EEPROM*************
e1000_detect_eeprom:
 pushaq

 mov word[e1000_rw_address],REG_EEPROM 	 
 mov dword[e1000_rw_data],0x1 						;write 0x1 to eeprom reg
 call e1000_write_command 

 mov rcx,0xFFFFFFFF 								;number of trials when trying to detect eeprom
 .loop: 
	 cmp rcx,0x0 									;stop the loop if number of retries left = 0
	 je .no_eprom 						
	 mov word[e1000_rw_address],REG_EEPROM
	 call e1000_read_command 						;read EEPROM REG to see if it contains 0x10
	 dec rcx
	 xor rdi,rdi
	 mov edi,dword[e1000_rw_data]
	 and rdi,0x10
	 cmp rdi,0x10
jne .loop 											;stop the loop if EEPROM REG is 0x10

 mov rsi,e1000_eeprom_detected_msg 					;If EEPROM REG contains 0x10, eeprom has been detected
 call video_print									;print message 
 mov byte [e1000_eeprom_flag],0x1
 jmp .quit
 .no_eprom:
	 mov byte [e1000_eeprom_flag],0x0 				;else, print message that no eeprom was detected
	 mov rsi, hello
	 call video_print
 .quit:
 popaq
ret


;************Read EEPROM Register**************
e1000_eeprom_read: 		; The eeprom registers are 16 byte wide
 	pushaq 				; The eeprom reads double word: the lower one is the status and
					 	; the higher one os the register value
 		xor rax,rax
	 	mov al,[e1000_eeprom_addr] 						;Read from e1000_eeprom_addr
	 	shl eax,0x8 									;multiply by 16 because eeprom registers are 16 byte wide
	 	or eax,0x1 								 		;store 1 in bit 0
	 	mov word[e1000_rw_address],REG_EEPROM
	 	mov dword[e1000_rw_data],eax 					;Use REG_EEPROM as the base address and e1000_rw_data as the offset
	 	call e1000_write_command
	 	.loop:
	 		mov word[e1000_rw_address],REG_EEPROM
	 		call e1000_read_command					 	;read from the EEPROM registers
	 		xor rdi,rdi
	 		mov edi,dword[e1000_rw_data] 
	 		and rdi, (1 << 4) 							;if bit 5 in [e1000_rw_data] is 0x1, we are done
	 		cmp rdi,0x0 ; else try again
	 	je .loop
	 	xor rdi,rdi
		mov edi,dword[e1000_rw_data]
	 	shr edi,16
	 	and edi,0xFFFF
	 	mov dword[e1000_rw_data],edi 		
 	popaq
ret



;************ Read MAC Address *****************
e1000_read_mac_address: ;read 6-octets from e1000_eeprom_addr into Register Index; each register contains 2 octets
 pushaq
	 mov r9,0x0
	 mov r10,0x0
	 .loop:
	 mov byte[e1000_eeprom_addr],r9b 								;read register 0
	 call e1000_eeprom_read
	 xor rdi,rdi
	 mov edi,dword[e1000_rw_data]
	 and edi,0xff 													;extract first byte
	 mov [e1000_mac_address+r10],dil 								;store the byte in e1000_mac_address
	 inc r10 														;get next byte in e1000_mac_address
	 xor rdi,rdi
	 mov edi,dword[e1000_rw_data]
	 shr edi,0x8 													;shift right 8 bits to get the next byte
	 and edi,0xff 													;extract next byte
	 mov [e1000_mac_address+r10],dil 								;store the byte in e1000_mac_address
	 inc r10 														;get next byte in e1000_mac_address
	 inc r9 														;r9 points to next register
	 cmp r9,0x3
	 jne .loop 														;loop until 3*2 octets have been read
	 call e1000_print_mac_address
 popaq
ret

;******************Print MAC Address ******************
e1000_print_mac_address:
 pushaq
	mov byte[hexa_pad],0x2  										;an octet is up to 2 hexa digits
	mov r9,0x0 														;loop counter for looping over all octets
	.loop:
		 xor rdi,rdi
		 mov dil,byte[e1000_mac_address+r9]
		 call bios_print_hexa 										;print octet
		 inc r9
		 cmp r9,0x6
		 je .skip_colon 											;if not last octet yet, print ':'
		 mov rsi,colon
		 call video_print
		.skip_colon:
		 cmp r9,0x6 												;if last octet, we are done
	 jl .loop
	 mov byte[hexa_pad],0x10 										;reset hexa_pad to its default
	 mov rsi,newline
	 call video_print
 popaq
ret



;**********************************Startup Link**************************************
e1000_startlink:
 pushaq
	 mov word[e1000_rw_address],REG_CTRL 			; Read the value on the REG_CTRL
	 call e1000_read_command
	 xor rax,rax
	 mov eax,dword[e1000_rw_data]
	 or eax, ECTRL_SLU | ECTRL_ASDE | ECTRL_FD | ECTRL_100M| ECTRL_FRCSPD
	 ; Set Link Up, Auto Speed Enabled, Full Duplex, Set Speed to 100 Mb/sec, Force Speed
	 mov dword[e1000_rw_data],eax
	 call e1000_write_command
	 xor rax,rax 									; Disable Flow control by writing 0x0 to all registers, to enable auto-negotiation
	 mov dword[e1000_rw_data],eax
	 mov word[e1000_rw_address],FCAL
	 call e1000_write_command
	 mov word[e1000_rw_address],FCAH
	 call e1000_write_command
	 mov word[e1000_rw_address],FCT
	 call e1000_write_command
	 mov word[e1000_rw_address],FCTT
	 call e1000_write_command
	 mov word[e1000_rw_address],REG_STATUS
	 call e1000_read_command
	 xor rdi,rdi 									;read Status register and print it.
	 mov edi,dword[e1000_rw_data]
	 call bios_print_hexa
	 mov rsi,newline
	 call video_print
	 mov rsi,e1000_start_up_link_msg
	 call video_print
 popaq
ret




;***********************************Setup Throttling Rate*******************************
; Throttling interval is defined in 256 ns.
; Interrupts/seconds = (256x10-9 x interval)-1
; We use here interval = 4
; 1000000000/(256*4)
e1000_setup_interrupt_throttling:
 pushaq
	 mov rax,0x3B9ACA00 							; 10^9
	 shr rax,10 									; 256*4 = 1024 = 2^10
	 mov dword[e1000_rw_data],eax
	 mov word[e1000_rw_address],THROT 				; Write to Throttling address
	 call e1000_write_command
	 mov rsi,e1000_setup_throttling_msg 			; Print a message for throttling setting
	 call video_print
 popaq
ret


;***********************************Clear Multicast Table Array****************************
; Clear multicast filter addresses. A buffer at address offset 0x5200 can hold up to 128 addresses
e1000_clear_multicast_table:
 pushaq
	 mov rcx,0x80 ; 0x80 = 128, act as a counter for MTA Table entries
	 mov r9,MULTICAST_VT 							; Location of the multicast buffer 0x5200
	 .loop:
	 mov dword[e1000_rw_data],0x0 ; Store 0x0
	 mov word[e1000_rw_address],r9w
	 call e1000_write_command
	 add r9,0x4 									; Increment register index by 0x4
	 dec rcx 										; Decrement counter

	 cmp rcx,0x0 									; check counter
	 jne .loop
	 mov rsi,e1000_multicast_vt_msg 				; Print a message
	 call video_print
 popaq
ret


;***************Configure Receiving**************
e1000_rx_init: 									; We assume here identity memory mapping, or else we need to use v2p
 pushaq
 mov rax,[e1000_rx_desc_ptr] 					; Set the low 32-bits of the Ring Buffer
 mov word[e1000_rw_address],REG_RXDESCLO 		; address to the memory area we already
 mov dword[e1000_rw_data],eax 			
 call e1000_write_command
 xor rax,rax 									; the address we are using is less than 4GB so we store in the higher
 mov word[e1000_rw_address],REG_RXDESCHI	 
 mov dword[e1000_rw_data],eax ; 32 bits 0x0
 call e1000_write_command
 mov rax,e1000_desc_array_size 					;size of the ring buffer
 mov word[e1000_rw_address],REG_RXDESCLEN
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 xor rax,rax ;Set the index of the head pointer
 mov word[e1000_rw_address],REG_RXDESCHEAD
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 xor rax,e1000_desc_array_count-1  				;Set the index of the tail
 mov word[e1000_rw_address],REG_RXDESCTAIL
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 mov rax, RCTL_EN| RCTL_UPE | RCTL_MPE | RCTL_LBM_NONE | RTCL_RDMTS_HALF | RCTL_BAM | RCTL_SECRC|RCTL_BSIZE_16384
 ; Enable Recv, Enable Unicast Promiscuous md, Enable Multicast Promiscuous md, No loopback, Bcast mode, Strip Eth CRC
 mov word[e1000_rw_address],REG_RCTRL
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 mov rsi,e1000_rx_init_msg
 call video_print
 popaq
ret



;************************Configure Transmission********************



e1000_tx_init: 
 pushaq
 mov rax,[e1000_tx_desc_ptr]								 ; We need to set the lower 32 bit of ring buffer
 mov word[e1000_rw_address],REG_TXDESCLO 						; address of the memory
 mov dword[e1000_rw_data],eax 
 call e1000_write_command
 xor rax,rax 
 mov word[e1000_rw_address],REG_TXDESCHI 					
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 mov rax,e1000_desc_array_size
 mov word[e1000_rw_address],REG_TXDESCLEN 					; Put the size of buffer in e1000_rw_address
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 xor rax,rax
 mov word[e1000_rw_address],REG_TXDESCHEAD 					
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 xor rax,rax
 mov word[e1000_rw_address],REG_TXDESCTAIL 
 mov dword[e1000_rw_data],eax
 call e1000_write_command 
 mov rax,TCTL_EN | TCTL_PSP | (0xF << TCTL_CT_SHIFT) | (0x3F << TCTL_COLD_SHIFT) | TCTL_SWXOFF | TCTL_RTLC
 ; Enable Transmission, Pad short packets, Collision Threshold, Collision Distance, SW XOFF ( late collision)
 mov word[e1000_rw_address],REG_TCTRL
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 ; Configure Inter Packet Gap Timer
 mov rax,0x00602006
 mov word[e1000_rw_address],REG_TIPG
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 ; Print a message
 mov rsi,e1000_tx_init_msg
 call video_print
 popaq
ret


;*************Enable Interrupt Events***************


e1000_enable_interrupts:
 pushaq
 xor rdi,rdi
 mov dil,[e1000_int_no]
 add rdi,32
 mov rsi, e1000_int_handler 					; register interrupt handler e1000_int_handler
 call register_idt_handler 
 xor rdi,rdi
 mov dil,[e1000_int_no]
 call clear_irq_mask 							; Clear the IRQ_mask here 
 mov rax,0x1F6DC 
 mov word[e1000_rw_address],REG_IMASK
 mov dword[e1000_rw_data],eax
 call e1000_write_command
 ; Read status and print it
 mov word[e1000_rw_address],REG_ICR
 call e1000_read_command
 xor rdi,rdi
 mov edi,dword[e1000_rw_data]
 call bios_print_hexa
 mov rsi,newline
 call video_print
 ; print a message
 mov rsi,e1000_enable_interrupt_msg
 call video_print
 popaq
ret


;*****************Send a Packet****************

e1000_send_out_packet:
 pushaq
 xor r11,r11 
 mov r11w,word[e1000_tx_cur] ; get the value of e1000_tx and multiply by 2^4
 shl r11,0x4
 xor r9,r9 			
 mov r9,[e1000_tx_desc_ptr]
 add r9,r11 
 mov rcx,e1000_packet_size
 cld
 mov rsi,[e1000_send_packet]
 mov rdi,[r9+e1000_tx_desc.addr]
 rep movsb
 mov byte[r9+e1000_tx_desc.status],0x0 

 ; Now the packet will send
 mov byte[r9+e1000_tx_desc.cmd],CMD_EOP | CMD_IFCS | CMD_RS | CMD_RPS
 mov bx,[e1000_send_packet_len]							 ; Store the length into the ring buffer descriptor
 mov [r9+e1000_tx_desc.length],bx
 inc word[e1000_tx_cur] 
 cmp word[e1000_tx_cur],0x800 
 jl .skip_mod 					; Final buffer size has reached
 mov dword[e1000_tx_cur],0x0
 .skip_mod:
 mov word[e1000_rw_address],REG_TXDESCTAIL 			; Update now the tx
 mov r8d,[e1000_tx_cur]
 mov [e1000_rw_data],r8d
 call e1000_write_command
 .loop: ; Loop until status not equal to zero
 cmp byte[r9+e1000_tx_desc.status],0x0
 je .loop
 mov rsi,e1000_sent_packet_msg					; print a message
 call video_print
 .quit:
 popaq
ret



;****************Network Interrupt Handler********************


e1000_int_handler: 										; Handler when the interrupt is invoked.
 pushaq
 mov word[e1000_rw_address],REG_ICR 					; Read the status register
 call e1000_read_command
 xor rax,rax
 mov eax,dword[e1000_rw_data]
 and eax,0x04
 cmp eax,0x04 ; Check status bit 3
 jne .skip_link_started
 mov rsi,e1000_link_restarted_int_msg 					; If set then link is restarted
 call video_print
 jmp .out
 .skip_link_started:
 mov eax,dword[e1000_rw_data]
 and eax,0x10 ; Else check bit 5
 cmp eax,0x10
 jne .skip_good_threshold 							; when it is set, it means that the packet rate is very high.
 mov rsi,e1000_good_threshold_int_msg 
 call video_print
 jmp .out
 .skip_good_threshold:
 mov eax,dword[e1000_rw_data]
 and eax,0x80
 cmp eax,0x80 ; Else check bit 7
 jne .skip_process_packet
 mov rsi,e1000_process_packet_int_msg				 ; process the received one.
 call video_print
 call e1000_process_packet 							; Call process now.
 jmp .out
 .skip_process_packet:								 ; Else exit
 .out:
 popaq
ret


;******************Process a Packets Upon Interrupt****************

e1000_process_packet:			; process the packet
 pushaq
 mov word[e1000_rw_address],REG_RXDESCHEAD 			; Fetch the Receive Ring Buffer Head pointer
 call e1000_read_command
 xor r8,r8
 mov r8d,[e1000_rw_data]
 cmp r8w,[e1000_rx_cur] 
 je .quit ; If they are equal nothing to process
 .loop:							; this loop is for  ; to process all network packets arrived since					 

 xor r8,r8
 mov r8w,[e1000_rx_cur]			
 shl r8,0x4 					; multiply by 2^4
 xor r9,r9
 mov r9,[e1000_rx_desc_ptr] 
 add r9,r8 
 xor rax,rax
 mov al,byte[r9+e1000_rx_desc.status] 
 and al,0x1
 cmp al,0x1
	jne .update_tail 					; if status does not have bit-0 set then  I am done. Exit now. 
mov rcx,e1000_packet_size 				; else copy the packet to the temp packet area
 shr rcx,8
 cld
 mov rsi,[r9+e1000_rx_desc.addr]
 mov rdi,[e1000_recv_packet]
 rep movsq
 mov bx,[r9+e1000_rx_desc.length] 
 mov [e1000_recv_packet_len],bx 
 call network_stack 						; Call the network_stack routine to start
 mov byte[r9+e1000_rx_desc.status],0x0 
 inc word[e1000_rx_cur] ; Advance e1000_rx_cur
 cmp word[e1000_rx_cur],0x800
 jl .skip_mod 
 mov dword[e1000_rx_cur],0x0
 .skip_mod:
 jmp .loop ;				 Check the next Descr. of the ring buffer
 .update_tail: 			; Update the tail of the ring buffer by writing it
 mov word[e1000_rw_address],REG_RXDESCTAIL
 mov r8d,[e1000_rx_cur]
 mov [e1000_rw_data],r8d
 call e1000_write_command
 .quit:
 popaq
ret



%define ETHERTYPE_IP 0x0800 
%define ETHERTYPE_ARP 0x0806
; Ethernet Protocol packet
struc ethernet_packet
 .h_dest resb 6 
 .h_src resb 6 
 .h_type resw 1 
endstruc


;**************Network Stack Entry point****************
network_stack:				; The prespective to be able to send and receive and construct or delete the headers. 
 pushaq
 xor rdi,rdi 
 mov di,[r9+ethernet_packet.h_type]
 rol di,0x8 
 cmp di,ETHERTYPE_ARP 
 jne .skip_arp
 call process_arp 
 jmp .quit
 .skip_arp:
 cmp di,ETHERTYPE_IP 
 jne .quit
 						
 .quit:
 popaq
ret





%define ARPHRD_ETHER 1 
%define ARPHRD_IEEE802 6 
%define ARPHRD_FRELAY 15 
%define ARPHRD_IEEE1394 24 
%define ARPHRD_IEEE1394_EUI64 27 
%define ARPOP_REQUEST 1 
%define ARPOP_REPLY 2
%define ARPOP_REVREQUEST 3 
%define ARPOP_REVREPLY 4 
%define ARPOP_INVREQUEST 8 
%define ARPOP_INVREPLY 9 
struc arp_packet
 .ethernet resb 14 ; Ethernet header
 .ar_hdr resw 1 ; Hardware Type
 .ar_pro resw 1 ; Protocol type for which resolution is performed e.g. IP
 .ar_hln resb 1 ; Hardware address length
 .ar_pln resb 1 ; Protocol address length
 .ar_op resw 1 ; Operation, e.g. Request/Reply
 .sender_hw_addr resb 6 ; Based on ar_hdr for ethernet 6-octet source HW address
 .sender_proto_addr resb 4 ; Based on ar_pro for IP 4-octet source protocol address
 .target_hw_addr resb 6 ; Based on ar_hdr for ethernet 6-octet target HW address
 .target_proto_addr resb 4 ; Based on ar_pro for IP 4-octet target protocol address
endstruc

;**************Process ARP Packet*****************
process_arp:
 pushaq
 mov r9,[e1000_recv_packet] 
 mov ax,word [r9+arp_packet.ar_op]
 rol ax,0x8 
 cmp ax,ARPOP_REQUEST
 jne .quit
 mov ax,word [r9+arp_packet.ar_hdr] 
 rol ax,0x8 
 cmp ax,ARPHRD_ETHER 
 jne .quit
 xor r8,r8
 xor rbx,rbx
 mov r8d,dword[r9+arp_packet.target_proto_addr] 
 mov ebx,dword[my_ip_address]
 cmp r8,rbx
 jne .quit
 mov rsi,my_ip_msg
 call video_print
 mov r8,[e1000_recv_packet]
 mov r9,[e1000_send_packet]

 								; Copy the source of the Recv buffer into the dest of the Send buffer
 lea rsi,[r8+ethernet_packet.h_src]
 lea rdi,[r9+ethernet_packet.h_dest]
 mov rcx,0x6
 cld
 rep movsb
 lea rsi,[e1000_mac_address]
 lea rdi,[r9+ethernet_packet.h_src]
 mov rcx,0x6
 cld
 rep movsb
 xor rax,rax
 mov ax,[r8+ethernet_packet.h_type]
 mov [r9+ethernet_packet.h_type],ax
 ; Set the ARP operation field in the Send buffer to ARPOP_REPLY
 mov ax, ARPOP_REPLY
 rol ax,0x8 ; Apply HTON (Host to Network)
 mov [r9+arp_packet.ar_op],ax
 mov word[r9+arp_packet.ar_hdr],ARPHRD_ETHER 				; Set Hardware Type
 mov word[r9+arp_packet.ar_pro],ETHERTYPE_IP				 ; Set Network Protocol Type
 mov byte[r9+arp_packet.ar_hln],0x6 					; Set Hardware Address length (ETHER MAC)
 mov byte[r9+arp_packet.ar_pln],0x4 						; Set Protocol Address length (IPv4)
 lea rsi,[r8+arp_packet.sender_hw_addr]
 lea rdi,[r9+arp_packet.target_hw_addr]
 mov rcx,0x6
 cld
 rep movsb
 ; Copy my MAC address to the sender source HW address
 lea rsi,[e1000_mac_address]
 lea rdi,[r9+arp_packet.sender_hw_addr]
 mov rcx,0x6
 cld
 rep movsb
 mov eax,[r8+arp_packet.sender_proto_addr]
 mov [r9+arp_packet.target_proto_addr],eax
 mov eax,[r8+arp_packet.target_proto_addr]
 mov [r9+arp_packet.sender_proto_addr],eax

 mov bx,[e1000_recv_packet_len]
 mov [e1000_send_packet_len],bx
 call e1000_send_out_packet
 .quit:
 popaq
ret