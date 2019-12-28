memcpy:
	; スタックフレームの構築
	push ebp ; EBP+0
	mov  ebp, esp ; EBP+4
	; レジスタの保存
	push ecx
	push esi
	push edi
	; バイト単位でのコピー
	cld ; DF = 0 でコピー先と元のアドレスを加算する
	mov edi, [ebp + 8] ; コピー先
	mov esi, [ebp + 12] ; コピー元
	mov ecx, [ebp + 16] ; バイト数
	rep movsb ; while(*DI++ = *SI++)
	; レジスタの復帰
	pop edi
	pop esi
	pop ecx
	; スタックフレームの破棄
	mov esp, ebp
	pop ebp
	ret
