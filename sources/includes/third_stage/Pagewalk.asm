%define page_table_base_address  0x100000   
%define TW0_MB                   0x200000
%define FOUR_KB   		 		0x1000     
%define MEM_PAGE_4K              0x1000
%define MEM_REGIONS_BASE_ADDRESS 0x21018
%define bitmap_address			0x14000

new_PT:   
		pushaq                                          
		xor rdi,rdi                                          ;looping over new 512 bytes at first for a new pml4
        mov rdi, page_table_base_address  
        xor rax, rax                                   
        mov rcx, 0x200                                  
        cld                                             
        rep stosq                                       

		mov qword[new_pt],rdi                                  ;new_pt has the end address of the pml4 
		mov qword[current_memory_address], rdi
        xor r10,r10												;virtual address
        xor r9,r9												;physical addresses
				
	    mov rsi, TW0_MB
	    call map
;							xchg bx,bx

        mov rax, bitmap_address	  		                        ;address of bitmap		
	    mov rcx,qword[bitmap_max]		                        ;address after bitmap ends

 ; rbx = start of segment , rdx = length of a particular segment
xor r11,r11

bitmap_loop:													;loop over bitmap entries  
	xor rsi,rsi
	xor rdx,rdx
	movsx rdx, byte[rax+16]										;get byte indicating page size (0->4kb, 1->2mb)
	cmp rdx, 0
	je check_count												;if 4k, check loop count (if loop count is zero then skip 4kb pages because
																;we start with 2mb pages then next time we loop over 4kb pages)
	mov rsi, TW0_MB												;else rsi = 2mb
	jmp continue                                                ;and continue (skip start_4k label)
				
start_4k:
;							xchg bx,bx

	movsx rdx, byte[rax+16]										;get byte indicating page size (0->4kb, 1->2mb)
	cmp rdx, 0
	jne next_entry
	mov rsi, FOUR_KB

continue:
	mov rbx, qword[rax]											;first address in this segment
	mov rdx, qword[rax+8]										;length of segment

map_addresses:          
	mov r9, rbx													;move physical address to r9 to call map function 
;					xchg bx,bx

	push rax
	push rbx
	push rcx
	push rdx
	push rsi
				;		xchg bx,bx

	call map													;map function: takes physical address to map it in page table

	pop rsi 	
	pop rdx
	pop rcx
	pop rbx
	pop rax

	add rbx, rsi			                                    ;addr + size = next address in this segment
	sub rdx, rsi												;length - size (used as loop counter)

	;						xchg bx,bx

	cmp rdx, 0

	jne map_addresses                                           ;if length not equal zero, loop again
                                                                ;else, get next entry in bitmap
mov byte[rax+17],1					                            ;change bit to 1 to indicate that this segment is mapped  

next_entry:
;						xchg bx,bx

	add rax, 18                                                 ;next entry in bitmap
	cmp rax, rcx
	jne bitmap_loop                                             ;if rax points to address after bitmap ends, check if we looped on bitmap once or twice
;jmp out

	cmp r11, 1													;if loop count = 1 (second loop done)
	je out														;then we are done
	mov r11, 1													;else, count = 1 (to indicate second loop)
	mov rax, bitmap_address										;reset rax to point to beginning of bitmap address
	jmp start_4k												;start mapping 4kb pages (2mb pages done)
check_count:
	cmp r11, 0													;if count = 0 (first loop)
	je next_entry												;continue mapping 2mb pages (label: back)
	jmp start_4k												;else, go to start_4k label to map 4kb pages (second loop over bitmap)

out:

						call MemoryTester

popaq 
ret 

            
map:                                   
;							xchg bx,bx
		mov r15, r10                                            ;r15 to store the pml4 cell index inside
  		shr r15, 39                                             ;shift right 39 bits to reach the start bit of pml4
  		and r15, 0x1ff                                          ;extract 9 bits eqivelent to the address that has the pdp address inside
		shl r15,3                                               ; multiply by 8 and add to the table address to get the cell
  		add r15, page_table_base_address
  		xor rdx, rdx                                     
  		cmp rdx, qword[r15]                                     ;check whether the pdp was created before, so I can access it directly, or I need to create it 
  		jne skip_pdp

		mov rcx, 512                                             ;if no table is found, we need to creat new one 
	    xor rax, rax 
		mov rdi,qword[new_pt] 

		cld                                 
        rep stosq    
