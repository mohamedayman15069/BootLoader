%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150                
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack

            mov ax,MEM_REGIONS_SEGMENT ; This is for the segment
            mov es , ax                 ; move the segment to the es 
            xor ebx,ebx                 ; make ebx = 0 
            mov [es:PTR_MEM_REGIONS_COUNT],word 0x0  ; Now [segment : Offset] I will increment the offset each time 
            mov di, PTR_MEM_REGIONS_TABLE               ; Starting after 24 bytes 
            .memory_scanner_loop:   ; Loop over the memory region to extract the all required information. 
            mov edx,MEM_MAGIC_NUMBER    ; According to the documentation, I will need to put in edx magic number 
            mov word [es:di+20], 0x1        ; This is where the function will load the memory region information to 
            mov eax, 0xE820             ;  This is required for int 0x15
            mov ecx,0x18
            int 0x15
            jc .memory_scan_failed ; if carry flag is set , there is a problem 
            cmp eax,MEM_MAGIC_NUMBER    ; if eax = Magic number, then, we are fine 
            jnz .memory_scan_failed ; else there is a problem 
            add di,0x18             ; Go to the next 24 byte region 
            inc word [es:PTR_MEM_REGIONS_COUNT] ; inc 
            cmp ebx,0x0             ; ; If ebx is zero, no more regions can be fetched 
            jne .memory_scanner_loop ; if not go to the next region 
            jmp .finish_memory_scan ; jmp if finished 
            ;;;;;;;;;;;;;;;;;;;;;;;;
           
            ;;;;;;;;;;;;;;;;;;;

            .memory_scan_failed:
            mov si, memory_scan_failed_msg
            call bios_print
.finish_memory_scan:
            popa                                        ; Restore all general purpose registers from the stack
            ret

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax       
            xor edi,edi
            mov di,word [es:PTR_MEM_REGIONS_COUNT]
            call bios_print_hexa
            mov si,newline
            call bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]
            mov si,0x1018 
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix


                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret