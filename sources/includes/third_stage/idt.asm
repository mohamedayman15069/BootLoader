%define IDT_BASE_ADDRESS            0x40000 ;  0x4000:0x0000 which is free
%define IDT_HANDLERS_BASE_ADDRESS   0x41000 ;  0x4000:0x1000 which is free
%define IDT_P_KERNEL_INTERRUPT_GATE 0x8E    ;  1 00 0 1110 -> P DPL Z Int_Gate

struc IDT_ENTRY
.base_low         resw  1
.selector         resw  1
.reserved_ist     resb  1
.flags            resb  1
.base_mid         resw  1
.base_high        resd  1
.reserved         resd  1
endstruc

ALIGN 4                 ; Make sure that the IDT starts at a 4-byte aligned address    
IDT_DESCRIPTOR:         ; The label indicating the address of the IDT descriptor to be used with lidt
      .Size dw    0x1000                   ; Table size is zero (word, 16-bit) -> 256 x 16 bytes
      .Base dq    IDT_BASE_ADDRESS         ; Table base address is NULL (Double word, 64-bit)

load_idt_descriptor:
    pushaq
    lidt [IDT_DESCRIPTOR]
    popaq
    ret


init_idt:         ; Intialize the IDT which is 256 entries each entry corresponds to an interrupt number
                  ; Each entry is 16 bytes long
                  ; Table total size if 4KB = 256 * 16 = 4096 bytes
      pushaq
          mov rdi, IDT_BASE_ADDRESS
          mov rcx, 512          ;rcx contains the number of repetitions that will be done by the rep stosq instruction
                                ;512 is double the amount of entries
          xor rax,rax           ;set rax to zero
          cld                   ;direction flag set to zero, so edi will be incremented by the next instruction
          rep stosq             ;store eax at address rdi and repeat for 512 times, incrementing edi by 8 every time (half an entry)

          popaq
          ret


register_idt_handler: ; Store a handler into the handler array
                        ; RDI contains the interrupt number
                        ; RSI contains the handler address
      pushaq            ; Save all general purpose registers

          shl rdi,3                                          ;shift interrupt number left by 3 (= multiply by 8) to get the index in the handler array
          mov [rdi+IDT_HANDLERS_BASE_ADDRESS],rsi            ;add the index to the base address of the handlers array to get the location in the array 
          call load_idt_descriptor
      popaq             ; Restore general purpose registers
      ret


setup_idt:
      pushaq
            ; This function need to be written by you.
        mov rdi ,0
        mask16:
            cmp rdi,16
            je continue1
            call set_irq_mask 
            inc rdi
	    jmp mask16
        continue1:
            call configure_pic                    
            call setup_idt_irqs 
            call setup_idt_exceptions
            call configure_pit                  
        mov rdi ,0
        clear_mask:
            cmp rdi,16
            je .done
            call clear_irq_mask 
            inc rdi
	    jmp clear_mask
      .done:
      popaq
      ret

setup_idt_entry:  ; Setup and interrupt entry in the IDT
                  ; RDI: Interrupt Number
                  ; RSI: Address of the handler
        pushaq
            ; This function need to be written by you.        
 
          shl rdi,4                                                      ;each entry is 16 bytes, so Interrupt Number * 16 = offset in IDT 
          add rdi,IDT_BASE_ADDRESS                                       ;offset in IDT + base address of IDT = address of entry
          mov rax,rsi                                                    ;copy handler address to rax
          and ax,0xFFFF                                                  ;extract the first 16 bits of the address to place in IDT
          mov [rdi+IDT_ENTRY.base_low],ax                                ;place 16 bits in IDT
          mov rax,rsi                                                    ;copy handler address to rax
          shr rax, 16                                                    ;shift right 16 bits to get the next 16 bits of the address
          and ax,0xFFFF                                                  ;extract next 16 bits from address
          mov [rdi+IDT_ENTRY.base_mid],ax                                ;place 16 bits in IDT
          mov rax,rsi                                                    ;copy handler address to rax
          shr rax, 32                                                    ;shift right 32 to get the last 32 bits of the address
          and eax,0xFFFFFFFF                                             ;extract 32 bits from address
          mov [rdi+IDT_ENTRY.base_high],eax                              ;move last 32 bits into IDT entry
          mov [rdi+IDT_ENTRY.selector],byte 0x8                          ;0x8 is the code segment in the GDT
          mov [rdi+IDT_ENTRY.reserved_ist],byte 0x0                      ;zeros in the reserved list
          mov [rdi+IDT_ENTRY.reserved],dword 0x0                         ;zeros in reserved last 32 bits
          mov [rdi+IDT_ENTRY.flags],byte IDT_P_KERNEL_INTERRUPT_GATE     ;0x8E, 1 00 0 1110 -> present, ring 0, 0, type 1110(interrupt gate)
        
        popaq
        ret