;                    		xchg bx,bx

	    mov qword[new_pt],rdi                                     ;new_pt stores the end address of the new table
				mov qword[current_memory_address], rdi

		or rdi, 11b                                               ; set the first two bits of present and read/write
		sub rdi, 4096                                             ; back to the start of the table,  print its output
		mov [r15],rdi    
		                                           
	skip_pdp:
 ; 							xchg bx,bx

   		mov r14, r10											;r14 to store the pdp cell index inside
    	shr r14, 30                                      	    ;shift right 30 bits to reach the start bit of pdp
        and r14, 111111111b								 		;extract 9 bits eqivelent to the address that has the pdt address inside
        shl r14,3                                               ; multiply by 8 and add to the table address to get the cell
	    mov r8, [r15]                      
        and r8,0xfffffffffffff000                               ;remove the first 12 bits of the offset
        add r14, r8              
        xor rdx,rdx                         
        cmp rdx, qword[r14]                 
        jne skip_pdt                                        	;check whether the pdt was created before, so I can access it directly, or I need to create it 
	
	    mov rcx, 512
	    xor rax, rax 
	    mov rdi,qword[new_pt] 
	    cld                                 
        rep stosq       
;  							xchg bx,bx

        mov qword[new_pt],rdi                                    ;new_pt stores the end address of the new table
	    		mov qword[current_memory_address], rdi

	    or rdi, 11b 
	    sub rdi, 4096
        mov [r14],rdi     


	skip_pdt:
  ;							xchg bx,bx

	    mov r13, r10											;r13 to store the pdt cell index inside
		shr r13, 21												;shift right 21 bits to reach the start bit of pdt
		and r13, 111111111b                         			;extract 9 bits eqivelent to the address that has the pte address inside
		shl r13,3                                               ; multiply by 8 and add to the table address to get the cell
		mov r8, [r14]                      
		and r8,0xfffffffffffff000                               ;remove the first 12 bits of the offset
		add r13, r8 

		cmp rsi, TW0_MB                                          ;we will map any 2MB areas from the third level and not the fourth
		je map_M	                                             ;if mem flag rsi is 2m, so we need to map here 
		xor rdx,rdx                         
		cmp rdx, qword[r13]                                      ;else, continue to the fourth level and if not pte is found, create it.
		jne skip_pte                                             ;check whether the pte was created before, so I can access it directly, or I need to create it 
			
		mov rcx, 512
		xor rax, rax 
		mov rdi,qword[new_pt]                                     ;new_pt stores the end address of the new table
		cld                                 
		rep stosq       
  						
		mov qword[new_pt],rdi
				mov qword[current_memory_address], rdi

		or rdi, 11b                                                ; set the first two bits to 1
		sub rdi, 4096
		mov [r13],rdi                                               

	skip_pte:
  

		mov r12, r10                                       ;r12 to store the pte cell index inside
		shr r12, 12                                        ;shift right 12 bits to reach the start bit of pte
		and r12, 111111111b                                ;extract 9 bits eqivelent to the address that has the entry physical address inside
		shl r12,3      
		mov r8, [r13]                      
		and r8,0xfffffffffffff000                          ; remove the first 12 bits of the offset
		add r12, r8                   


		cmp rsi, FOUR_KB                                    ;map what we have using 4k,if 2m is not available anymore 
		je map_k	                

map_M:      
	mov rax, r9                                              ;get the physical address into rax

	or rax, 11b                                              ;set its first two bits to 1
	or rax, 10000000b                                        ;set the 7th bit to 1, as size is 2M

    mov [r13], rax                                           ;now we have the physical entry is ready to be mapped into r13 of the third level
	add r10, TW0_MB                                          ;increment the virtual address by 2M
	jmp return2
	
map_k:   
	mov rax, r9                                              ; get the physical address into rax

	or  rax, 11b                                             ; set the first two bits to 1
		
 ;   and rax, 0xFDFFFFFFFFFFFFFF                              ; set the seventh bit to zero as it is 4k



	mov [r12], rax                                           ; map the physical entry into r12 of the fourth level
	add r10, FOUR_KB                                         ;increment the virtual address by 4k

return2:

	mov rdi, page_table_base_address                        ; refresh the cr3 after creating any new tables
	mov cr3, rdi 

push rsi           
mov rsi, 0xFFFFF000                                          ; if we reach this max physical address for the program here, we cannot test memory then
cmp rax, rsi
jge leave
call MemoryTester
leave:
pop rsi 
	ret
