GDT64:                          ; the global descriptor table
 .Null: equ $ - GDT64           ; identify null into the null descriptor
        dw 0                    ; the lower 2 limit bytes 
        dw 0                    ; the lower 2 base bytes 
        db 0                    ; the middle base byte 
        db 0                    ; to access mem
        db 0                    ; high flags to check mem
        db 0                    ; the high base byte 
 .Code: equ $ - GDT64           ; the kernel code descriptor.
        dw 0                    ; the lower 2 limit bytes 
        dw 0                    ; the lower 2 base bytes 
        db 0                    ; the middle base byte 
        db 10011000b            ; Access byte -->set present bit/set 2 bits into 00 in ring 0(kernell)/Ex-->eecuting the code 
        db 00100000b            ; Flags L-->high for long mode
        db 0                    ; higher base byte 
 .Data: equ $ - GDT64           ; the kernel data descriptor.
        dw 0                    ; the lower 2 limit bytes 
        dw 0                    ; the lower 2 base bytes 
        db 0                    ; the middle base byte
        db 10010011b            ; Access-->set present bit/set 2 bits into 00 in ring 0/read andwrite bits
        db 00000000b            ; flags
        db 0                    ; the high base byte 
        
ALIGN 4                         ; gdt must be 4 aligned
 dw 0                           ; padding 
.Pointer:                       ; the GDT-pointer
 dw $ - GDT64 - 1               ; the limit of gdt eqals 16 bit 
 dd GDT64                       ; the 32 base address..will be extended 

 
