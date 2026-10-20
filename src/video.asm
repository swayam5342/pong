; video.asm - screens and text-mode drawing
;
; Everything draws into a back buffer at BUF; present copies it to VGA
; memory in one go so the screen never flickers.

draw_title:
    call clear_buf
    mov si, banner
    mov dh, 3
.row:
    mov dl, (80 - 52) / 2
    mov bl, A_BALL
    call print_wide
    inc dh
    cmp dh, 8
    jb .row

    mov si, msg_t1
    mov dh, 11
    mov bl, A_BRIGHT
    call print_centered
    mov si, msg_t2
    mov dh, 12
    call print_centered
    mov si, msg_t3
    mov dh, 15
    mov bl, A_TEXT
    call print_centered
    mov si, msg_t4
    mov dh, 16
    call print_centered
    mov si, msg_t5
    mov dh, 21
    mov bl, A_DIM
    call print_centered
    ret

draw_game:
    call clear_buf

    ; walls
    mov dh, TOP_ROW - 1
    mov ax, (A_TEXT << 8) | 0xDC    ; lower half block
    call hline
    mov dh, BOT_ROW + 1
    mov ax, (A_TEXT << 8) | 0xDF    ; upper half block
    call hline

    ; dashed centre net
    mov dh, TOP_ROW
    mov dl, 39
    mov ax, (A_DIM << 8) | 0xDE     ; right half block
.net:
    call put_char
    add dh, 2
    cmp dh, BOT_ROW
    jbe .net

    ; paddles
    mov dh, [lp_y]
    mov dl, LP_X
    mov ax, (A_LEFT << 8) | 0xDB
    call paddle
    mov dh, [rp_y]
    mov dl, RP_X
    mov ax, (A_RIGHT << 8) | 0xDB
    call paddle

    ; ball (blinks while waiting to serve)
    test byte [serve_timer], 8
    jnz .hud
    mov dh, [ball_y]
    mov dl, [ball_x]
    mov ax, (A_BALL << 8) | 0xFE
    call put_char

.hud:
    xor dh, dh
    mov dl, 2
    mov bl, A_LEFT
    mov si, msg_p1
    call print_str
    mov dl, 70
    mov bl, A_RIGHT
    mov si, msg_p2
    cmp byte [mode], 2
    je .p2
    mov si, msg_cpu
.p2:
    call print_str
    mov dl, 37
    mov bl, A_DIM
    mov si, msg_pong
    call print_str

    mov dl, 33
    mov al, [score_l]
    add al, '0'
    mov ah, A_BRIGHT
    call put_char
    mov dl, 46
    mov al, [score_r]
    add al, '0'
    call put_char
    ret

; dh = top row, dl = column, ax = attr:char
paddle:
    mov cx, PAD_H
.l:
    call put_char
    inc dh
    loop .l
    ret

; dh = row, ax = attr:char
hline:
    push di
    xor dl, dl
    call calc_di
    mov cx, 80
    rep stosw
    pop di
    ret

clear_buf:
    mov di, BUF
    mov ax, (A_TEXT << 8) | ' '
    mov cx, 80 * 25
    rep stosw
    ret

; copy back buffer to VGA text memory
present:
    push es
    mov ax, 0xB800
    mov es, ax
    mov si, BUF
    xor di, di
    mov cx, 80 * 25
    rep movsw
    pop es
    ret

; dh = row, dl = col -> di = address in back buffer
calc_di:
    push ax
    mov al, 80
    mul dh
    add al, dl
    adc ah, 0
    shl ax, 1
    add ax, BUF
    mov di, ax
    pop ax
    ret

; dh = row, dl = col, ax = attr:char
put_char:
    push di
    call calc_di
    mov [di], ax
    pop di
    ret

; si = zero-terminated string, dh = row, dl = col, bl = attr
print_str:
    push ax
    push di
    call calc_di
    mov ah, bl
.l:
    lodsb
    test al, al
    jz .done
    stosw
    jmp .l
.done:
    pop di
    pop ax
    ret

; si = string, dh = row, bl = attr; centres horizontally
print_centered:
    push si
    xor cx, cx
.len:
    lodsb
    test al, al
    jz .got
    inc cx
    jmp .len
.got:
    pop si
    mov dl, 80
    sub dl, cl
    shr dl, 1
    jmp print_str

; banner row: each '#' becomes two solid blocks, anything else two spaces.
; si advances past the terminator so rows can be printed back to back.
print_wide:
    push di
    call calc_di
    mov ah, bl
.l:
    lodsb
    test al, al
    jz .done
    cmp al, '#'
    mov al, ' '
    jne .put
    mov al, 0xDB
.put:
    stosw
    stosw
    jmp .l
.done:
    pop di
    ret
