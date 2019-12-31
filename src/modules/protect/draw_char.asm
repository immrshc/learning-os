draw_char:
	push ebp
	mov ebp, esp

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	; コピー元フォントアドレスの設定
	movzx esi, byte [ebp + 20]
	shl esi, 4
	add esi, [FONT_ADR]

	; コピー先アドレスを取得
	mov edi, [ebp + 12]
	shl edi, 8
	lea edi, [edi * 4 + edi + 0xA0000]
	add edi, [ebp + 8]

	; 1文字分のフォントを出力
	movzx ebx, word [ebp + 16]

	cdecl vga_set_read_plane, 0x03 ; 輝度
	cdecl vga_set_write_plane, 0x08 ; 輝度
	cdecl vram_font_copy, esi, edi, 0x08, ebx ; font address, vram address, plane, color

	cdecl vga_set_read_plane, 0x02 ; 赤
	cdecl vga_set_write_plane, 0x04 ; 赤
	cdecl vram_font_copy, esi, edi, 0x04, ebx ; font address, vram address, plane, color

	cdecl vga_set_read_plane, 0x01 ; 緑
	cdecl vga_set_write_plane, 0x02 ; 緑
	cdecl vram_font_copy, esi, edi, 0x02, ebx ; font address, vram address, plane, color

	cdecl vga_set_read_plane, 0x00 ; 青
	cdecl vga_set_write_plane, 0x01 ; 青
	cdecl vram_font_copy, esi, edi, 0x01, ebx ; font address, vram address, plane, color

	pop edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	mov	esp, ebp
	pop	ebp

	ret
