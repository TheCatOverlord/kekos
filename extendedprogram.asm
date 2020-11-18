
jmp EnterProtectedMode

; GDT
%include "gdt.asm"
%include "printf.asm"
%include "EnableA20.asm"

EnterProtectedMode:
    call EnableA20
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp codeseg:ClearPipe

[bits 32]

%include "SimplePaging.asm"
%include "cpuid.asm"
ClearPipe:
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    jmp StartProtectedMode

StartProtectedMode:
    call Detectcpuid
    call DetectLongMode
    call SetupIdentityPaging
    call EditGDT
    jmp codeseg:Start64bit

[bits 64]
[extern _start]
Start64bit:
    mov edi, 0xb8000
    mov rax, 0x1f201f201f201f20
    mov ecx, 500
    rep stosq
    call _start
    jmp $

times 2048-($-$$) db 0 ; pad it out to 2048 byte (2 sectors)