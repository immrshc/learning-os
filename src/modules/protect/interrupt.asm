ALIGN 4
IDTR:
	dw 8 * 256 - 1 ; idt_limit
	dd VECT_BASE ; idt location

init_int:
	push eax
	push ebx
	push ecx
	push edi
	; 全ての割り込みにデフォルト処理を設定
	lea eax, [int_default]
	mov ebx, 0x000B_8E00
	xchg ax, bx

	mov ecx, 256
	mov edi, VECT_BASE

.10L:
	mov [edi + 0], ebx
	mov [edi + 4], eax
	add edi, 8
	loop .10L

	lidt [IDTR]

	pop edi
	pop ecx
	pop ebx
	pop eax

	ret

int_stop:
	cdecl draw_str, 25, 15, 0x060F, eax

	mov eax, [esp + 0]
	cdecl itoa, eax, .p1, 8, 16, 0b0100

	mov eax, [esp + 4]
	cdecl itoa, eax, .p2, 8, 16, 0b0100

	mov eax, [esp + 8]
	cdecl itoa, eax, .p3, 8, 16, 0b0100

	mov eax, [esp + 12]
	cdecl itoa, eax, .p4, 8, 16, 0b0100

	cdecl draw_str, 25, 16, 0x0F04, .s1	; draw_str("ESP+ 0:-------- ");
	cdecl draw_str, 25, 17, 0x0F04, .s2	; draw_str("   + 4:-------- ");
	cdecl draw_str, 25, 18, 0x0F04, .s3	; draw_str("   + 8:-------- ");
	cdecl draw_str, 25, 19, 0x0F04, .s4	; draw_str("   +12:-------- ");

	jmp	$								; while (1) ; // 無限ループ

.s1	db "ESP+ 0:"
.p1	db "________ ", 0
.s2	db "   + 4:"
.p2	db "________ ", 0
.s3	db "   + 8:"
.p3	db "________ ", 0
.s4	db "   +12:"
.p4	db "________ ", 0

int_default:
	pushf ; // EFLAGS(IF==0)
	push cs ; // CS
	push int_stop ; // スタック表示処理

	mov	eax, .s0 ; // 割り込み種別
	iret

.s0	db " <    STOP    > ", 0

int_zero_div:
	pushf ; EFLAGS
	push cs ; CS
	push int_stop ; スタック表示処理

	mov	eax, .s0 ; 割り込み種別
	iret

.s0	db " <  ZERO DIV  > ", 0
