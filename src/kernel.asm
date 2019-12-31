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
	; 文字の表示
;	mov esi, 'A'
;	shl esi, 4
;	add esi, [FONT_ADR]
;	mov edi, 2 ; 行数
;	shl edi, 8 ; EDI * 256
;	lea edi, [edi * 4 + edi + 0xA_0000] ; EDI = VRAMアドレス
;	mov ecx, 16
;.10L:
;	movsb
;	add edi, 80 - 1
;	loop .10L
	; 文字の表示
	cdecl draw_char, 0, 0, 0x010F, 'A' ; column, row, color, char
	cdecl draw_char, 1, 0, 0x010F, 'B' ; column, row, color, char
	cdecl draw_char, 2, 0, 0x010F, 'C' ; column, row, color, char
	cdecl draw_char, 0, 0, 0x0402, '0' ; column, row, color, char
	cdecl draw_char, 1, 0, 0x0212, '1' ; column, row, color, char
	cdecl draw_char, 2, 0, 0x0212, '_' ; column, row, color, char
	jmp $

ALIGN 4, db 0
FONT_ADR: dd 0

; モジュール
%include "./src/modules/protect/vga.asm"
%include "./src/modules/protect/draw_char.asm"

	times KERNEL_SIZE - ($ - $$) db 0
