nasm -l bootloader.txt bootloader.asm -f bin -o bootloader.bin
nasm -l extendedprogram.txt extendedprogram.asm -f elf64 -o extendedprogram.o
wsl %WSLGCCENV%/x86_64-elf-gcc -ffreestanding -mno-red-zone -m64 -c "kernel.cpp" -o "kernel.o"
wsl %WSLGCCENV%/x86_64-elf-ld -o kernel.tmp -Ttext 0x7e00 extendedprogram.o kernel.o
wsl %WSLGCCENV%/x86_64-elf-objcopy -O binary kernel.tmp kernel.bin

copy /b bootloader.bin+kernel.bin bootloader.flp

@REM All source is compiled and a mix of the source and asm is output into seperate files. All of that is combined here
wsl %WSLGCCENV%/x86_64-elf-gcc -Wa,-adhln -g -ffreestanding -mno-red-zone -m64 -c "kernel.cpp" -o "kernel.tmp" > kernel.txt
copy bootloader.txt+extendedprogram.txt+kernel.txt fullsource.asm

qemu-system-x86_64.exe ./bootloader.flp