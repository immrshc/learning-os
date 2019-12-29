BOOT_LOAD equ 0x7c00
ORG BOOT_LOAD

%include "./src/include/macro.asm"

entry:
	jmp ipl
	times 90 - ($ - $$) db 0x90
ipl:
	cli

	mov ax, 0x0000
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BOOT_LOAD

	sti

	mov [BOOT.DRIVE], dl

	cdecl puts, .s0

	cdecl itoa, 8086, .s1, 8, 10, 0b0001
	cdecl puts, .s1

	cdecl itoa, 8086, .s1, 8, 10, 0b0011
	cdecl puts, .s1

	cdecl itoa, -8086, .s1, 8, 10, 0b0001
	cdecl puts, .s1

	cdecl itoa, -1, .s1, 8, 10, 0b0001
	cdecl puts, .s1

	cdecl itoa, -1, .s1, 8, 10, 0b0000
	cdecl puts, .s1

	cdecl itoa, -1, .s1, 8, 16, 0b0000
	cdecl puts, .s1

	cdecl itoa, 12, .s1, 8, 2, 0b0100
	cdecl puts, .s1

	jmp $

.s0	db "Booting...", 0x0A, 0x0D, 0
.s1	db "--------", 0x0A, 0x0D, 0

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0

%include "./src/modules/real/puts.asm"
%include "./src/modules/real/itoa.asm"

	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA
