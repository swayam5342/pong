; boot.asm - stage 1: the 512-byte boot sector
;
; Loaded by the BIOS at 0x7C00. Reads stage 2 from the sectors that
; follow it into memory right after itself (0x7E00) and jumps there.

boot:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    jmp 0x0000:boot_go          ; make sure cs = 0

boot_go:
    cld
    mov [boot_drive], dl
    mov si, 3                   ; retries

.read:
    mov ah, 0x02                ; read sectors
    mov al, STAGE2_SECTORS
    mov ch, 0                   ; cylinder 0
    mov cl, 2                   ; from sector 2
    mov dh, 0                   ; head 0
    mov dl, [boot_drive]
    mov bx, stage2
    int 0x13
    jnc stage2

    xor ah, ah                  ; reset disk and retry
    mov dl, [boot_drive]
    int 0x13
    dec si
    jnz .read

    mov si, msg_disk_err
.print:
    lodsb
    test al, al
    jz .hang
    mov ah, 0x0E
    int 0x10
    jmp .print
.hang:
    cli
    hlt
    jmp .hang

msg_disk_err db "Disk read error", 0
boot_drive   db 0

    times 510 - ($ - $$) db 0
    dw 0xAA55
