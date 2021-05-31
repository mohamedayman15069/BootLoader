%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define bitmap_address	           	0x14000

[ORG 0x10000]

[BITS 64]
  
; mov rax,MEM_REGIONS_SEGMENT ; This is for the segment
;mov rdi , rax                 ; move the segment to the es 
;mov r11,0x3000
; shl rax,0x4
 ;add rax,PTR_MEM_REGIONS_COUNT
  ;  xor rdi,rdi
  ;  mov rdi, [rax] 
  ;  call bios_print_hexa
   
  
;call disable_cursor
xor rbx,rbx
xor rax,rax 
call Move_cursor 


call parse_memory_regions


call new_PT

 
xor rsi,rsi
mov rsi,Greetings_third_stage
call video_print



Kernel:


call scan_pci_recursive


channel_loop:
    mov qword [ata_master_var],0x0
    master_slave_loop:
        mov rdi,[ata_channel_var]
        mov rsi,[ata_master_var]
   ;                 xchg bx,bx

        call ata_identify_disk
        inc qword [ata_master_var]
        cmp qword [ata_master_var],0x2
        jl master_slave_loop

    inc qword [ata_channel_var]
    inc qword [ata_channel_var]
    cmp qword [ata_channel_var],0x4
    jl channel_loop
    
 ;           xchg bx,bx


call init_idt
call setup_idt
xor rdi, rdi
mov rsi,hello_world_str
call video_print


kernel_halt: 
    hlt
    jmp kernel_halt


;*******************************************************************************************************************
      %include "sources/includes/third_stage/pushaq.asm"
      %include "sources/includes/third_stage/pic.asm"
      %include "sources/includes/third_stage/idt.asm"
      %include "sources/includes/third_stage/pci.asm"
      %include "sources/includes/third_stage/video.asm"
      %include "sources/includes/third_stage/pit.asm"
      %include "sources/includes/third_stage/ata.asm"
      %include "sources/includes/third_stage/bitmap.asm"
      %include "sources/includes/third_stage/Pagewalk.asm"
      %include "sources/includes/third_stage/MemoryTester.asm"
      %include "sources/includes/third_stage/e1000_pci.asm"
      %include "sources/includes/third_stage/e1000_init.asm"

;*******************************************************************************************************************

e1000_mem_base dq 0x0 ; Physical Memory MMIO base address
e1000_rw_data dd 0x0 ; Data to be written/read from MMIO or Port I/O address space
e1000_rw_address dw 0x0 ; Offset address into MMIO or Port I/O address space
e1000_io_base dw 0x0 ; Port base address
e1000_vaddress dq 0x2000000000 ; Starting virtual address to map MMIO Physical Memory to
e1000_flag db 0x0 ; Flag used to be set when E1000 NIC is detected
e1000_ioport_flag db 0x0 ; A flag used to be set if the NIC is PortIO-based
e1000_mac_address db 0x0,0x0,0x0,0x0,0x0,0x0 ; A space to store E1000 NIC 6-octet MAC address
e1000_eeprom_addr db 0x0 ; EEProm address
e1000_int_no db 0x0 ; IRQ number detected from PCI Header
e1000_eeprom_flag db 0x0 ; A flag used to indicate that the EEPROM is detected
; Some messages to be used for notifications
found_intel_e1000_msg db 'Found e1000 NIC device',13,10,0
e1000_configure_msg db 'Configuring e1000',13,10,0
e1000_map_memio_msg db 'Mapping e1000 MemIO',13,10,0
e1000_eeprom_detected_msg db 'e1000 EEProm Detected',13,10,0
e1000_start_up_link_msg db 'e1000 Started Link',13,10,0
e1000_setup_throttling_msg db 'e1000 Throttling setup done',13,10,0
e1000_multicast_vt_msg db 'e1000 clear Multicast VT done',13,10,0
e1000_mem_init_msg db 'e1000 memory setup done',13,10,0
e1000_rx_init_msg db 'e1000 init RX',13,10,0
e1000_tx_init_msg db 'e1000 init TX',13,10,0
e1000_enable_interrupt_msg db 'e1000 interrupts enabled',13,10,0
e1000_got_packet_msg db 'e1000 got interrupt',13,10,0
e1000_link_restarted_int_msg db 'e1000(int) link restarted',13,10,0
e1000_good_threshold_int_msg db 'e1000(int) good threshold',13,10,0
e1000_process_packet_int_msg db 'e1000(int) process packet',13,10,0
e1000_sent_packet_msg db 'e1000 sent packet',13,10,0
my_ip_msg db 'got ARP Packet',13,10,0

; PCI bus/device/function of slot that the detected E1000 NIC is connected to
e1000_bus db 0
e1000_device db 0
e1000_function db 0
e1000_rx_cur dw 0x0 ; Current descriptor index to be processed in the Receive Ring Buffer
e1000_tx_cur dw 0x0 ; Current descriptor index to be processed in the Transmit Ring Buffer
e1000_rx_desc_ptr dq 0x0 ; Address of the Receive Ring Buffer
e1000_tx_desc_ptr dq 0x0 ; Address of the Transmit Ring Buffer
e1000_rx_packets_ptr dq 0x0 ; Address of buffer that holds packets pointed to by receive descriptor ring buffer
e1000_tx_packets_ptr dq 0x0 ; Address of buffer that holds packets pointed to by transmit descriptor ring buffer
e1000_recv_packet dq 0x0 ; Address of a buffer that holds the last packet received for processing
e1000_send_packet dq 0x0 ; Address of a buffer that holds the next packet to be sent on the network
e1000_recv_packet_len dw 0x0 ; Length of the last received packet stored in e1000_recv_packet
e1000_send_packet_len dw 0x0 ; Length of the packet to be sent store in e1000_send_packet
my_ip_address db 192,168,1,88 ; IP address assigned to the E1000 NIC


pci_offset dq 0
vaddress dq 0
paddress dq 0
current_memory_address dq 0
start_bus_mastering_msg db "Starting bus mastering..",13,10,0
bus_mastering_msg db "Bus Mastering is enabled",13,10,0
e1000_eeprom_detected_failed_msg db "eeprom NOT detected"
hexa_pad db 0

hello db "hellooooo",13,10,0
nextfunc db "next function..",13,10,0
NL db ".. ",13,0
entry dq 0
prev_bus dw 0
dot db ".",0
Greetings_third_stage db "Welcome to 64-bit Mode........ ",13,0
space db " ",13,0
colon db ':',0
comma db ',',0
newline db 13,0
new_pt dq 0
bitmap_max dq 0
loop_count dq 0
end_of_string db 13        ; The end of the string indicator
start_location dq  0x0  ; A default start position (Line # 8)

    hello_world_str db 'Hello all here',13, 0

    ata_channel_var dq 0
    ata_master_var dq 0

    bus db 0
    device db 0
    function db 0
    offset db 0
    hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
    ALIGN 4


;times 8192-($-$$) db 0
times 65024-($-$$) db 0
