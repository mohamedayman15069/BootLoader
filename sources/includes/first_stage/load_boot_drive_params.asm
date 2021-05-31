;************************************** load_boot_drive_params.asm **************************************
      load_boot_drive_params: ; A subroutine to read the [boot_drive] parameters and update [hpc] and [spt]
           pusha        ; Again, I will push the all register values in the stack 
           xor di,di
           mov es , di ; I need [es:di] = [0x0000000:0x0000000000] to overcome some bugs regarding BIOS
           mov ah, 0x8  ; we need to add in ah 8 to be able to fetch the disk parameters
           mov dl, [boot_drive]     ; to add the last boot_drive ( if floppy, bootdrive content is zero)
           int 0x13                 ; interrupt now to load the parameters "MASS Storatge ACCESS"
            inc dh                  ; the head number will be incremented.
            mov word[hpc],0x0       ; Remember that hpc is for the number of head/cylinders
            mov [hpc+1],dh           ; I will need to store the number of heads/cylinders in the lower part of hpc
            and cx,0000000000111111b ; This is an optimization that I will not need to know which cylinder: as each cylinder will not exceed 64 bits
                                          ; However, I care for knowing the numberr of sectors/track(first 6 bits)
            mov word[spt],cx           ; Put cx in the content of the address of spt.
            popa 
            ret

