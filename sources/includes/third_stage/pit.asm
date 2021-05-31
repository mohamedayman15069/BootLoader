%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43



pit_counter dq    0x0               ; A variable for counting the PIT ticks
print_pit_counter   dq    0x0

handle_pit:                               
      pushaq
            mov rdi,[pit_counter]         ;value to be printed in hexa
           ;I want to check whether 1000 interrupts are done or not to print every 1000 int.
            cmp qword[print_pit_counter],1000   
            jne .continue
          ;  push qword [start_location]
           ; mov qword[start_location],0x0
            call bios_print_hexa     ;print pit_counter in hexa
         ;   pop qword [start_location]
            mov qword[print_pit_counter],0x0
	    ;mov rsi,newline
           ; call video_print
   .continue:
      inc qword [pit_counter]       ;Increment the pit_counter
      inc qword [print_pit_counter]
      popaq
      ret


configure_pit:
    pushaq
      mov rdi,32                    ;I need to connect the PIT to its location ind the idt, so connecting it Interrupt 32 IRQ0
      mov rsi, handle_pit           ;move handle_pit code that will run by firing pit into rsi
      call register_idt_handler     ;Invoke handle_pit through IRQ32
      mov al,00110110b              ;set the 8 bits of the command reg--> channel 0, both lo/hi writing,mode 3, and we use binary bits
      out PIT_COMMAND,al            ;out these 8 bits writing them to the PIT command
      xor rdx,rdx                   
      mov rcx,50                    
      mov rax,1193180               ;move the oscillator' frequency into rax
      div rcx                       ;divide the frequency by 50...for 50 interrupts per second
      out PIT_DATA0,al              ;write the quotient in the lower bytes in the data port 0
      mov al,ah                     
      out PIT_DATA0,al              ;write the quotient in the higher bytes to the data port 0
    popaq
    ret
