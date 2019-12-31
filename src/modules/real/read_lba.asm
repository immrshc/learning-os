read_lba:
	push bp
	mov	bp, sp
	push si

	mov		si, [bp + 4]					; SI = ドライブ情報;
	; LBA→CHS変換
	mov		ax, [bp + 6]					; AX = LBA;
	cdecl	lba_chs, si, .chs, ax			; lba_chs(drive, .chs, AX);

	; ドライブ番号のコピー
	mov	al, [si + drive.no]
	mov	[.chs + drive.no], al ; ドライブ番号

	; セクタの読み込み
	cdecl read_chs, .chs, word [bp + 8], word [bp +10]; AX = read_chs(.chs, セクタ数, ofs);

	pop	si
	mov	sp, bp
	pop	bp

	ret

ALIGN 2
.chs: times drive_size db 0 ; 読み込みセクタに関する情報
