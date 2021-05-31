%define VIDEO_BUFFER_SEGMENT                    0xB000
%define VIDEO_BUFFER_OFFSET                     0x8000
%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000
%define VIDEO_SIZE      0X0FA0    ; 25*80*2
    video_cls_16:
            pusha                                   ; Save all general purpose registers on the stack

                  ; This function need to be written by you.

            xor ebx, ebx                              ; zero out the edx
            mov edx, VIDEO_BUFFER_EFFECTIVE_ADDRESS  
            mov ax, 0x1020                           ; If we use 0x10 alone, we will have black- 
                                                ; According to the manual, we can use 0x1020 to make it blue 
                                                ; 0x2020 green and so on.
            clear:                               ; loop for clearing the screen

            mov word[edx], ax                         ; The value of ax will be in the memory of VIDEO_BUFFER_EFFECTIVE_ADDRESS
            add ebx,2                                ; inc. edx by 2 to compare with the video size
            add edx,2                                ; inc. ecx by since we know that the screen is by each 2 bytes. 
            cmp ebx,VIDEO_SIZE                       ; comparing edx with the max_video size (25*80*2)
            jl clear                             ; loop again if we did not reach the max_video size.




            popa                                ; Restore all general purpose registers from the stack
            ret

