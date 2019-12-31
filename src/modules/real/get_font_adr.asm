get_font_adr:
	push bp
	mov bp, sp

	push ax
	push bx
	push si
	push es
	push bp

	; フォントアドレスの保存先
	mov si, [bp + 4]
	; フォントアドレスの取得
	; es, bp レジスタに格納される
	mov ax, 0x1130
	mov bh, 0x06
	int 10h

	mov [si + 0], es ; セグメント
	mov [si + 2], bp ; オフセット

	pop bp
	pop es
	pop si
	pop bx
	pop ax

	mov bp, sp
	pop bp

	ret
