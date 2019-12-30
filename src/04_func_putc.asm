BOOT_LOAD equ 0x7C00 ; ブートプログラムのロード位置
ORG BOOT_LOAD ; ロードアドレスをアセンブラに指示する

%include "./src/include/macro.asm"

entry:
	jmp ipl; IPLへジャンプ
	times 90 - ($ - $$) db 0x90

ipl:
	cli ; 割り込み禁止
	mov ax, 0x0000; AX = 0x0000
	mov ds, ax; DS = 0x0000
	mov es, ax; ES = 0x0000
	mov ss, ax; SS = 0x0000
	mov sp, BOOT_LOAD; SP = 0x7C00

	sti ; 割り込み許可
	mov [BOOT.DRIVE], dl ; ブートドライブを保存

	cdecl putc, word 'X'
	cdecl putc, word 'Y'
	cdecl putc, word 'Z'

	jmp $ ; 無限ループ

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0

%include "./src/modules/real/putc.asm"

	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

