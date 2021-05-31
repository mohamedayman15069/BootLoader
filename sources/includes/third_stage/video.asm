%define MAX_TO_Scroll           0xB8FA0     ;0x0B8000+0xFA0 (Effective address + Max_Size)
%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000
%define VIDEO_SIZE      0X0FA0    ; 25*80*2

temp   dq    0x0


;*******************************************************************************************************************
bios_print_hexa:  ; A routine to print a 64-bit value stored in di in hexa decimal (16 hexa digits)
pushaq
mov rbx,0x0B8000          ; set BX to the start of the video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    mov rcx,0x10                                ; Set loop counter for 4*4 iterations, one for eacg digit
    xor r15,r15
    mov r15, MAX_TO_Scroll          
    .loop:                                    ; Loop on all 4 digits
            mov rsi,rdi                           ; Move current bx into si
            shr rsi,0x3C                          ; Shift SI 60 bits right 
            mov al,[hexa_digits+rsi]             ; get the right hexadcimal digit from the array        

;  Here I will need to check whether I have reached the end of the address to write on the screen. 
;  If so, I will need to scroll here. 


            cmp rbx,r15                 ; Check whether the screen is full or not 
            jl .dont_scroll              ; If not, I will complete my loop without any problem.

; Now, I need to row up one line to update a new line by the end! It is easy to use the rep function as hinted in the phase 3 assignment guidance. 

        push rdi        ; destination 
                           ; Check this link: https://en.wikibooks.org/wiki/X86_Assembly/Data_Transfer
        push rsi        ; Source : I will put the row in rsi in rdi 
        push rcx        ; Number of iterations 

        mov rdi, VIDEO_BUFFER_EFFECTIVE_ADDRESS
        mov rsi, rdi 
        add rsi, 160    ; Go to the second row 
        mov rcx, 3840   ; I will iterate over the whole screen 80*25*2 and do nothing to the final one ( it will crash since no thing after)
                        ; for(int i = 0 ; i<4000-160 ; i++)
                        ; {
                        ;    put row rsi in rdi;
                        ;     inc by 160 for both of them 
                        ;    and so on.  
                        ;    
                        ;}
    rep movsw           ; One byte for asci character and one byte for the background and font. 

    mov rdi, 3840

    mov qword[start_location],rdi ; Store the start location for printing the last row
    
     add rdi, VIDEO_BUFFER_EFFECTIVE_ADDRESS    ; the start address of last line 

; Now I need to clear out the last row to be able to write what I need. 
        mov r15,MAX_TO_Scroll
        .last_line: 

        mov word[rdi],0x1020       

        add rdi,2       ; add 2 bytes for the following one

        cmp rdi,r15
            jl .last_line  
        pop rcx 
        pop rsi
        pop rdi 

        mov rbx,VIDEO_BUFFER_EFFECTIVE_ADDRESS
        add rbx, 3840       ; Now start from the last line. 

        .dont_scroll:        

            mov byte [rbx],al     ; Else Store the charcater into current video location
            inc rbx                ; Increment current video location
            mov byte [rbx],1Fh    ; Store Blue Backgroun,  font color
            inc rbx                ; Increment current video location

            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place to be processed
            dec rcx                              ; decrement loop counter
            cmp rcx,0x0                          ; compare loop counter with zero.
            jg .loop                            ; Loop again we did not yet finish the 4 digits

            add [start_location],word 0x20
       mov rax,[start_location]
           shr ax,1
           xor rdx,rdx
            mov rcx,80
            div rcx
            mov bx,dx 
            call Move_cursor

    popaq
    ret
;*******************************************************************************************************************


video_print:
    xor r12,r12
    pushaq
    mov rbx,0x0B8000          ; set BX to the start of the video RAM
    ;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    xor rcx,rcx
video_print_loop:           ; Loop for a character by charcater processing
    inc r12
    lodsb                   ; Load character pointer to by SI into al
    cmp al,13               ; Check  new line character to stop printing
    je out_video_print_loop ; If so get out
    cmp al,0                ; Check  new line character to stop printing
    je out_video_print_loop1 ; If so get out

; Check For Scrolling here .... 
  xor r15,r15
    mov r15, MAX_TO_Scroll    


;  Here I will need to check whether I have reached the end of the address to write on the screen. 
;  If so, I will need to scroll here. 

            cmp rbx,r15                 ; Check whether the screen is full or not 
            jl .dont_scroll              ; If not, I will complete my loop without any problem.

