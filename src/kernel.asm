%include "./src/include/define.asm"
%include "./src/include/macro.asm"

ORG KERNEL_LOAD ; カーネルのロードアドレス

[BITS 32]
kernel:
	jmp $

	times KERNEL_SIZE - ($ - $$) db 0
