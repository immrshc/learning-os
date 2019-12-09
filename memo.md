brew install qemu
==> Downloading https://homebrew.bintray.com/bottles/qemu-4.1.1.mojave.bottle.tar.gz
brew install nasm
==> Downloading https://homebrew.bintray.com/bottles/nasm-2.14.02.mojave.bottle.tar.gz

nasm ./src/00_boot_only/boot.asm -o ./src/00_boot_only/boot.img -l ./src/00_boot_only/boot.lst
qemu-system-i386 -rtc base=localtime -drive file=./src/00_boot_only/boot.img,format=raw -boot order=c

基本的な文法はドキュメントで説明されている
https://www.nasm.us/doc/nasmdoc3.html
https://www.nasm.us/doc/nasmdoc4.html

gdbであとでデバッグしてみる
https://qiita.com/dora-gt/items/889a564ebd682fbe4257
