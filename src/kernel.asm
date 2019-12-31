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

	; 初期化
	cdecl init_int ; 割り込みベクタの初期化
	set_vect 0x00, int_zero_div ; 0除算

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
	; 文字列の表示
	cdecl draw_str, 25, 14, 0x010F, .s0
	; 割り込み処理を実行
;	push 0x11223344
;	pushf; EFLAGSの保存
;	call 0x0008:int_default

	; 割り込み処理の呼び出し
	mov	al, 0 ; AL = 0;
	div	al ; 0除算
.10L:
	; 時刻の表示
	cdecl rtc_get_time, RTC_TIME
	cdecl draw_time, 72, 0, 0x0700, dword [RTC_TIME]
	jmp .10L

	jmp $

.s0: db	" Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0
RTC_TIME: dd 0

; モジュール
%include "./src/modules/protect/vga.asm"
%include "./src/modules/protect/itoa.asm"
%include "./src/modules/protect/rtc.asm"
%include "./src/modules/protect/draw_char.asm"
%include "./src/modules/protect/draw_str.asm"
%include "./src/modules/protect/draw_time.asm"
%include "./src/modules/interrupt.asm"

	times KERNEL_SIZE - ($ - $$) db 0
