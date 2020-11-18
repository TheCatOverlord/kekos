[org 0x7c00]

; Setup the stack
; (Guessing you cant write directly into the sp register,
;  so instead using the bp register as a work around)
mov bp, 0x7c00          ; Move the memory address of the start of the program into the bp register
mov sp, bp              ; Set the stack pointer to the start of the program

; Move the boot disk id into the BOOT_DISK varible
; On boot the boot disk id is in register dl
mov [BOOT_DISK], dl

mov si, welcomeString   ; Move the memory location of the welcome string into bx

call printf             ; Call printf to print the welcome message


call readDisk           ; Read the rest of the disk and put it into memory

mov si, test
call printf

jmp PROGRAM_SPACE       ; Jump to PROGRAM_SPACE

jmp $

; Include the print functions
%include "printf.asm"
; Include the diskread functions
%include "diskread.asm"

test:
    db 'Got here', 0x0a, 0x0d, 0x00

times 510-($-$$) db 0   ; Pad the rest of the first sector
dw 0xaa55               ; Magic number to declare this sector as boot