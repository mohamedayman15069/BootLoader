;************************************** first_stage_data.asm **************************************
boot_drive db 0x0 ; An address to have boot_drive 
lba_sector dw 0x1 ; the number of lba_sector 

spt dw 0x12       ; An address that contains the sector/track 
hpc dw 0x2        ; An address that contains the head/cylinder
; The three addresses that I will need for having the Cylidner, Head, and Sector. 
Cylinder dw 0x0
Head db 0x0
Sector dw 0x0

; Some addresses containing some messages needed in the program.
disk_error_msg db 'Disk Error', 13, 10, 0
fault_msg db 'Unknown Boot Device', 13, 10, 0
booted_from_msg db 'Booted from ', 0
floppy_boot_msg db 'Floppy', 13, 10, 0
drive_boot_msg db 'Disk', 13, 10, 0
greeting_msg db '1st Stage Loader', 13, 10, 0
second_stage_loaded_msg db 13,10,'2nd Stage loaded, press any key to resume!', 0
dot db '.',0
newline db 13,10,0
disk_read_segment dw 0
disk_read_offset dw 0