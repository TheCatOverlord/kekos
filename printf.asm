; Function that prints a string from the bx register 
; printf:
;     pusha
;     mov ah, 0x0e
;     printf_loop:
;         cmp [bx], byte 0
;         je printf_exit
;         mov al, [bx]
;         int 0x10
;         inc bx
;         jmp printf_loop
;     printf_exit:
;         popa
;         ret

; Function that prints a string from the si register
printf:
    pusha                    ; Push Everything to the stack
    str_loop:                ; Label the loop
        mov al, [si]         ; Mov the byte at si to al
        cmp al, 0            ; cmp that byte with 0
        jne print_char       ; if the data in al isnt zero jmp to print_char
        popa                 ; Pop everything off the stack
        ret                  ; Return
    print_char:              ; Label for print char
        mov ah, 0x0e         ; mov 0x0e into ah (to tell to print a char on int)
        int 0x10             ; int 0x10 to print the char in al
        inc si               ; inc si
        jmp str_loop         ; jmp back to the str so can print the next char


; Function to print a hex number (whatevers in dx) to the screen
printh:
    mov bx, dx
    shr bx, 12
    mov bx, [bx + HEX_TABLE]
    mov [HEX_PATTERN + 2], bl

    mov bx, dx
    shr bx, 8
    and bx, 0x000f
    mov bx, [bx + HEX_TABLE]
    mov [HEX_PATTERN + 3], bl
    
    mov bx, dx
    shr bx, 4
    mov bx, [bx + HEX_TABLE]
    mov [HEX_PATTERN + 4], bl
    
    mov bx, dx
    and bx, 0x000f
    mov bx, [bx + HEX_TABLE]
    mov [HEX_PATTERN + 5], bl
    
    mov si, HEX_PATTERN
    call printf
    ret

HEX_PATTERN: db '0x****', 0x0a, 0x0d, 0x00
HEX_TABLE: db '0123456789abcdef'

welcomeString: ; Welcome message string
    db '[INFO] Welcome to the KekOS bootloader!', 0x0a, 0x0d, 0x0
