%define PAGE_TABLE_BASE_ADDRESS 0x0000
%define PAGE_TABLE_BASE_OFFSET 0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000
%define PAGE_PRESENT_WRITE 0x3  ; 011b
%define MEM_PAGE_4K         0x1000

build_page_table:
    pusha                                   ; Save all general purpose registers on the stack

            ; This function need to be written by you.


    mov ax, PAGE_TABLE_BASE_ADDRESS			;base address is 0x0000
    mov es, ax								;move base address into es
    mov edi, PAGE_TABLE_BASE_OFFSET 		;move offset (0x1000) into edi
    										;so that es:di contains where the page table should be stored 0x0000:0x1000
    mov ecx, 0x1000							;ecx contains the number of repetitions that will be done by the rep stosd instruction
    										;0x1000 is 4096 in decimal, which is 4KB
    xor eax,eax								;set eax to zero
    cld										;direction flag set to zero, so edi will be incremented by the next instruction
    rep stosd								;store eax at address es:di and repeat for 4096 times, incrementing edi by 4 every time (double word)
    										;this creates 16KB which is 4 memory pages

    mov edi,PAGE_TABLE_BASE_OFFSET			;di points to 0x1000 again, so it points to page map level 4 (PML4)
    										;so es:di + 4KB = address of PDP
    lea eax, [es:di + MEM_PAGE_4K]			;address of PDP in eax
    or eax, PAGE_PRESENT_WRITE 				;set bits 0 & 1 (present and read/write), eax = 0x2003
    mov [es:di], eax						;move 0x2003 into first entry of PML4

    add di,MEM_PAGE_4K 						;es:di points to PDP (0x0000:0x2000)
    lea eax, [es:di + MEM_PAGE_4K]			;eax = address of PD 
    or eax, PAGE_PRESENT_WRITE 				;set bits 0 & 1 (present and read/write), eax = 0x3003
    mov [es:di], eax						;move 0x3003 into first entry of PDP

    add di, MEM_PAGE_4K 					;es:di points to PD (0x0000:0x3000)
    lea eax, [es:di +MEM_PAGE_4K]			;eax = address of Page Table (PT)
    or eax, PAGE_PRESENT_WRITE 				;set bits 0 & 1 (present and read/write), eax = 0x4003
    mov [es:di], eax 						;move 0x4003 into first entry of PD

    add di, MEM_PAGE_4K 					;es:di points to PT (0x0000:0x4000)
    mov eax, PAGE_PRESENT_WRITE 			;eax = 0x0003

    .pte_loop:
    	mov [es:di], eax 					;store 0x0003 in first entry in page table (first iteration of the loop)
    	add eax, MEM_PAGE_4K 				;add 0x1000 to eax
    	add di, 0x8							;point to next PTE
    	cmp eax, 0x200000					;check if we mapped 2 MB of memory
    	jl .pte_loop						;loop until 2 MB of memory have been mapped

    popa                                ; Restore all general purpose registers from the stack
    ret