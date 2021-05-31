%define INTEL_VEND      0x8086
%define E1000_DEV       0x100E
%define E1000_DEV1      0x153A
%define E1000_DEV2      0x10EA
%define E1000_DEV3      0x100F
%define E1000_DEV4      0x1004
%define E1000_MODELS_COUNT 0x5
%define pci_config_data 0x15000

e1000_pci_config:                           ; This function need to be invoked from within the PCI scan loop for each device
 pushaq

mov r15, qword[pci_offset]
cmp word[pci_config_data+r15], INTEL_VEND
jne .quit                                       ; Get out the device is definitely not and E1000 NIC
                                                ; Check to see if the DEVICE ID is equal to one of the E1000 NICs above, else quit.
cmp word[pci_config_data+r15+2], E1000_DEV
 je .found
 cmp word[pci_config_data+r15+2], E1000_DEV1
 je .found
 cmp word[pci_config_data+r15+2], E1000_DEV2
 je .found
 cmp word[pci_config_data+r15+2], E1000_DEV3
 je .found
 cmp word[pci_config_data+r15+2], E1000_DEV4
 je .found
 jmp .quit
 

.found:                                         ;found e1000 device
 mov byte[e1000_flag],0x1                       ;set the e1000 flag to 1 because we found it
 xor rax,rax
 mov al,byte[pci_config_data+r15+16]            ;check first byte in bar0 (0->MMIO, 1->I/O PORTS)
 and al,0x1
 mov [e1000_ioport_flag],al                     ;I/O ports flag = lowest byte in bar0 anded with 1
 mov eax,[pci_config_data+r15+20]               ;read bar1 into eax (port number)
 and eax,~0x1                                   ;clear first bit in bar1
 mov [e1000_io_base],ax                         
 xor rax,rax
 mov eax,[pci_config_data+r15+16]       		;read BAR0 and clear first 2 bits as MMIO base address
 and eax,~0x3
 mov [e1000_mem_base],rax
 xor rax,rax                                
 mov al,byte[pci_config_data+r15+60]            ;get interrupt line
 or al,byte[pci_config_data+r15+61]             ;get interrupt pin, int pin OR int line = IRQ number
 mov [e1000_int_no],al                          ;save IRQ number in mem variable 
 mov rsi,found_intel_e1000_msg                  ;print message e1000 found
 call video_print   
 mov al,[bus]                                   ;save the PCI bus
 mov [e1000_bus],al                        
 mov al,[device]                                ;save PCI device
 mov [e1000_device],al
 mov al,[function]                              ;save PCI function
 mov [e1000_function],al

call e1000_init
 .quit:

 popaq
ret