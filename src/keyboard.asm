; keyboard.asm - IRQ1 handler tracking key state by scancode

kbd_isr:
    push ax
    push bx
    in al, 0x60
    cmp al, 0xE0                ; extended prefix: arrows map to same codes
    je .eoi
    xor bx, bx
    mov bl, al
    and bl, 0x7F
    test al, 0x80
    setz al                     ; 1 = pressed, 0 = released
    mov [cs:keys+bx], al
    or [cs:hit+bx], al          ; latch presses so quick taps aren't missed
.eoi:
    mov al, 0x20
    out 0x20, al
    pop bx
    pop ax
    iret

; forget earlier presses before waiting for a new one
clear_hits:
    mov di, hit
    mov cx, 128
    xor al, al
    rep stosb
    ret

keys        times 128 db 0      ; 1 while a key is held
hit         times 128 db 0      ; 1 once a key was pressed (see clear_hits)
