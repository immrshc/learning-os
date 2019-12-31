vga_set_read_plane:
	push ebp
	mov ebp, esp
	push eax
	push edx
	; 読み込みプレーンの選択
	mov ah, [ebp + 8] ; プレーンを選択
	and ah, 0x03 ; 余計なビットをマスク
	mov al, 0x04
	mov dx, 0x03CE
	out dx, ax

	pop edx
	pop eax
	mov esp, ebp
	pop ebp

	ret

vga_set_write_plane:
	push ebp
	mov ebp, esp
	push eax
	push edx
	; 書き込みプレーン
	mov ah, [ebp + 8]
	and ah, 0x0F
	mov al, 0x02
	mov dx, 0x03C4
	out dx, ax

	pop edx
	pop eax
	mov esp, ebp
	pop ebp

	ret

vram_font_copy:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	mov esi, [ebp + 8] ; フォントアドレス
	mov edi, [ebp + 12] ; VRAMアドレス
	movzx eax, byte [ebp + 16] ; 対象プレーン
	movzx ebx, word [ebp + 20] ; 色

	test bh, al
	setz dh
	dec dh

	cld
	mov ecx, 16
.10L:
	; フォントマスクの作成
	lodsb
	mov ah, al
	not ah

	; 前景色
	and al, dl

	; 背景色
	test ebx, 0x0010
	jz .11F
	and ah, [edi]
	jmp .11E
.11F:
	and ah, dh
.11E:
	; 前景色と背景色を合成
	or al, ah
	; 新しい値を出力
	mov [edi], al
	add edi, 80
	loop .10L
.10E:
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret