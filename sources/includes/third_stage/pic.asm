%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    configure_pic:
        pushaq
                  ; This function need to be written by you.

            mov al,11111111b                                        ;masking all IRQs to disable the PIC
            out MASTER_PIC_DATA_PORT,al 
            out SLAVE_PIC_DATA_PORT,al

            ;sending ICW1 to command port so that the PIC understands the other ICWs
            ;sending initialization control words on the data port

            mov al,00010001b                                        ;set ICW1
            out MASTER_PIC_COMMAND_PORT,al                          ;send to command ports
            out SLAVE_PIC_COMMAND_PORT,al

            ;send ICW2 to data ports: for mapping PIC pins to interrupts
            mov al,0x20                                             ;interrupt 32 on the master
            out MASTER_PIC_DATA_PORT,al
            mov al,0x28                                             ;interrupt 40 on the slave
            out SLAVE_PIC_DATA_PORT,al

            ;send ICW3 to data ports: for cascading communication between master and slave.
            mov al,00000100b                                        ;IRQ2 on the master
            out MASTER_PIC_DATA_PORT,al
            mov al,00000010b                                        ;send to the slave that the master is at IRQ2
            out SLAVE_PIC_DATA_PORT,al

            ;send ICW4 to data ports: to finish initialization and set 80x86 mode
            mov al,00000001b                                        ;set bit0: sets 80x86 mode
            out MASTER_PIC_DATA_PORT,al                             ;write to data ports
            out SLAVE_PIC_DATA_PORT,al

            mov al,0x0                                              ;unmasking all IRQs
            out MASTER_PIC_DATA_PORT,al
            out SLAVE_PIC_DATA_PORT,al


        popaq
        ret


    set_irq_mask:
        pushaq                              ;Save general purpose registers on the stack
        ; This function need to be written by you.


            mov rdx,MASTER_PIC_DATA_PORT                        ;master data port
            cmp rdi,15                                          ;if not in the first 15 IRQs, then leave
            jg .out
            cmp rdi,8                                           ;if in the first 8 interrupts, then go to master
            jl .master
            sub rdi,8                                           ;else (slave), subtract 8 to get port number from 0 to 7 on the slave
            mov rdx,SLAVE_PIC_DATA_PORT                         ;slave data port
            .master:                                            ;at this label, all port numbers are 0-7, for both master and slave
            in eax,dx                                           ;read interrupt mask register
            mov rcx,rdi                                         ;copy port number to rcx     
            mov rdi,0x1                                         ;move 1 to rdi
            shl rdi,cl                                          ;shift the 1 left to the bit number equal to the port number we want to mask
            or rax,rdi                                          ;set this bit in the IMR
            out dx,eax                                          ;write to data port to update IMR after masking


        .out:    
        popaq
        ret


    clear_irq_mask:
        pushaq
        ; This function need to be written by you.


            mov rdx,MASTER_PIC_DATA_PORT                        ;master data port
            cmp rdi,15                                          ;if not in the first 15 IRQs, then leave
            jg .out
            cmp rdi,8                                           ;if in the first 8 interrupts, then go to master
            jl .master
            sub rdi,8                                           ;else (slave), subtract 8 to get port number from 0 to 7 on the slave
            mov rdx,SLAVE_PIC_DATA_PORT                         ;slave data port
            .master:                                            ;at this label, all port numbers are 0-7, for both master and slave
            in eax,dx                                           ;read interrupt mask register
            mov rcx,rdi                                         ;copy port number to rcx     
            mov rdi,0x1                                         ;move 1 to rdi
            shl rdi,cl                                          ;shift the 1 left to the bit number equal to the port number we want to unmask
            not rdi                                             ;negate rdi to have 1s in all bits except the bit corresponding to the port we want to unmask (would be zero)
            and rax,rdi                                         ;and with IMR to zero out this bit
            out dx,eax                                          ;write to data port to update IMR after unmasking

        .out:    
        popaq
        ret
