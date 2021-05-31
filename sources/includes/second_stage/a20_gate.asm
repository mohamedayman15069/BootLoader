check_a20_gate:
    pusha                                   ; Save all general purpose registers on the stack
;I will need to check the A20 
.check_gate:
mov ax,0x2402
int 0x15
jc .error ; This will give me an error 
cmp al,0x0      ; This will compare if al = 0 
je .enable_a20  ; if so I will need to enable the A20 

.enable_a20:
mov ax,0x2401
int 0x15
jc .error             ; If there is a problem go to function error 
       ; I will need to check again because the interrupt does not guarantee to enable the gate.

 mov si, a20_enabled_msg
 call bios_print
 mov ax,0x2402
int 0x15
jc .error ; This will give me an error 

    popa                                ; Restore all general purpose registers from the stack
    ret

    .error: 
          mov si, a20_enabled_msg
                call bios_print       
                popa 
                ret