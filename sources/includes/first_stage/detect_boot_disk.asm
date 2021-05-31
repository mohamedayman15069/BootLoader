;************************************** detect_boot_disk.asm **************************************      
      detect_boot_disk: ; A subroutine to detect the the storage device number of the device we have booted from
                        ; After the execution the memory variable [boot_drive] should contain the device number
                        ; Upon booting the bios stores the boot device number into DL
            pusha ; take a screenshot of all registers and pushing it into the stack 
            mov si, fault_msg ; As sort of taking precutions, I will put in si the address to say that the disk number is not detected.
            xor ax,ax           ; For reseting the disk drive, AH = 0 
            int 13h           ;      This Bios interrupt is to detect the disk drive number and put it in al 
            jc .exit_with_error ; If the flag is 1(set), there is a problem during bios interrupt. 
            mov si,booted_from_msg ; I will put the address contain "booted From" in si 
            call bios_print         ;Printing "Booted_from"
            mov [boot_drive], dl ; Now the number will be put in boot_drive instead of zero 
            cmp dl,0          ; According to the documentation, if dl is zero, it is floppy 
            je .floppy
            call load_boot_drive_params ; else call the function load_boot_drive_params
            mov si,drive_boot_msg  ; Now I will need to store the address of the string drive_boot_msg for printing
            jmp .finish ; go to this function for calling bios_print 


                  .floppy: 
                        mov si,floppy_boot_msg ; Here I will put in si "Floppy" message
                        jmp .finish

                  .exit_with_error:
                        jmp hang
                  .finish: 
                        call bios_print
                        popa ; This will restore what is in the stack to the registers.
            ret