idt_default_handler:
      pushaq
      ;This is the default

      popaq
      ret

isr_common_stub:
      pushaq                  ; Save all general purpose registers
      
      cli                                       ;disable interrupts
      mov rdi,rsp                               ;move the stack address to rdi
      mov rax,[rdi+120]                         ;get the interrupt number that was pushed by the macro onto the stack
      shl rax,3                                 ;shift interrupt number left by 3 (= multiply by 8) to get the index in the handler array
      mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax]   ;add the index to the base address of the handlers array to get the address of the routine
      cmp rax,0                                 ;if NULL (no registered routine)
      je .call_default                          ;call the default handler
      call rax                                  ;if not null, call the routine in that location
      jmp .out
      .call_default:
      call idt_default_handler                  ;call the default handler

      .out:
      popaq                   ; Restore all the general purpose registers
      add rsp,16              ; Make up for the interrupt number and the error code pushed by the macros
      sti                     ; Enable interrupts -> not necessary, why:
      iretq           ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP


irq_common_stub:
      pushaq                  ; Save all general purpose registers
      ; This function need to be written by you.

      cli                                       ;disable interrupts
      mov rdi,rsp                               ;move the stack address to rdi
      mov rax,[rdi+120]                         ;get the interrupt number that was pushed by the macro onto the stack
      shl rax,3                                 ;shift interrupt number left by 3 (= multiply by 8) to get the index in the handler array
      mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax]   ;add the index to the base address of the handlers array to get the address of the routine
      cmp rax,0                                 ;if NULL (no registered routine)
      je .call_default                          ;call the default handler
      call rax                                  ;if not null, call the routine in that location

      mov al,0x20                               ;send to PIC: End of Interrupt
      out MASTER_PIC_COMMAND_PORT,al            ;send to master
      out SLAVE_PIC_COMMAND_PORT,al             ;send to slave
      jmp .out
      .call_default:
      call idt_default_handler                  ;call the default handler

      .out:
      popaq                   ; Restore all the general purpose registers
      add rsp,16              ; Make up for the interruot number and the error code pushed by the macros
      sti                     ; Enable interrupts -> not necessary, why: 
      iretq           ; pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP



setup_idt_irqs:
      pushaq
      ; This function need to be written by you.

        mov rsi,irq0
        mov rdi,32
        call setup_idt_entry
        mov rsi,irq1
        mov rdi,33
        call setup_idt_entry
        mov rsi,irq2
        mov rdi,34
        call setup_idt_entry
        mov rsi,irq3
        mov rdi,35
        call setup_idt_entry
        mov rsi,irq4
        mov rdi,36
        call setup_idt_entry
        mov rsi,irq5
        mov rdi,37
        call setup_idt_entry
        mov rsi,irq6
        mov rdi,38
        call setup_idt_entry
        mov rsi,irq7
        mov rdi,39
        call setup_idt_entry
        mov rsi,irq8
        mov rdi,40
        call setup_idt_entry
        mov rsi,irq9
        mov rdi,41
        call setup_idt_entry
        mov rsi,irq10
        mov rdi,42
        call setup_idt_entry
        mov rsi,irq11
        mov rdi,43
        call setup_idt_entry
        mov rsi,irq12
        mov rdi,44
        call setup_idt_entry
        mov rsi,irq13
        mov rdi,45
        call setup_idt_entry
        mov rsi,irq14
        mov rdi,46
        call setup_idt_entry
        mov rsi,irq15
        mov rdi,47
        call setup_idt_entry
        

      popaq
      ret


