; timer.asm - 60 Hz frame clock (PIT channel 0, IRQ0)

; sleep until the next timer tick
wait_frame:
    mov ax, [ticks]
    cmp ax, [last_tick]
    jne .done
    hlt
    jmp wait_frame
.done:
    mov [last_tick], ax
    ret

timer_isr:
    inc word [cs:ticks]
    push ax
    mov al, 0x20
    out 0x20, al
    pop ax
    iret

ticks       dw 0
last_tick   dw 0
