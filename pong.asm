; pong.asm - bootable Pong for x86 real mode (VGA text mode 80x25)
;
; Build:  nasm -f bin pong.asm -o pong.img   (from this directory)
; Run:    qemu-system-i386 -drive format=raw,file=pong.img
;
; Layout: sector 1 is the boot sector (src/boot.asm), which loads the
; game (stage 2, everything after it) from the following sectors to
; 0x7E00 and jumps to it. The image is padded to 1.44MB so it also works
; as a floppy (-fda pong.img).
;
; A flat binary is one translation unit, so the modules are pulled in
; with %include. boot.asm must come first and main.asm must start stage 2.

bits 16
org 0x7C00

%include "src/defs.inc"
%include "src/boot.asm"

stage2:
%include "src/main.asm"
%include "src/game.asm"
%include "src/video.asm"
%include "src/sound.asm"
%include "src/timer.asm"
%include "src/keyboard.asm"
%include "src/data.asm"
stage2_end:

STAGE2_SECTORS equ (stage2_end - stage2 + 511) / 512

; stage 1 reads from track 0 only (sectors 2..18)
    times -((stage2_end - stage2) > 17 * 512) db 0

; pad to a 1.44MB floppy image
    times 1474560 - ($ - $$) db 0
