read_chs:
	push bp
	mov bp, sp
	push 3 ; リトライ回数
	push 0 ; 読み込みセクタ数

	push bx
	push cx
	push dx
	push es
	push si

	mov si, [bp + 4]

	; cxレジスタの設定
	mov ch, [si + drive.cyln + 0]
	mov cl, [si + drive.cyln + 1]
	shl cl, 6
	or cl, [si + drive.sect]

	; セクタ読み込み
	mov dh, [si + drive.head]
	mov dl, [si + 0]
	mov ax, 0x0000
	mov es, ax
	mov bx, [bp + 8]
.10L:
	mov	ah, 0x02 ; AH = セクタ読み込み
	mov	al, [bp + 6] ; AL = セクタ数
	int	0x13
	jnc	.11E

	mov	al, 0
	jmp	.10E
.11E:
	cmp	al, 0 ; 読み込んだセクタがあるか
	jne	.10E
	mov	ax, 0 ; ret = 0; // 戻り値を設定
	dec	word [bp - 2]
	jnz	.10L
.10E:
	mov	ah, 0 ; AH = 0; // ステータス情報は破棄

	pop	si
	pop	es
	pop	dx
	pop	cx
	pop	bx
	mov	sp, bp
	pop	bp

	ret
