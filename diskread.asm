PROGRAM_SPACE equ 0x7e00    ; The memory location of where the data is loaded
                            ; 0x7c00 + 512

readDisk:
    mov bx, PROGRAM_SPACE   ; Mov the memory location into bx (this is where the data will start to write)
    mov ah, 0x02            ; mov 0x02 into ah to declare this as a boot read int
    mov al, 2               ; The amount of sectors to load
    mov dl, 0x80            ; This is supposed to be "BOOT_DISK" but for some reason that doesnt work
                            ; 0x80 = Hard disk 0x00 = Floppy
                            ; dl is the disk to read from
    mov ch, 0x00            ; Which cylinder head to use (HDD stuff)
    mov dh, 0x00            ; Head number (more hdd stuff)
    mov cl, 0x02            ; Sector number
    int 0x13                ; Interupt call 0x13 to read the disk
    jc diskReadFailed       ; Jump to diskReadFailed if the carry flag is set

    mov si, diskReadSuccessful
    call printf
    ret                     ; Return back to the where the function was called

BOOT_DISK: ; Location to store the boot disk id
    db 0

DiskReadErrorString: ; String to store a disk read failed message
    db '[ERROR] Disk Read Failed.', 0x0a, 0x0d, 0x00
    
diskReadSuccessful:
    db '[INFO] Successfully read from the disk!', 0x0a , 0x0d, 0x00

diskReadFailed: ; Function to Print the diskreadfailed string to the screen
    mov si, DiskReadErrorString ; mov the string pointer into si
    call printf                 ; Call printf
    jmp $                    ; jmp to hang 