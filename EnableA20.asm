EnableA20:
    ; Check to see if the a20 gate is supported
    mov ax, 0x2403
    int 0x15
    jb a20ns
    cmp ah, 0
    jnz a20ns

    ; Get the status of the gate
    mov ax, 0x2402
    int 0x15
    jb a20failed
    cmp ah, 0
    jnz a20failed

    cmp al, 1
    jz a20activated

    ; Activate the a20 gate
    mov ax, 0x2401
    int 0x15
    jb a20failed
    cmp ah, 0
    jnz a20failed

    mov si, a20activatedstring
    call printf
    ; return to continue enabling protected mode
    a20end:
    ret

a20activated:
    mov si, a20activatedstring
    call printf
    jmp a20end

a20activatedstring:
    db '[INFO] A20 Activated.', 0x0a, 0x0d, 0x00

a20failed:
    mov si, a20failedstring
    call printf
    jmp $
a20failedstring:
    db '[ERROR] Failed to get status or enable the a20 line.', 0x0a, 0x0d, 0x00

a20ns:
    mov si, a20nsstring
    call printf
    jmp $
a20nsstring:
    db '[ERROR] A20 gate is not supported.', 0x0a, 0x0d, 0x00
