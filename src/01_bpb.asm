entry:
	jmp		ipl								; IPLへジャンプ
	times	90 - ($ - $$) db 0x90			;
ipl:
	jmp		$								; while (1) ; // 無限ループ
; ブートフラグ（先頭512バイトの終了）
	times	510 - ($ - $$) db 0x00
	db	0x55, 0xAA
