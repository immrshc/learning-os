itoa:
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; ------+--------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi
		; 引数を取得
		mov		eax, [ebp + 8]					; val  = 数値;
		mov		esi, [ebp +12]					; dst  = バッファアドレス;
		mov		ecx, [ebp +16]					; size = 残りバッファサイズ;

		mov		edi, esi						; // バッファの最後尾
		add		edi, ecx						; dst  = &dst[size - 1];
		dec		edi								;
		mov		ebx, [ebp +24]					; flags = オプション;
		; 符号付き判定
		test	ebx, 0b0001						; if (flags & 0x01)// 符号付き
.10Q:	je		.10E							; {
		cmp		eax, 0							;   if (val < 0)
.12Q:	jge		.12E							;   {
		or		ebx, 0b0010						;     flags |=  2; // 符号表示
.12E:											;   }
.10E:											; }
		; 符号出力判定
		test	ebx, 0b0010						; if (flags & 0x02)// 符号出力判定
.20Q:	je		.20E							; {
		cmp		eax, 0							;   if (val < 0)
.22Q:	jge		.22F							;   {
		neg		eax								;     val *= -1;   // 符号反転
		mov		[esi], byte '-'					;     *dst = '-';  // 符号表示
		jmp		.22E							;   }
.22F:											;   else
												;   {
		mov		[esi], byte '+'					;     *dst = '+';  // 符号表示
.22E:											;   }
		dec		ecx								;   size--;        // 残りバッファサイズの減算
.20E:											; }

		; ASCII変換
		mov		ebx, [ebp +20]					; BX = 基数;
.30L:											; do
												; {
		mov		edx, 0							;
		div		ebx								;   DX = DX:AX % 基数;
												;   AX = DX:AX / 基数;
												;
		mov		esi, edx						;   // テーブル参照
		mov		dl, byte [.ascii + esi]			;   DL = ASCII[DX];
												;
		mov		[edi], dl						;   *dst = DL;
		dec		edi								;   dst--;
												;
		cmp		eax, 0							;
		loopnz	.30L							; } while (AX);
.30E:

		; 空欄を埋める
		cmp		ecx, 0							; if (size)
.40Q:	je		.40E							; {
		mov		al, ' '							;   AL = ' ';  // ' 'で埋める（デフォルト値）
		cmp		[ebp +24], word 0b0100			;   if (flags & 0x04)
.42Q:	jne		.42E							;   {
		mov		al, '0'							;     AL = '0'; // '0'で埋める
.42E:											;   }
		std										;   // DF = 1（-方向）
		rep stosb								;   while (--CX) *DI-- = ' ';
.40E:											; }
		pop		edi
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax
		mov		esp, ebp
		pop		ebp
		ret

.ascii	db		"0123456789ABCDEF"				; 変換テーブル

