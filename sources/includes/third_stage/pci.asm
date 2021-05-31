%define CONFIG_ADDRESS  0xcf8
%define CONFIG_DATA     0xcfc
%define pci_config_data 0x15000

ata_device_msg db 'Found ATA Controller',13,10,0
pci_header times 512 db 0

struc PCI_CONF_SPACE 
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc



scan_pci_recursive:
pushaq


device_loop:

    mov byte [function],0x0                 ;start from function zero (new device)

    function_loop:

        xor rax,rax                                 ;reset the word we send to command port
        xor rbx,rbx                                 ;(bus << 16)            
        mov bl,[bus]                                ;move bus number to lower byte of rbx
        shl ebx,16                                  ;shift left 16 bits
        or eax,ebx                                  ;or it with the word we send to command port
        xor rbx,rbx                                 ;(device << 11)
        mov bl,[device]                             ;move device number to lower byte of rbx
        shl ebx,11                                  ;shift device number left by 11 bits
        or eax,ebx                                  ;or it with the word we send to command port
        xor rbx,rbx                                 ;(function << 8)
        mov bl,[function]                           ;move function number to lower byte of rbx
        shl ebx,8                                   ;shift function number left by 8 bits
        or eax,ebx                                  ;or it with the word we send to command port
        or eax,0x80000000                           ;set bit 31 to make this register enabled
        xor rsi,rsi                                 
        
        mov r15, qword[entry]

        pci_config_space_read_loop:
            push rax ;save the word we send to command port on the stack
            or rax,rsi                              ;add offset in lower 8 bits
            and al,0xfc                             ;make sure last 2 bits are zeros
            mov dx,CONFIG_ADDRESS                   ;write word to command port
            out dx,eax
            mov dx,CONFIG_DATA                      ;get data from data port
            xor rax,rax
            in eax,dx
            mov [pci_config_data+r15+rsi],eax               ;store the 4 bytes read from the configuration space into the memory 
            add rsi,0x4                             ;increment offset to get next 4 bytes 
            pop rax                                 ;restore the word we send to command port from the stack
            cmp rsi,0xff                            ;loop again if we are not done reading the 256 bytes configuration space
        jl pci_config_space_read_loop

        
xor rdi,rdi
mov di, word[pci_config_data+r15+2]
cmp di, 0xFFFF
je .nodevice
call bios_print_hexa
xor rsi,rsi
mov rsi, newline
call video_print


;check for e1000

mov qword[pci_offset], r15

call e1000_pci_config


mov r11b, byte[pci_config_data+r15+14]          ;header type
cmp r11b, 0
je .next                                        ;if zero, then we're done with this device
                                                
;else (type 1), get secondary bus no. and recursively call function

;check if this is the bus we came from (bridge)
xor r12, r12
mov r12b, byte[pci_config_data+r15+25]          ;get secondary bus number
cmp r12b, byte[prev_bus]
je .nodevice

xor r14,r14
mov r14b, byte [prev_bus]
push r14

xor r13, r13
mov r13b, byte[bus]
mov byte[prev_bus], r13b


;save current bus,device and function on the stack
xor r8,r8
xor r9,r9
xor r10,r10
mov r8b, byte [bus]
mov r9b, byte [device]
mov r10b, byte [function]
push r8
push r9
push r10

mov byte[bus], r12b                             ;place it in the bus variable

mov byte [device],0x0                           ;start from dev 0, func 0 for this bus
mov byte [function],0x0

call scan_pci_recursive                         ;scan this pci bus


;restore current bus,device and function from the stack
pop r10
pop r9
pop r8
pop r14
mov byte [bus], r8b
mov byte [device], r9b
mov byte [function], r10b
mov byte [prev_bus], r14b

.next:                                          ;continue scanning devices
    add qword[entry], 256

.nodevice:
    inc byte [function]                         ;next function in this device
    cmp byte [function],8                       ;up to 8 finctions for each device
    jne function_loop
inc byte [device]                               ;next device in this bus
cmp byte [device],32                            ;up to 32 devices per bus
jne device_loop

;if 32 devices of initial bus (bus 0) are scanned, we are done.

popaq
ret