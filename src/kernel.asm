%include "./src/include/define.asm"
%include "./src/include/macro.asm"

ORG KERNEL_LOAD ; カーネルのロードアドレス

[BITS 32]
kernel:
; BIOSの文字出力をするには、プロテクトモードでkernelからの割り込みを許可する必要がある
;	cdecl puts, .s0
;	mov al, 'A'
;	mov ah, 0x0E
;	mov ebx, 0x000
;	int 0x10
	jmp $

	times KERNEL_SIZE - ($ - $$) db 0

;.s0:	db	" Hello, kernel! ", 0x0A, 0x0D, 0

;ALIGN 4, db 0

; モジュール
;%include "./src/modules/protect/puts.asm"