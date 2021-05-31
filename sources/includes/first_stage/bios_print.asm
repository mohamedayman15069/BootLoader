;************************************** bios_print.asm **************************************      
      bios_print:       ; A subroutine to print a string on the screen using the bios int 0x10.
                        ; Expects si to have the address of the string to be printed.
             pusha           ; Will loop on the string characters, printing one by one. 
                        ; Will Stop when encountering character 0.
           ; This function need to be written by you.    
            .print_loop:  ; here I will need to loop over each charchters, print it , and clean it by zero. 
                  xor ax,ax ; it is the same as mov ax,0 , but this is faster in piepline.
                  lodsb      ; this CISC instruction does the following: 1. load a char that is pointed by si to ax. 2. Inc si.
                  or al,al   ; If al is zero, so we are done and back to the main function.
                  jz .done    ; now I am done. 
                              ; If there are still some charachters, I need to print them. 
                  mov ah,0x0E ; Pass the required parameters in a right way for printing using INT 0x10
                  int 0x10    ; Now print  the char which ah points to. 
                  jmp .print_loop   ; Jmp again till finishing printing the whole string. 
                  .done:            ; I need to restore the all regsiters from the stack and return.
                        popa        ; Restore(Poping) the all registers from the stack in 16-bit mode.
                        ret 
