%include "./src/include/define.asm"
%include "./src/include/macro.asm"

ORG BOOT_LOAD ; ロードアドレスをアセンブラに指示

entry:
	jmp ipl
	times 90 - ($ - $$) db 0x90 ; ブートパラメータブロックを無操作（NOP）命令で埋める

ipl:
	cli ; 割り込み禁止
	mov ax, 0x0000
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, BOOT_LOAD

	sti ; 割り込み許可
	mov [BOOT.DRIVE], dl ; ブートドライブを保存
	cdecl puts, .s0

	; 次の512バイトを読み込む
	mov ah, 0x02
	mov al, BOOT_SECT - 1 ; 残りのブートプログラムのセクタ数
	mov cx, 0x0002
	mov dh, 0x00
	mov dl, [BOOT.DRIVE]
	mov bx, BOOT_LOAD + SECT_SIZE ; 次のロードアドレス
	int 0x13
.10Q:
	jnc .10E
.10T:
	cdecl puts, .e0
	call reboot
.10E:
	jmp stage_2

.s0 db "Booting...", 0x0A, 0x0D, 0
.e0 db "Error:sector read", 0

ALIGN 2, db 0
BOOT:
.DRIVE: dw 0 ; ドライブ番号

; モジュール
%include "./src/modules/real/puts.asm"
%include "./src/modules/real/reboot.asm"

; 先頭512バイトの残りを埋める
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

; モジュール（先頭512バイト以降で利用）
%include	"./src/modules/real/itoa.asm"

ALIGN 4, db 0
GDT: dq	0x00_0_0_0_0_000000_0000 ; NULL
.cs: dq	0x00_C_F_9_A_000000_FFFF ; CODE 4G
.ds: dq	0x00_C_F_9_2_000000_FFFF ; DATA 4G
.gdt_end:

; セレクタ
SEL_CODE equ .cs - GDT ; コード用セレクタ
SEL_DATA equ .ds - GDT ; データ用セレクタ

; GDT
GDTR: dw GDT.gdt_end - GDT - 1 ; ディスクリプタテーブルのリミット
	 dd GDT	; ディスクリプタテーブルのアドレス

; IDT（疑似：割り込み禁止にする為）
IDTR: dw 0 ; idt_limit
	 dd 0 ; idt location

stage_2:
	cdecl puts, .s0
	cli

	; GDTの設定
	lgdt [GDTR] ; グローバルディスクリプタテーブルをレジスタにロード
	lidt [IDTR] ; 割り込みディスクリプタテーブルをレジスタにロード

	; プロテクトモードへ移行
	mov eax, cr0 ; PEビットをセット
	or ax, 1
	mov cr0, eax
	jmp $ + 2 ; 先読みをクリア

; セグメント間ジャンプ
[BITS 32]
	DB 0x66 ; オペランドサイズオーバーライドプレフィックス
	jmp SEL_CODE:CODE_32

.s0 db "2nd stage...", 0x0A, 0x0D, 0

; 32ビットコード開始
CODE_32:
	; セレクタを初期化
	mov	ax, SEL_DATA
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	; カーネル部をコピー
	mov	ecx, (KERNEL_SIZE) / 4 ; ECX = 4バイト単位でコピー;
	mov	esi, BOOT_END ; ESI = 0x0000_9C00; // カーネル部
	mov	edi, KERNEL_LOAD ; EDI = 0x0010_1000; // 上位メモリ
	cld ; // DFクリア（+方向）
	rep movsd ; while (--ECX) *EDI++ = *ESI++;

	; カーネル処理に移行
	jmp	KERNEL_LOAD ; カーネルの先頭にジャンプ

; ブートプログラムの残りを埋める
	times BOOT_SIZE - ($ - $$) db 0

