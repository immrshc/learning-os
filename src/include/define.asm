BOOT_LOAD equ 0x7C00 ; ブートプログラムのロード位置
BOOT_SIZE equ (1024 * 8) ; ブートプログラムのサイズ
BOOT_END equ (BOOT_LOAD + BOOT_SIZE)
SECT_SIZE equ (512) ; セクタサイズ
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE) ; ブートプログラムのセクタ数
KERNEL_SIZE	equ	(1024 * 8) ; カーネルサイズ
KERNEL_LOAD	equ	0x0010_1000
KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)
VECT_BASE equ 0x0010_0000
