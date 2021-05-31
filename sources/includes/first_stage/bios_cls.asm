;************************************** bios_cls.asm **************************************      
      bios_cls:   ; A routine to initialize video mode 80x25 which also clears the screen
            ; This function need to be written by you.
      pusha ; this will push all registers in the stack in 16-bit real mode
      mov ah, 0x0 ; To set the video function (As required, I need to pass ah as zero)
      mov al , 0x3 ; I will set the screen using 0x3.
      int 0x10 ; using interrupt to pass the ah and al parameters and clear the screen. 
      popa ; This will pop all registers from the stack in 16-bit mode.
      ret