setup_idt_exceptions:
      pushaq
      ; This function need to be written by you.




        mov rsi,isr0 
        mov rdi,0
        call setup_idt_entry
        mov rsi,isr1 
        mov rdi,1
        call setup_idt_entry
        mov rsi,isr2 
        mov rdi,2
        call setup_idt_entry
        mov rsi,isr3 
        mov rdi,3
        call setup_idt_entry
        mov rsi,isr4 
        mov rdi,4
        call setup_idt_entry
        mov rsi,isr5 
        mov rdi,5
        call setup_idt_entry
        mov rsi,isr6 
        mov rdi,6
        call setup_idt_entry
        mov rsi,isr7 
        mov rdi,7
        call setup_idt_entry
        mov rsi,isr8
        mov rdi,8
        call setup_idt_entry
        mov rsi,isr9 
        mov rdi,9
        call setup_idt_entry
        mov rsi,isr10 
        mov rdi,10
        call setup_idt_entry
        mov rsi,isr11 
        mov rdi,11
        call setup_idt_entry
        mov rsi,isr12 
        mov rdi,12
        call setup_idt_entry
        mov rsi,isr13 
        mov rdi,13
        call setup_idt_entry
        mov rsi,isr14 
        mov rdi,14
        call setup_idt_entry
        mov rsi,isr15 
        mov rdi,15
        call setup_idt_entry
        mov rsi,isr16 
        mov rdi,16
        call setup_idt_entry
        mov rsi,isr17 
        mov rdi,17
        call setup_idt_entry
        mov rsi,isr18 
        mov rdi,18
        call setup_idt_entry
        mov rsi,isr19 
        mov rdi,19
        call setup_idt_entry
        mov rsi,isr20 
        mov rdi,20
        call setup_idt_entry
        mov rsi,isr21 
        mov rdi,21
        call setup_idt_entry
        mov rsi,isr22 
        mov rdi,22
        call setup_idt_entry
        mov rsi,isr23 
        mov rdi,23
        call setup_idt_entry
        mov rsi,isr24 
        mov rdi,24
        call setup_idt_entry
        mov rsi,isr25 
        mov rdi,25
        call setup_idt_entry
        mov rsi,isr26 
        mov rdi,26
        call setup_idt_entry
        mov rsi,isr27 
        mov rdi,27
        call setup_idt_entry
        mov rsi,isr28 
        mov rdi,28
        call setup_idt_entry
        mov rsi,isr29 
        mov rdi,29
        call setup_idt_entry
        mov rsi,isr30 
        mov rdi,30
        call setup_idt_entry
        mov rsi,isr31 
        mov rdi,31
        call setup_idt_entry


      popaq
      ret

; This macro will be used with exceptions that does not push error codes on the stack
; NOtice that we push first a zero on the stack to make it consistent with other excptions
; that pushes an error code on the stack
%macro ISR_NOERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword 0
      push qword %1
      jmp isr_common_stub
%endmacro

; This macro will be used with exceptions that push error codes on the stack
; Notice that we here push only the interrupt number which is passed as a parameter to the macro
%macro ISR_ERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword %1
      jmp isr_common_stub
%endmacro


; This macro will be used with the IRQs generated by the PIC
%macro IRQ 2
  global irq%1
  irq%1:
      cli
      push qword 0
      push qword %2
      jmp irq_common_stub
%endmacro



ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31


IRQ   0,    32
IRQ   1,    33
IRQ   2,    34
IRQ   3,    35
IRQ   4,    36
IRQ   5,    37
IRQ   6,    38
IRQ   7,    39
IRQ   8,    40
IRQ   9,    41
IRQ  10,    42
IRQ  11,    43
IRQ  12,    44
IRQ  13,    45
IRQ  14,    46
IRQ  15,    47


isr255:
        iretq