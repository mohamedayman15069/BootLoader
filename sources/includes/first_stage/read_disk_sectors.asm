 ;************************************** read_disk_sectors.asm **************************************
      read_disk_sectors: ; This function will read a number of 512-sectors stored in DI 
                         ; The sectors should be loaded at the address starting at [disk_read_segment:disk_read_offset]
          pusha ; Put the all registers in the stack as a screenshot
          add di , [lba_sector] ; I will add on di the lba_sector number 
                                   ; To be able to compare between it and di in a loop 
                                   ; I will make di in the beginning 8 since I will not 
                                   ; exceed 8 sectors 
          mov ax,[disk_read_segment]  ; I will need to add in the ax the segment of the disk(ES)
          mov es , ax         ; Now I have the segment address in es 
          add bx,[disk_read_offset] ; this is for the offset [es:bx]
          mov dl,[boot_drive]       ; I will need the boot_drive (whether it is floppy or not)
          ; Now I will loop on each sector 
          .read_sector_loop:
           call lba_2_chs          ; convert the LBA_ADD to CHS 
           mov ah, 0x2        ; This is for interrupt : read from the sector
           mov al,0x1         ; with condition that I will add only one sector 
           ; Now I need to add the cylinder number and sector in CX 
           mov cx, [Cylinder] ; Moving with the cylinder 
           shl cx,0x8  ; I will shift cx to the cx by 8 to put the cylinder at the beginning.
          or cx,[Sector]      ; ORingto put the sector in the beginning 
          mov dh,[Head]  ; Adding the head number in dh 
          int 0x13       ; The Read interrupt
          jc .read_disk_error ; If the flag is set , go out of the loop and mention an issue
          mov si,dot     ; Print dot for succeeding in reading 
          call bios_print 
          inc word [lba_sector]    ; inc the lba_sector 
          add bx,0x200   ; the following address (512Byte)
          cmp word[lba_sector],di  ; compare if lba_sector exceeded the di (8)
          jl .read_sector_loop        ; complete the loop in case the flag has not set yet.
          jmp .finish 
          
          .read_disk_error:
          mov si,disk_error_msg ; Put in the si the address of the string that contains an error message
          call bios_print          ; print this message
          jmp hang       ; Do hang again 
          .finish:
          popa ; 
          ret
