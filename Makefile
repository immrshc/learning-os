.PHONY: build build.kernel boot clean execute execute.kernel

ASM_FILE ?= "./src/boot.asm"
ASM_DIR_PATH := $(shell dirname $(ASM_FILE))
ASM_BASE_PATH := $(ASM_DIR_PATH)/$(shell basename $(ASM_FILE) .asm)

build:
	@nasm $(ASM_FILE) -o $(ASM_BASE_PATH).bin

build.kernel:
	@nasm $(ASM_FILE) -o $(ASM_BASE_PATH).tmp.bin
	@nasm $(ASM_DIR_PATH)/kernel.asm -o $(ASM_DIR_PATH)/kernel.bin
	@touch $(ASM_BASE_PATH).bin
	@cat $(ASM_BASE_PATH).tmp.bin $(ASM_DIR_PATH)/kernel.bin > $(ASM_BASE_PATH).bin

boot:
	@qemu-system-i386 -rtc base=localtime -drive file=$(ASM_BASE_PATH).bin,format=raw -boot order=c

execute:
	@$(MAKE) build
	@$(MAKE) boot

execute.kernel:
	@$(MAKE) build.kernel
	@$(MAKE) boot

clean:
	@rm $(ASM_DIR_PATH)/*.bin