; Now, I need to row up one line to update a new line by the end! It is easy to use the rep function as hinted in the phase 3 assignment guidance. 

        push rdi        ; destination 
                           ; Check this link: https://en.wikibooks.org/wiki/X86_Assembly/Data_Transfer
        push rsi        ; Source : I will put the row in rsi in rdi 
        push rcx        ; Number of iterations 

        mov rdi, VIDEO_BUFFER_EFFECTIVE_ADDRESS
        mov rsi, rdi 
        add rsi, 160    ; Go to the second row 
        mov rcx, 3840   ; I will iterate over the whole screen 80*25*2 and do nothing to the final one ( it will crash since no thing after)
                        ; for(int i = 0 ; i<4000-160 ; i++)
                        ; {
                        ;    put row rsi in rdi;
                        ;     inc by 160 for both of them 
                        ;    and so on.  
                        ;    
                        ;}
    rep movsw           ; One byte for asci character and one byte for the background and font. 

    mov rdi, 3840

    mov qword[start_location],rdi ; Store the start location for printing the last row
    
     add rdi, VIDEO_BUFFER_EFFECTIVE_ADDRESS    ; the start address of last line 

; Now I need to clear out the last row to be able to write what I need. 
        mov r15,MAX_TO_Scroll
        .last_line: 

        mov word[rdi],0x1020       

        add rdi,2       ; add 2 bytes for the following one

        cmp rdi,r15
            jl .last_line  
        pop rcx 
        pop rsi
        pop rdi 

        mov rbx,VIDEO_BUFFER_EFFECTIVE_ADDRESS
        add rbx, 3840       ; Now start from the last line. 

        .dont_scroll:        



    mov byte [rbx],al     ; Else Store the charcater into current video location
    inc rbx                ; Increment current video location
    mov byte [rbx],1Fh    ; Store Blue Backgroun, Yellow font color
    inc rbx                ; Increment current video location
                            ; Each position on the screen is represented by 2 bytes
                            ; The first byte stores the ascii code of the character
                            ; and the second one stores the color attributes
                            ; Foreground and background colors (16 colors) stores in the
                            ; lower and higher 4-bits
    inc rcx
    inc rcx
    jmp video_print_loop    ; Loop to print next character
out_video_print_loop:
    xor rax,rax
    mov ax,[start_location] ; Store the start location for printing in AX
    mov r8,160
    xor rdx,rdx
    add ax,0xA0             ; Add a line to the value of start location (80 x 2 bytes)
    div r8
    xor rdx,rdx
    mul r8
    mov [start_location],ax
    jmp finish_video_print_loop
out_video_print_loop1:
    mov ax,[start_location] ; Store the start location for printing in AX
    add ax,cx             ; Add a line to the value of start location (80 x 2 bytes)
    mov [start_location],ax
finish_video_print_loop:
    dec r12
    
    mov rax,[start_location]
       
            ;mov rcx,
            ;div rcx
           xor rdx,rdx
            mov rcx,160
            div rcx
            mov bx,dx 
            dec rax 
            add rbx,r12
            call Move_cursor
    
    popaq
ret



;***************************************************************************

clear_video_64: 
    pushaq


            xor ebx, ebx                              ; zero out the edx
            mov edx, 0xB8000  
            mov ax, 0x1020                           ; If we use 0x10 alone, we will have black- 
                                                ; According to the manual, we can use 0x1020 to make it blue 
                                                ; 0x2020 green and so on.
            clear:                               ; loop for clearing the screen

            mov word[edx], ax                         ; The value of ax will be in the memory of VIDEO_BUFFER_EFFECTIVE_ADDRESS
            add ebx,2                                ; inc. edx by 2 to compare with the video size
            add edx,2                                ; inc. ecx by since we know that the screen is by each 2 bytes. 
            cmp ebx,0X0FA0                       ; comparing edx with the max_video size (25*80*2)
            jl clear                             ; loop again if we did not reach the max_video size.


            
            mov qword[start_location] ,0x0              ; Start from the begining again 


    popaq
    ret
;**************************************************************************************************************
 ;  I will need bx for x  and ax for y 
Move_cursor:
 pushaq

 
	mov dl,80
	mul dl
	add bx, ax
 

	mov dx, 0x03D4
	mov al, 0x0F
	out dx, al
 
	inc dl
	mov al, bl
	out dx, al
 
	dec dl
	mov al, 0x0E
	out dx, al
 
	inc dl
	mov al, bh
	out dx, al

    popaq
	ret
;*********************************
disable_cursor:
	pushaq
	
 
	mov dx, 0x3D4
	mov al, 0xA	; low cursor shape register
	out dx, al
 
	inc dx
	mov al, 0x20	; bits 6-7 unused, bit 5 disables the cursor, bits 0-4 control the cursor shape
	out dx, al
 
	
	popaq
	ret


