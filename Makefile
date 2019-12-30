.PHONY: build boot clean execute

ASM_BASE_PATH := $(shell dirname $(ASM_FILE))/$(shell basename $(ASM_FILE) .asm)

build:
	@nasm $(ASM_FILE) -o $(ASM_BASE_PATH).bin

boot:
	@qemu-system-i386 -rtc base=localtime -drive file=$(ASM_BASE_PATH).bin,format=raw -boot order=c

execute:
	@$(MAKE) build
	@$(MAKE) boot

clean:
	@rm $(ASM_BASE_PATH).bin


