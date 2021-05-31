 ;************************************** lba_2_chs.asm **************************************
 lba_2_chs:  ; Convert the value store in [lba_sector] to its equivelant CHS values and store them in [Cylinder],[Head], and [Sector]
    pusha  ; Push the all registers in the stack 
    ; Basically, I will need to get the Cylinder number, head number , and sector number 
    ; Following some basic formulas. 
    ; First get the sector number 

    xor dx, dx ; make dx = 0 to perform a right divison 
    mov ax,[lba_sector] ; This is the number of lba ( I need to change it )
    div word [spt]      ; Now I have the reminder of this divison (lba_sector/spt) which is the sector
    inc dx ; the sector is one based 
   mov [Sector], dx         ; Now, I have the sector number 
   ; Second the cylinder 
     xor dx, dx 
     div word[hpc]          ; The track number(Quotient(ax)) / hpc will help me getting the cylinder number
    mov [Cylinder], ax      ; Put the division inside the cylinder 
    mov [Head],dl           ; The reminder will be the number of heads 

    popa 
    ret 