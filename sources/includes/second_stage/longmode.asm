%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT

%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000 		;address of PML4

switch_to_long_mode:

                  ; This function need to be written by you.

    ;configure CR4
    ;enable bit 5 (PAE) and bit 7 (PGE)

    mov eax, 10100000b						;move to eax first
    mov cr4, eax							;store 10100000b into cr4

    ;configure CR3
    ;store flat address of PML4 in cr3

    mov edi, PAGE_TABLE_EFFECTIVE_ADDRESS 	;edi points to address of PML4
    mov edx, edi							;move to edx first before cr3
    mov cr3, edx							;cr3 contains address of PML4

    ;configure EFER MSR
    ;enable bit 8 (long mode)

    mov ecx, 0xC0000080						;EFER MSR identifier
    rdmsr									;value of the register is read into edx:eax

    or eax, 0x00000100						;set bit 8 (long mode enabled)
    wrmsr									;write back to special register

    ;configure cr0
    ;enable bit 0 (protected mode) and bit 31 (enable paging)
    mov ebx, cr0 							;move cr0 into ebx to modify it 
    or ebx, 0x80000001						;set bits 0 and 31 to 1
    mov cr0, ebx							;write modified value into cr0

    lgdt [GDT64.Pointer]					;load address of GDT
    jmp CODE_SEG:LongModeEntry						;load code selector with code in 64 bit mode and jump to it


 

    ret