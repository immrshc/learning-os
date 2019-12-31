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
	mov [BOOT + drive.no], dl ; ブートドライブを保存
	cdecl puts, .s0

	; 残りのセクタを全て読み込む
	mov bx, BOOT_SECT - 1
	mov cx, BOOT_LOAD + SECT_SIZE
	cdecl read_chs, BOOT, bx, cx
	cmp ax, bx
.10Q:
	jnc .10E
.10T:
	cdecl puts, .e0
	call reboot
.10E:
	jmp stage_2

.s0 db "Booting...", 0x0A, 0x0D, 0
.e0 db "Error:sector read", 0

; ブートドライブに関する情報
ALIGN 2, db 0
BOOT:
	istruc drive
		at drive.no, dw 0
		at drive.cyln, dw 0
		at drive.head, dw 0
		at drive.sect, dw 2
	iend

; モジュール
%include "./src/modules/real/puts.asm"
%include "./src/modules/real/reboot.asm"
%include "./src/modules/real/read_chs.asm"

; 先頭512バイトの残りを埋める
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

; リアルモード時に取得した情報
; 二番目のセクタの先頭で保持する
FONT:
.seg dw 0
.off dw 0

; モジュール（先頭512バイト以降で利用）
%include "./src/modules/real/itoa.asm"
%include "./src/modules/real/get_drive_param.asm"
%include "./src/modules/real/get_font_adr.asm"
%include "./src/modules/real/lba_chs.asm"
%include "./src/modules/real/read_lba.asm"

stage_2:
	cdecl puts, .s0
	; ドライブ情報を取得
	cdecl get_drive_param, BOOT
	cmp ax, 0
.10Q:
	jne .10E
.10T:
	cdecl puts, .e0
	call reboot
.10E:
	; ドライブ情報を表示
	mov	ax, [BOOT + drive.no] ; AX = ブートドライブ;
	cdecl itoa, ax, .p1, 2, 16, 0b0100
	mov	ax, [BOOT + drive.cyln]
	cdecl itoa, ax, .p2, 4, 16, 0b0100
	mov	ax, [BOOT + drive.head]	; AX = ヘッド数;
	cdecl itoa, ax, .p3, 2, 16, 0b0100
	mov	ax, [BOOT + drive.sect]	; AX = トラックあたりのセクタ数;
	cdecl itoa, ax, .p4, 2, 16, 0b0100
	cdecl puts, .s1

	jmp	stage_3

.s0		db	"2nd stage...", 0x0A, 0x0D, 0
.s1		db	" Drive:0x"
.p1		db	"  , C:0x"
.p2		db	"    , H:0x"
.p3		db	"  , S:0x"
.p4		db	"  ", 0x0A, 0x0D, 0

.e0		db	"Can't get drive parameter.", 0

stage_3:
	cdecl puts, .s0
	; BIOSに内蔵されたフォントをプロテクトモード時に利用する
	cdecl get_font_adr, FONT
	; フォントアドレスの表示
	cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
	cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100
	cdecl puts, .s1
	jmp stage_4

.s0 db "3rd stage...", 0x0A, 0x0D, 0
.s1: db " Font Address = "
.p1: db "ZZZZ:"
.p2: db "ZZZZ", 0x0A, 0x0D, 0
	db 0x0A, 0x0D, 0

stage_4:
	cdecl puts, .s0
.10L:
	; ユーザーからの入力待ち
	mov ah, 0x00
	int 0x16
	cmp al, ' '
	jne .10L

	; ビデオモードの設定
	mov ax, 0x0012
	int 0x10

	jmp stage_5

.s0 db "4th stage...", 0x0A, 0x0D, 0x0A, 0x0D
	db " [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0

stage_5:
	cdecl puts, .s0
	; カーネルを読み込む
	cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
	cmp ax, KERNEL_SECT
.10Q:
	jz .10E
.10T:
	cdecl puts, .e0
	call reboot
.10E:
	jmp stage_6

.s0 db "5th stage...", 0x0A, 0x0D, 0
.e0 db " Failure load kernel...", 0x0A, 0x0D, 0

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

stage_6:
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

