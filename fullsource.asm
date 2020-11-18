     1                                  [org 0x7c00]
     2                                  
     3                                  ; Setup the stack
     4                                  ; (Guessing you cant write directly into the sp register,
     5                                  ;  so instead using the bp register as a work around)
     6 00000000 BD007C                  mov bp, 0x7c00          ; Move the memory address of the start of the program into the bp register
     7 00000003 89EC                    mov sp, bp              ; Set the stack pointer to the start of the program
     8                                  
     9                                  ; Move the boot disk id into the BOOT_DISK varible
    10                                  ; On boot the boot disk id is in register dl
    11 00000005 8816[C800]              mov [BOOT_DISK], dl
    12                                  
    13 00000009 BE[8400]                mov si, welcomeString   ; Move the memory location of the welcome string into bx
    14                                  
    15 0000000C E80E00                  call printf             ; Call printf to print the welcome message
    16                                  
    17                                  
    18 0000000F E89C00                  call readDisk           ; Read the rest of the disk and put it into memory
    19                                  
    20 00000012 BE[1701]                mov si, test
    21 00000015 E80500                  call printf
    22                                  
    23 00000018 E9(007E)                jmp PROGRAM_SPACE       ; Jump to PROGRAM_SPACE
    24                                  
    25 0000001B EBFE                    jmp $
    26                                  
    27                                  ; Include the print functions
    28                                  %include "printf.asm"
    29                              <1> ; Function that prints a string from the bx register 
    30                              <1> ; printf:
    31                              <1> ;     pusha
    32                              <1> ;     mov ah, 0x0e
    33                              <1> ;     printf_loop:
    34                              <1> ;         cmp [bx], byte 0
    35                              <1> ;         je printf_exit
    36                              <1> ;         mov al, [bx]
    37                              <1> ;         int 0x10
    38                              <1> ;         inc bx
    39                              <1> ;         jmp printf_loop
    40                              <1> ;     printf_exit:
    41                              <1> ;         popa
    42                              <1> ;         ret
    43                              <1> 
    44                              <1> ; Function that prints a string from the si register
    45                              <1> printf:
    46 0000001D 60                  <1>     pusha                    ; Push Everything to the stack
    47                              <1>     str_loop:                ; Label the loop
    48 0000001E 8A04                <1>         mov al, [si]         ; Mov the byte at si to al
    49 00000020 3C00                <1>         cmp al, 0            ; cmp that byte with 0
    50 00000022 7502                <1>         jne print_char       ; if the data in al isnt zero jmp to print_char
    51 00000024 61                  <1>         popa                 ; Pop everything off the stack
    52 00000025 C3                  <1>         ret                  ; Return
    53                              <1>     print_char:              ; Label for print char
    54 00000026 B40E                <1>         mov ah, 0x0e         ; mov 0x0e into ah (to tell to print a char on int)
    55 00000028 CD10                <1>         int 0x10             ; int 0x10 to print the char in al
    56 0000002A 46                  <1>         inc si               ; inc si
    57 0000002B EBF1                <1>         jmp str_loop         ; jmp back to the str so can print the next char
    58                              <1> 
    59                              <1> 
    60                              <1> ; Function to print a hex number (whatevers in dx) to the screen
    61                              <1> printh:
    62 0000002D 89D3                <1>     mov bx, dx
    63 0000002F C1EB0C              <1>     shr bx, 12
    64 00000032 8B9F[7400]          <1>     mov bx, [bx + HEX_TABLE]
    65 00000036 881E[6D00]          <1>     mov [HEX_PATTERN + 2], bl
    66                              <1> 
    67 0000003A 89D3                <1>     mov bx, dx
    68 0000003C C1EB08              <1>     shr bx, 8
    69 0000003F 83E30F              <1>     and bx, 0x000f
    70 00000042 8B9F[7400]          <1>     mov bx, [bx + HEX_TABLE]
    71 00000046 881E[6E00]          <1>     mov [HEX_PATTERN + 3], bl
    72                              <1>     
    73 0000004A 89D3                <1>     mov bx, dx
    74 0000004C C1EB04              <1>     shr bx, 4
    75 0000004F 8B9F[7400]          <1>     mov bx, [bx + HEX_TABLE]
    76 00000053 881E[6F00]          <1>     mov [HEX_PATTERN + 4], bl
    77                              <1>     
    78 00000057 89D3                <1>     mov bx, dx
    79 00000059 83E30F              <1>     and bx, 0x000f
    80 0000005C 8B9F[7400]          <1>     mov bx, [bx + HEX_TABLE]
    81 00000060 881E[7000]          <1>     mov [HEX_PATTERN + 5], bl
    82                              <1>     
    83 00000064 BE[6B00]            <1>     mov si, HEX_PATTERN
    84 00000067 E8B3FF              <1>     call printf
    85 0000006A C3                  <1>     ret
    86                              <1> 
    87 0000006B 30782A2A2A2A0A0D00  <1> HEX_PATTERN: db '0x****', 0x0a, 0x0d, 0x00
    88 00000074 303132333435363738- <1> HEX_TABLE: db '0123456789abcdef'
    88 0000007D 39616263646566      <1>
    89                              <1> 
    90                              <1> welcomeString: ; Welcome message string
    91 00000084 5B494E464F5D205765- <1>     db '[INFO] Welcome to the KekOS bootloader!', 0x0a, 0x0d, 0x0
    91 0000008D 6C636F6D6520746F20- <1>
    91 00000096 746865204B656B4F53- <1>
    91 0000009F 20626F6F746C6F6164- <1>
    91 000000A8 6572210A0D00        <1>
    29                                  ; Include the diskread functions
    30                                  %include "diskread.asm"
    31                              <1> PROGRAM_SPACE equ 0x7e00    ; The memory location of where the data is loaded
    32                              <1>                             ; 0x7c00 + 512
    33                              <1> 
    34                              <1> readDisk:
    35 000000AE BB007E              <1>     mov bx, PROGRAM_SPACE   ; Mov the memory location into bx (this is where the data will start to write)
    36 000000B1 B402                <1>     mov ah, 0x02            ; mov 0x02 into ah to declare this as a boot read int
    37 000000B3 B002                <1>     mov al, 2               ; The amount of sectors to load
    38 000000B5 B280                <1>     mov dl, 0x80            ; This is supposed to be "BOOT_DISK" but for some reason that doesnt work
    39                              <1>                             ; 0x80 = Hard disk 0x00 = Floppy
    40                              <1>                             ; dl is the disk to read from
    41 000000B7 B500                <1>     mov ch, 0x00            ; Which cylinder head to use (HDD stuff)
    42 000000B9 B600                <1>     mov dh, 0x00            ; Head number (more hdd stuff)
    43 000000BB B102                <1>     mov cl, 0x02            ; Sector number
    44 000000BD CD13                <1>     int 0x13                ; Interupt call 0x13 to read the disk
    45 000000BF 724E                <1>     jc diskReadFailed       ; Jump to diskReadFailed if the carry flag is set
    46                              <1> 
    47 000000C1 BE[E500]            <1>     mov si, diskReadSuccessful
    48 000000C4 E856FF              <1>     call printf
    49 000000C7 C3                  <1>     ret                     ; Return back to the where the function was called
    50                              <1> 
    51                              <1> BOOT_DISK: ; Location to store the boot disk id
    52 000000C8 00                  <1>     db 0
    53                              <1> 
    54                              <1> DiskReadErrorString: ; String to store a disk read failed message
    55 000000C9 5B4552524F525D2044- <1>     db '[ERROR] Disk Read Failed.', 0x0a, 0x0d, 0x00
    55 000000D2 69736B205265616420- <1>
    55 000000DB 4661696C65642E0A0D- <1>
    55 000000E4 00                  <1>
    56                              <1>     
    57                              <1> diskReadSuccessful:
    58 000000E5 5B494E464F5D205375- <1>     db '[INFO] Successfully read from the disk!', 0x0a , 0x0d, 0x00
    58 000000EE 636365737366756C6C- <1>
    58 000000F7 792072656164206672- <1>
    58 00000100 6F6D20746865206469- <1>
    58 00000109 736B210A0D00        <1>
    59                              <1> 
    60                              <1> diskReadFailed: ; Function to Print the diskreadfailed string to the screen
    61 0000010F BE[C900]            <1>     mov si, DiskReadErrorString ; mov the string pointer into si
    62 00000112 E808FF              <1>     call printf                 ; Call printf
    63 00000115 EBFE                <1>     jmp $                    ; jmp to hang 
    31                                  
    32                                  test:
    33 00000117 476F7420686572650A-         db 'Got here', 0x0a, 0x0d, 0x00
    33 00000120 0D00               
    34                                  
    35 00000122 00<rep DCh>             times 510-($-$$) db 0   ; Pad the rest of the first sector
    36 000001FE 55AA                    dw 0xaa55               ; Magic number to declare this sector as boot
     1                                  
     2 00000000 E981010000              jmp EnterProtectedMode
     3                                  
     4                                  ; GDT
     5                                  %include "gdt.asm"
     6                              <1> gdt_nulldesc:
     7 00000005 00000000            <1>     dd 0
     8 00000009 00000000            <1>     dd 0
     9                              <1> gdt_codedesc:
    10 0000000D FFFF                <1>     dw 0xffff     ; Limit
    11 0000000F 0000                <1>     dw 0x0000     ; Base (Low)
    12 00000011 00                  <1>     db 0x00       ; Base (Medium)
    13 00000012 9A                  <1>     db 10011010b  ; Flags
    14 00000013 CF                  <1>     db 11001111b  ; Flags + Upper limit
    15 00000014 00                  <1>     db 0x00       ; base (High)
    16                              <1> 
    17                              <1> gdt_datadesc:
    18 00000015 FFFF                <1>     dw 0xffff
    19 00000017 0000                <1>     dw 0x0000
    20 00000019 00                  <1>     db 0x00
    21 0000001A 92                  <1>     db 10010010b
    22 0000001B CF                  <1>     db 11001111b
    23 0000001C 00                  <1>     db 0x00
    24                              <1> 
    25                              <1> gdt_end:
    26                              <1> 
    27                              <1> gdt_descriptor:
    28                              <1>     gdt_size:
    29 0000001D 1700                <1>         dw gdt_end - gdt_nulldesc - 1
    30 0000001F [0500000000000000]  <1>         dq gdt_nulldesc
    31                              <1> 
    32                              <1> codeseg equ gdt_codedesc - gdt_nulldesc
    33                              <1> dataseg equ gdt_datadesc - gdt_nulldesc
    34                              <1> 
    35                              <1> [bits 32]
    36                              <1> EditGDT:
    37 00000027 C605[13000000]AF    <1>     mov [gdt_codedesc + 6], byte 10101111b
    38 0000002E C605[1B000000]AF    <1>     mov [gdt_datadesc + 6], byte 10101111b
    39 00000035 C3                  <1>     ret
    40                              <1> 
    41                              <1> [bits 16]
     6                                  %include "printf.asm"
     7                              <1> ; Function that prints a string from the bx register 
     8                              <1> ; printf:
     9                              <1> ;     pusha
    10                              <1> ;     mov ah, 0x0e
    11                              <1> ;     printf_loop:
    12                              <1> ;         cmp [bx], byte 0
    13                              <1> ;         je printf_exit
    14                              <1> ;         mov al, [bx]
    15                              <1> ;         int 0x10
    16                              <1> ;         inc bx
    17                              <1> ;         jmp printf_loop
    18                              <1> ;     printf_exit:
    19                              <1> ;         popa
    20                              <1> ;         ret
    21                              <1> 
    22                              <1> ; Function that prints a string from the si register
    23                              <1> printf:
    24 00000036 60                  <1>     pusha                    ; Push Everything to the stack
    25                              <1>     str_loop:                ; Label the loop
    26 00000037 8A04                <1>         mov al, [si]         ; Mov the byte at si to al
    27 00000039 3C00                <1>         cmp al, 0            ; cmp that byte with 0
    28 0000003B 7502                <1>         jne print_char       ; if the data in al isnt zero jmp to print_char
    29 0000003D 61                  <1>         popa                 ; Pop everything off the stack
    30 0000003E C3                  <1>         ret                  ; Return
    31                              <1>     print_char:              ; Label for print char
    32 0000003F B40E                <1>         mov ah, 0x0e         ; mov 0x0e into ah (to tell to print a char on int)
    33 00000041 CD10                <1>         int 0x10             ; int 0x10 to print the char in al
    34 00000043 46                  <1>         inc si               ; inc si
    35 00000044 EBF1                <1>         jmp str_loop         ; jmp back to the str so can print the next char
    36                              <1> 
    37                              <1> 
    38                              <1> ; Function to print a hex number (whatevers in dx) to the screen
    39                              <1> printh:
    40 00000046 89D3                <1>     mov bx, dx
    41 00000048 C1EB0C              <1>     shr bx, 12
    42 0000004B 8B9F[8D00]          <1>     mov bx, [bx + HEX_TABLE]
    43 0000004F 881E[8600]          <1>     mov [HEX_PATTERN + 2], bl
    44                              <1> 
    45 00000053 89D3                <1>     mov bx, dx
    46 00000055 C1EB08              <1>     shr bx, 8
    47 00000058 83E30F              <1>     and bx, 0x000f
    48 0000005B 8B9F[8D00]          <1>     mov bx, [bx + HEX_TABLE]
    49 0000005F 881E[8700]          <1>     mov [HEX_PATTERN + 3], bl
    50                              <1>     
    51 00000063 89D3                <1>     mov bx, dx
    52 00000065 C1EB04              <1>     shr bx, 4
    53 00000068 8B9F[8D00]          <1>     mov bx, [bx + HEX_TABLE]
    54 0000006C 881E[8800]          <1>     mov [HEX_PATTERN + 4], bl
    55                              <1>     
    56 00000070 89D3                <1>     mov bx, dx
    57 00000072 83E30F              <1>     and bx, 0x000f
    58 00000075 8B9F[8D00]          <1>     mov bx, [bx + HEX_TABLE]
    59 00000079 881E[8900]          <1>     mov [HEX_PATTERN + 5], bl
    60                              <1>     
    61 0000007D BE[8400]            <1>     mov si, HEX_PATTERN
    62 00000080 E8B3FF              <1>     call printf
    63 00000083 C3                  <1>     ret
    64                              <1> 
    65 00000084 30782A2A2A2A0A0D00  <1> HEX_PATTERN: db '0x****', 0x0a, 0x0d, 0x00
    66 0000008D 303132333435363738- <1> HEX_TABLE: db '0123456789abcdef'
    66 00000096 39616263646566      <1>
    67                              <1> 
    68                              <1> welcomeString: ; Welcome message string
    69 0000009D 5B494E464F5D205765- <1>     db '[INFO] Welcome to the KekOS bootloader!', 0x0a, 0x0d, 0x0
    69 000000A6 6C636F6D6520746F20- <1>
    69 000000AF 746865204B656B4F53- <1>
    69 000000B8 20626F6F746C6F6164- <1>
    69 000000C1 6572210A0D00        <1>
     7                                  %include "EnableA20.asm"
     8                              <1> EnableA20:
     9                              <1>     ; Check to see if the a20 gate is supported
    10 000000C7 B80324              <1>     mov ax, 0x2403
    11 000000CA CD15                <1>     int 0x15
    12 000000CC 0F828900            <1>     jb a20ns
    13 000000D0 80FC00              <1>     cmp ah, 0
    14 000000D3 0F858200            <1>     jnz a20ns
    15                              <1> 
    16                              <1>     ; Get the status of the gate
    17 000000D7 B80224              <1>     mov ax, 0x2402
    18 000000DA CD15                <1>     int 0x15
    19 000000DC 723C                <1>     jb a20failed
    20 000000DE 80FC00              <1>     cmp ah, 0
    21 000000E1 7537                <1>     jnz a20failed
    22                              <1> 
    23 000000E3 3C01                <1>     cmp al, 1
    24 000000E5 7413                <1>     jz a20activated
    25                              <1> 
    26                              <1>     ; Activate the a20 gate
    27 000000E7 B80124              <1>     mov ax, 0x2401
    28 000000EA CD15                <1>     int 0x15
    29 000000EC 722C                <1>     jb a20failed
    30 000000EE 80FC00              <1>     cmp ah, 0
    31 000000F1 7527                <1>     jnz a20failed
    32                              <1> 
    33 000000F3 BE[0201]            <1>     mov si, a20activatedstring
    34 000000F6 E83DFF              <1>     call printf
    35                              <1>     ; return to continue enabling protected mode
    36                              <1>     a20end:
    37 000000F9 C3                  <1>     ret
    38                              <1> 
    39                              <1> a20activated:
    40 000000FA BE[0201]            <1>     mov si, a20activatedstring
    41 000000FD E836FF              <1>     call printf
    42 00000100 EBF7                <1>     jmp a20end
    43                              <1> 
    44                              <1> a20activatedstring:
    45 00000102 5B494E464F5D204132- <1>     db '[INFO] A20 Activated.', 0x0a, 0x0d, 0x00
    45 0000010B 302041637469766174- <1>
    45 00000114 65642E0A0D00        <1>
    46                              <1> 
    47                              <1> a20failed:
    48 0000011A BE[2201]            <1>     mov si, a20failedstring
    49 0000011D E816FF              <1>     call printf
    50 00000120 EBFE                <1>     jmp $
    51                              <1> a20failedstring:
    52 00000122 5B4552524F525D2046- <1>     db '[ERROR] Failed to get status or enable the a20 line.', 0x0a, 0x0d, 0x00
    52 0000012B 61696C656420746F20- <1>
    52 00000134 676574207374617475- <1>
    52 0000013D 73206F7220656E6162- <1>
    52 00000146 6C6520746865206132- <1>
    52 0000014F 30206C696E652E0A0D- <1>
    52 00000158 00                  <1>
    53                              <1> 
    54                              <1> a20ns:
    55 00000159 BE[6101]            <1>     mov si, a20nsstring
    56 0000015C E8D7FE              <1>     call printf
    57 0000015F EBFE                <1>     jmp $
    58                              <1> a20nsstring:
    59 00000161 5B4552524F525D2041- <1>     db '[ERROR] A20 gate is not supported.', 0x0a, 0x0d, 0x00
    59 0000016A 323020676174652069- <1>
    59 00000173 73206E6F7420737570- <1>
    59 0000017C 706F727465642E0A0D- <1>
    59 00000185 00                  <1>
     8                                  
     9                                  EnterProtectedMode:
    10 00000186 E83EFF                      call EnableA20
    11 00000189 FA                          cli
    12 0000018A 0F0116[1D00]                lgdt [gdt_descriptor]
    13 0000018F 0F20C0                      mov eax, cr0
    14 00000192 6683C801                    or eax, 1
    15 00000196 0F22C0                      mov cr0, eax
    16 00000199 EA[2A02]0800                jmp codeseg:ClearPipe
    17                                  
    18                                  [bits 32]
    19                                  
    20                                  %include "SimplePaging.asm"
    21                              <1> PageTableEntry equ 0x1000
    22                              <1> 
    23                              <1> SetupIdentityPaging:
    24 0000019E BF00100000          <1>     mov edi, PageTableEntry
    25 000001A3 0F22DF              <1>     mov cr3, edi
    26 000001A6 C70703200000        <1>     mov dword [edi], 0x2003
    27 000001AC 81C700100000        <1>     add edi, 0x1000
    28 000001B2 C70703300000        <1>     mov dword [edi], 0x3003
    29 000001B8 81C700100000        <1>     add edi, 0x1000
    30 000001BE C70703400000        <1>     mov dword [edi], 0x4003
    31 000001C4 81C700100000        <1>     add edi, 0x1000
    32                              <1> 
    33 000001CA BB03000000          <1>     mov ebx, 0x00000003
    34 000001CF B900020000          <1>     mov ecx, 512
    35                              <1> 
    36                              <1>     .SetEntry:
    37 000001D4 891F                <1>         mov dword [edi], ebx
    38 000001D6 81C300100000        <1>         add ebx, 0x1000
    39 000001DC 83C708              <1>         add edi, 8
    40 000001DF E2F3                <1>         loop .SetEntry
    41                              <1> 
    42                              <1> 
    43 000001E1 0F20E0              <1>     mov eax, cr4
    44 000001E4 83C820              <1>     or eax, 1 << 5
    45 000001E7 0F22E0              <1>     mov cr4, eax
    46                              <1> 
    47 000001EA B9800000C0          <1>     mov ecx, 0xc0000080
    48 000001EF 0F32                <1>     rdmsr
    49 000001F1 0D00010000          <1>     or eax, 1 << 8
    50 000001F6 0F30                <1>     wrmsr
    51                              <1> 
    52 000001F8 0F20C0              <1>     mov eax, cr0
    53 000001FB 0D00000080          <1>     or eax, 1 << 31
    54 00000200 0F22C0              <1>     mov cr0, eax
    55                              <1> 
    56 00000203 C3                  <1>     ret
    21                                  %include "cpuid.asm"
    22                              <1> Detectcpuid:
    23 00000204 9C                  <1>     pushfd
    24 00000205 58                  <1>     pop eax
    25 00000206 89C1                <1>     mov ecx, eax
    26 00000208 3500002000          <1>     xor eax, 1 << 21
    27 0000020D 50                  <1>     push eax
    28 0000020E 9D                  <1>     popfd
    29                              <1> 
    30 0000020F 9C                  <1>     pushfd
    31 00000210 58                  <1>     pop eax
    32 00000211 51                  <1>     push ecx
    33 00000212 9D                  <1>     popfd
    34 00000213 31C8                <1>     xor eax, ecx
    35 00000215 7412                <1>     jz NoCPUID
    36 00000217 C3                  <1>     ret
    37                              <1> 
    38                              <1> DetectLongMode:
    39 00000218 B801000080          <1>     mov eax, 0x80000001
    40 0000021D 0FA2                <1>     cpuid
    41 0000021F F7C200000020        <1>     test edx, 1 << 29
    42 00000225 7401                <1>     jz NoLongMode
    43 00000227 C3                  <1>     ret
    44                              <1> 
    45                              <1> NoLongMode:
    46 00000228 F4                  <1>     hlt
    47                              <1> 
    48                              <1> NoCPUID:
    49 00000229 F4                  <1>     hlt
    22                                  ClearPipe:
    23 0000022A 66B81000                    mov ax, dataseg
    24 0000022E 8ED8                        mov ds, ax
    25 00000230 8ED0                        mov ss, ax
    26 00000232 8EC0                        mov es, ax
    27 00000234 8EE0                        mov fs, ax
    28 00000236 8EE8                        mov gs, ax
    29 00000238 EB00                        jmp StartProtectedMode
    30                                  
    31                                  StartProtectedMode:
    32 0000023A E8C5FFFFFF                  call Detectcpuid
    33 0000023F E8D4FFFFFF                  call DetectLongMode
    34 00000244 E855FFFFFF                  call SetupIdentityPaging
    35 00000249 E8D9FDFFFF                  call EditGDT
    36 0000024E EA[55020000]0800            jmp codeseg:Start64bit
    37                                  
    38                                  [bits 64]
    39                                  [extern _start]
    40                                  Start64bit:
    41 00000255 BF00800B00                  mov edi, 0xb8000
    42 0000025A 48B8201F201F201F20-         mov rax, 0x1f201f201f201f20
    42 00000263 1F                 
    43 00000264 B9F4010000                  mov ecx, 500
    44 00000269 F348AB                      rep stosq
    45 0000026C E8(00000000)                call _start
    46 00000271 EBFE                        jmp $
    47                                  
    48 00000273 00<rep 58Dh>            times 2048-($-$$) db 0 ; pad it out to 2048 byte (2 sectors)
   1              		.file	"kernel.cpp"
   2              		.text
   3              	.Ltext0:
   4              		.globl	_start
   6              	_start:
   7              	.LFB0:
   8              		.file 1 "kernel.cpp"
   1:kernel.cpp    **** extern "C" void _start()
   2:kernel.cpp    **** {
   9              		.loc 1 2 1
  10              		.cfi_startproc
  11 0000 55       		pushq	%rbp
  12              		.cfi_def_cfa_offset 16
  13              		.cfi_offset 6, -16
  14 0001 4889E5   		movq	%rsp, %rbp
  15              		.cfi_def_cfa_register 6
  16 0004 4883EC10 		subq	$16, %rsp
   3:kernel.cpp    ****     int* ptr = (int*)0xb8000;
  17              		.loc 1 3 10
  18 0008 48C745F8 		movq	$753664, -8(%rbp)
  18      00800B00 
   4:kernel.cpp    ****     *ptr = 0x50505050;
  19              		.loc 1 4 10
  20 0010 488B45F8 		movq	-8(%rbp), %rax
  21 0014 C7005050 		movl	$1347440720, (%rax)
  21      5050
   5:kernel.cpp    ****     return;
  22              		.loc 1 5 5
  23 001a 90       		nop
   6:kernel.cpp    **** }...
  24              		.loc 1 6 1
  25 001b C9       		leave
  26              		.cfi_restore 6
  27              		.cfi_def_cfa 7, 8
  28 001c C3       		ret
  29              		.cfi_endproc
  30              	.LFE0:
  32              	.Letext0:
