;************************************** get_key_stroke.asm **************************************      
        get_key_stroke: ; A routine to print a confirmation message and wait for key press to jump to second boot stage
        ; This function will wait till clicking in the keyboard. 
        pusha ; Push all registers in the stack in 16-bit mode 
        mov ah,0x0      ; make the required parameter of int 0x16 of ah to be zero
        int 0x16 ; interrupt for waiting the user till putting an input from the keyboard 
        popa            ; pop what is inside the stack to all registers in 16-bit mode. 
        ret     ; Back 