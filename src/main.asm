; main.asm - stage 2 entry: hardware setup and the screen flow
;
;   title -> new_game -> game_loop -> game_over -> title

    mov ax, 0x0003              ; 80x25 colour text, clears screen
    int 0x10
    mov ah, 0x01                ; hide cursor
    mov cx, 0x2000
    int 0x10

    cli
    mov word [0x08*4], timer_isr
    mov word [0x08*4+2], 0
    mov word [0x09*4], kbd_isr
    mov word [0x09*4+2], 0
    mov al, 0x36                ; PIT ch0, lo/hi, mode 3
    out 0x43, al
    mov ax, PIT_DIV
    out 0x40, al
    mov al, ah
    out 0x40, al
    sti

; ---------------------------------------------------------------- title
title:
    call speaker_off
    call draw_title
    call present
    call clear_hits
.wait:
    call wait_frame
    call rand                   ; stir the RNG while the player decides
    cmp byte [hit+K_1], 0
    jne .one
    cmp byte [hit+K_2], 0
    jne .two
    jmp .wait
.one:
    mov byte [mode], 1
    jmp new_game
.two:
    mov byte [mode], 2

; ---------------------------------------------------------------- game
new_game:
    mov byte [score_l], 0
    mov byte [score_r], 0
    mov byte [lp_y], (TOP_ROW + PAD_MAX) / 2
    mov byte [rp_y], (TOP_ROW + PAD_MAX) / 2
    call rand
    test al, 1
    mov byte [ball_dx], 1
    jz .serve
    mov byte [ball_dx], -1
.serve:
    call reset_ball
    call clear_hits

game_loop:
    call wait_frame
    inc byte [frame]
    cmp byte [hit+K_ESC], 0
    jne title

    call update_paddles
    call update_ball
    call update_beep
    call draw_game
    call present

    cmp byte [score_l], WIN_SCORE
    jae .left_wins
    cmp byte [score_r], WIN_SCORE
    jae .right_wins
    jmp game_loop

.left_wins:
    mov si, msg_p1_wins
    jmp game_over
.right_wins:
    mov si, msg_p2_wins
    cmp byte [mode], 2
    je game_over
    mov si, msg_cpu_wins

; si = winner message
game_over:
    mov dh, 10
    mov bl, A_BALL
    call print_centered
    mov si, msg_again
    mov dh, 12
    mov bl, A_TEXT
    call print_centered
    call present
    call clear_hits
.wait:
    call wait_frame
    call update_beep
    cmp byte [hit+K_SPACE], 0
    je .wait
    jmp title
