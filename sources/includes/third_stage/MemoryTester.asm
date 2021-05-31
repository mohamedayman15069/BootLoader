%define TW0_MB                   0x200000
MemoryTester:
    pushaq
        

        mov rcx, TW0_MB       ; If beyond 2MB, I will do what I need 
        cmp rax, rcx                    
        jl .endagain                ;otherwise, I am done

    

        mov byte[rax], 0        ; Insert just  zero in the addresses


;    movsx rdi, byte[rax]
 ;  call bios_print_hexa        ; Call the number 
;video_print

    .endagain: ; back to the pagewalk 
        popaq
        ret

