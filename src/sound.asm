; sound.asm - PC speaker beeps (PIT channel 2)

; bx = PIT divisor, cl = duration in frames
beep:
    push ax
    mov al, 0xB6                ; PIT ch2, lo/hi, square wave
    out 0x43, al
    mov ax, bx
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    mov [beep_timer], cl
    pop ax
    ret

; call once per frame; silences the speaker when the beep runs out
update_beep:
    cmp byte [beep_timer], 0
    je beep_done
    dec byte [beep_timer]
    jnz beep_done
speaker_off:
    in al, 0x61
    and al, 0xFC
    out 0x61, al
beep_done:
    ret

beep_timer  db 0
