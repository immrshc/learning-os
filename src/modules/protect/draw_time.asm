draw_time:
	push ebp
	mov ebp, esp
	push eax
	push ebx

	mov eax, [ebp + 20] ; 時刻データ
	cmp eax, [.last]
	je .10E

	mov [.last], eax

	mov ebx, 0
	mov bl, al
	cdecl itoa, ebx, .sec, 2, 16, 0b0100

	mov bl, ah
	cdecl itoa, ebx, .min, 2, 16, 0b0100

	shr eax, 16
	cdecl itoa, eax, .hour, 2, 16, 0b0100

	cdecl draw_str, dword [ebp + 8], dword [ebp + 12], dword [ebp + 16], .hour

.10E:
	pop ebx
	pop eax
	mov esp, ebp
	pop ebp
	ret

ALIGN 2, db 0
.temp:	dq	0
.last:	dq	0
.hour:	db	"ZZ:"
.min:	db	"ZZ:"
.sec:	db	"ZZ", 0
