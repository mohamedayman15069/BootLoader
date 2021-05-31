        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack


            pushfd              ; I will push the e-flag in the stack
            pushfd              ; Packup for the eflag. ( I will need it again for comparison) 
            pushfd              ; Copy for the eax 

            pop eax             ; Take the e-flag and put it in the eax
            xor eax, 0x0200000  ; We will see if 21 will be flipped or not 
            push eax        ; Push the value in the stack again 
            popfd           ; I will pop the value of e-flag from the stack 
            pushfd          ; Push it again for eax 
            pop eax 
            pop ecx             ; I have the modified one in the eax and the original one in ecx
            xor eax,ecx         ; Xoring each other to get all of them ones
            and eax,0x0200000       ; To have in 21th bit 1 or zero 
            cmp eax,0x0             ; If it is zero, 21th bit is not flipped 
            jne .cpuid_supported    ; if not , it is supported
            mov si,cpuid_not_supported; the message that CPUID is not supported
            call bios_print         ; Call from the bios to print
            jmp hang 
            ; if it is supported 
            .cpuid_supported:
                mov si,cpuid_supported
                call bios_print
                popfd
        

            popa                ; Restore all general purpose registers from the stack
            ret

        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack

                mov eax,0x80000000          ; Now we need to get the largest function number. 
                cpuid                        ; This CISC function will return the largest function number. 
                cmp eax,0x80000001              ; If eax is less than this number,there is no support. 
                jl .long_mode_not_supported     ; I will go to this function 
                mov eax,0x80000001          ; If yes, I need to check whether I am supporting the long mode or not 
                cpuid                          ; Now I need to return a number if 29th bit is zero, I do not support 64 bit-mode 
                and edx,0x20000000          ; Compare now 
                cmp edx, 0x0                 ; zero! No support  
                je .long_mode_not_supported
                mov si,long_mode_supported_msg ;Else I can now support long mode 
                call bios_print
                jmp .exit_check_long_mode_with_cpuid ; now I have finsihed 
        .long_mode_not_supported:
            mov si,long_mode_not_supported_msg ; I am here, so no support to 64-bit mode.
            call bios_print ; Print now on the screen that I am not support long mode.
            jmp hang
.exit_check_long_mode_with_cpuid:

            popa                                ; Restore all general purpose registers from the stack
            ret