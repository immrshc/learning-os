puts:
	push ebp
	mov ebp, esp

	push eax
	push ebx
	push esi

	mov esi, [ebp + 8]

	mov ah, 0x0E
	mov ebx, 0x0000
	cld

.10L:
	lodsb
	cmp al, 0
	je .10E
	int 0x10
	jmp .10L

.10E:
	pop esi
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp

	ret
