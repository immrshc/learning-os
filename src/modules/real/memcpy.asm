memcpy:
	; スタックフレームの構築
	push bp ; BP+2
	mov  bp, sp ; BP+0
	; レジスタの保存
	push cx
	push si
	push di
	; バイト単位でのコピー
	cld ; DF = 0 でコピー先と元のアドレスを加算する
	mov di, [bp + 4] ; コピー先
	mov si, [bp + 6] ; コピー元
	mov cx, [bp + 8] ; バイト数
	rep movsb ; while(*DI++ = *SI++)
	; レジスタの復帰
	pop di
	pop si
	pop cx
	; スタックフレームの破棄
	mov sp, bp
	pop bp
	ret
