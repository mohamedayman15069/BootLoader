%define MEM_REGIONS_SEGMENT         0x2000  
%define PTR_MEM_REGIONS_TABLE       0x18 		;24 bytes
%define Memory_region_offset        0x1018
%define bitmap_address	           	0x14000
%define PTR_MEM_REGIONS_COUNT       0x1000 
%define TW0_MB       				0x200000
%define FOUR_KB       				0x1000


parse_memory_regions: 
	pushaq
	mov rcx, MEM_REGIONS_SEGMENT
	shl rcx, 0x4	
	add rcx, PTR_MEM_REGIONS_COUNT
	mov r15, qword[rcx]

	mov r10, MEM_REGIONS_SEGMENT
	shl r10, 0x4
	add r10, Memory_region_offset			;r10 = mem segment:offset
	mov r14, bitmap_address

	loop:

		mov r11, qword[r10] 				;r11 = base address
		mov r12, qword[r10+8]				;r12 = region length
		mov r13d, dword[r10+16]				;r13 = region type
		cmp r11, 0							;if address = zero, skip this region (first 2mb)
		je next
		cmp r13d, 1
		jne next							;if not mem type 1, check next region

		jmp bitmap							;else (type 1) place it in bitmap
	
		next:
		
		add r10, 0x18 						;next in memory region table
		dec r15 							;decrement loop counter (regions count)
		cmp r15, 0
		jne loop

	mov [bitmap_max], r14					;r14 has address of last entry in bitmap

popaq
ret


bitmap:						;r11 base address and r12 region length
	
		cmp r11, TW0_MB
		jge start								;skip next part if address >=2MB

		mov rax, TW0_MB							;if address < 2mb, address + diff, length - diff
		sub rax, r11
		add r11, rax
		sub r12, rax
		cmp r12, 0
		jle return								;if length - diff < 0, get next region

		start:

	xor rdx, rdx							;zero out rdx before division
	mov rax, r11							;dividend: base address
	mov rbx, TW0_MB							;divisor 2MB
	idiv rbx								;rax/rbx, check if address is 2MB-aligned
	
	mov rax, r11
	cmp rdx, 0								;rdx = remainder
	je aligned 								;if no remainder, go to "aligned"
		
	;else, map 4kb pages until aligned address
	mov rbx, TW0_MB
	sub rbx, rdx							;2MB - remainder = excess before aligned address

	mov rax, r11
	add rax, rbx							;new base address (aligned) = base + excess
	sub r12, rbx							;remove excess part from the length


	mov qword[r14], r11						;base address in bitmap
	mov qword[r14+8], rbx					;total length of 4kb pages before aligned address (move in bitmap)
	mov byte[r14+16], 0						;move 0 in bitmap to indicate size (4KB)
	mov byte[r14+17], 0						;zero in next byte (not mapped yet)


;							xor rdi,rdi
;						 mov rdi, [r14]
;						call bios_print_hexa
;
;						  mov rsi,space
;						    call video_print
;;							xor rdi,rdi
;						 mov rdi, [r14+8]
;						call bios_print_hexa
;						mov rsi,space
;						    call video_print
						;	xor rdi,rdi
;						 mov rdi, [r14+16]
;						call bios_print_hexa
;						mov rsi,space
;						    call video_print
;							xor rdi,rdi
;						 mov rdi, [r14+17]
;						call bios_print_hexa
;
;						 mov rsi,NL
;						    call video_print
;;
;
	add r14, 18								;next entry in bitmap


	aligned:								;aligned address in rax and new length in r12, r14 = address of next bitmap entry

	mov r11, rax							;move new base address into r11

	xor rdx, rdx
	mov rax, r12							;dividend: remaining length
	mov rbx, TW0_MB							;divisor: 2MB
	idiv rbx								;divide remaining length / 2mb to get max length of 2mb pages
	
	cmp rdx, r12							;if remainder = length then length is less than 2mb
	je less									;so map them as 4kb pages

	mov r9, r12
	sub r9, rdx								;length - remainder = total length of 2mb pages



	mov qword[r14], r11						;base address in bitmap
	mov qword[r14+8], r9					;total length of 2mb pages (move in bitmap)
	mov byte[r14+16], 1						;move 1 in bitmap to indicate size (2MB)
	mov byte[r14+17], 0						;zero in next byte (not mapped yet)

		

;							xor rdi,rdi
;						 mov rdi, [r14]
;						call bios_print_hexa
;
;						  mov rsi,space
;						    call video_print
;							xor rdi,rdi
						 mov rdi, [r14+8]
;;						call bios_print_hexa
;						mov rsi,space
;						    call video_print
							xor rdi,rdi
;;						 mov rdi, [r14+16]
;						call bios_print_hexa
						mov rsi,space
;						    call video_print
;							xor rdi,rdi
;						 mov rdi, [r14+17]
;						call bios_print_hexa

;						 mov rsi,NL
;						    call video_print
;;
;		

	add r14, 18								;next entry in bitmap
	
	add r11, r9								;base address + length = address after segments added to bitmap
	cmp rdx, 0								;rdx has remainder (if remaining part is less than 2mb)
	je return								;if no remaining segments (remainder = 0), return to parse_memory_regions

	less:
	;else, map 4kb pages until end of memory region
	mov qword[r14], r11						;base address in bitmap
	mov qword[r14+8], rdx					;total length of 4kb pages remaining after 2mb pages(move in bitmap)
	mov byte[r14+16], 0						;move 0 in bitmap to indicate size (4KB)
	mov byte[r14+17], 0						;zero in next byte (not mapped yet)
	
		;					xor rdi,rdi
		;				 mov rdi, [r14]
		;				call bios_print_hexa
;
;						  mov rsi,space
;						    call video_print
;							xor rdi,rdi
;						 mov rdi, [r14+8]
;						call bios_print_hexa
;						mov rsi,space
;						    call video_print
;							xor rdi,rdi
;						 mov rdi, [r14+16]
;						call bios_print_hexa
;						mov rsi,space
;						    call video_print
							xor rdi,rdi
;						 mov rdi, [r14+17]
;;						call bios_print_hexa

;						 mov rsi,NL
;						    call video_print
;;

	add r14, 18								;next entry in bitmap

return:
	jmp next
