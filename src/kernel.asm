%include "./src/include/define.asm"
%include "./src/include/macro.asm"

ORG KERNEL_LOAD ; カーネルのロードアドレス

[BITS 32]
kernel:
	; フォントアドレスの取得
	mov esi, BOOT_LOAD + SECT_SIZE; 0x7C00 + 512
	movzx eax, word [esi + 0]
	movzx ebx, word [esi + 2]
	shl eax, 4
	add eax, ebx
	mov [FONT_ADR], eax
	; 三行目に文字を描画
	mov esi, 'A'
	shl esi, 4
	add esi, [FONT_ADR]

	mov edi, 2
	shl edi, 8
	lea edi, [edi * 4 + edi + 0xA_0000]

	mov ecx, 16
.10L:
	movsb
	add edi, 80 - 1
	loop .10L

	jmp $

ALIGN 4, db 0
FONT_ADR: dd 0

	times KERNEL_SIZE - ($ - $$) db 0