; vaddress -> virtual address , paddress-> physical address 

map_page:

	pushaq 
	mov r10,[vaddress]
	mov r15, r10                                            ;r15 to store the pml4 cell index inside
  		shr r15, 39                                             ;shift right 39 bits to reach the start bit of pml4
  		and r15, 0x1ff                                          ;extract 9 bits eqivelent to the address that has the pdp address inside
		shl r15,3                                               ; multiply by 8 and add to the table address to get the cell
  		add r15, page_table_base_address
  		xor rdx, rdx                                     
  		cmp rdx, qword[r15]                                     ;check whether the pdp was created before, so I can access it directly, or I need to create it 
  		jne .skip_pdp

		mov rcx, 512                                             ;if no table is found, we need to creat new one 
	    xor rax, rax 
		mov rdi,qword[new_pt] 

		cld                                 
        rep stosq    
;                    		xchg bx,bx

	    mov qword[new_pt],rdi                                     ;new_pt stores the end address of the new table
	    		mov qword[current_memory_address], rdi

		or rdi, 11b                                               ; set the first two bits of present and read/write
		sub rdi, 4096                                             ; back to the start of the table,  print its output
		mov [r15],rdi    
		                                           
	.skip_pdp:
 ; 							xchg bx,bx

   		mov r14, r10											;r14 to store the pdp cell index inside
    	shr r14, 30                                      	    ;shift right 30 bits to reach the start bit of pdp
        and r14, 111111111b								 		;extract 9 bits eqivelent to the address that has the pdt address inside
        shl r14,3                                               ; multiply by 8 and add to the table address to get the cell
	    mov r8, [r15]                      
        and r8,0xfffffffffffff000                               ;remove the first 12 bits of the offset
        add r14, r8              
        xor rdx,rdx                         
        cmp rdx, qword[r14]                 
        jne .skip_pdt                                        	;check whether the pdt was created before, so I can access it directly, or I need to create it 
	
	    mov rcx, 512
	    xor rax, rax 
	    mov rdi,qword[new_pt] 
	    cld                                 
        rep stosq       
;  							xchg bx,bx

        mov qword[new_pt],rdi                                    ;new_pt stores the end address of the new table
        	    		mov qword[current_memory_address], rdi

	    or rdi, 11b 
	    sub rdi, 4096
        mov [r14],rdi     


	.skip_pdt:
  ;							xchg bx,bx

	    mov r13, r10											;r13 to store the pdt cell index inside
		shr r13, 21												;shift right 21 bits to reach the start bit of pdt
		and r13, 111111111b                         			;extract 9 bits eqivelent to the address that has the pte address inside
		shl r13,3                                               ; multiply by 8 and add to the table address to get the cell
		mov r8, [r14]                      
		and r8,0xfffffffffffff000                               ;remove the first 12 bits of the offset
		add r13, r8 

		cmp rsi, TW0_MB                                          ;we will map any 2MB areas from the third level and not the fourth
		je map_M	                                             ;if mem flag rsi is 2m, so we need to map here 
		xor rdx,rdx                         
		cmp rdx, qword[r13]                                      ;else, continue to the fourth level and if not pte is found, create it.
		jne .skip_pte                                             ;check whether the pte was created before, so I can access it directly, or I need to create it 
			
		mov rcx, 512
		xor rax, rax 
		mov rdi,qword[new_pt]                                     ;new_pt stores the end address of the new table
		cld                                 
		rep stosq       
  						
		mov qword[new_pt],rdi
		or rdi, 11b                                                ; set the first two bits to 1
		sub rdi, 4096
		mov [r13],rdi                                               

	.skip_pte:
  

		mov r12, r10                                       ;r12 to store the pte cell index inside
		shr r12, 12                                        ;shift right 12 bits to reach the start bit of pte
		and r12, 111111111b                                ;extract 9 bits eqivelent to the address that has the entry physical address inside
		shl r12,3      
		mov r8, [r13]                      
		and r8,0xfffffffffffff000                          ; remove the first 12 bits of the offset
		add r12, r8                   
	; Now with the physical part

		mov rdi, [paddress]									; put physical address in rdi
		or rax, 11b											; Now set the write and read bits
		mov [r12],rax										; map here 

	popaq
	ret 


	reload_page_table:	; refresh cr3 
    pushaq

    mov rdi, page_table_base_address                   
    mov cr3, rdi                       

    popaq
    ret
