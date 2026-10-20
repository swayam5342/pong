; game.asm - game logic: paddles, CPU player, ball physics, scoring

update_paddles:
    test byte [frame], 1        ; humans move every other frame
    jnz .ai

    cmp byte [keys+K_W], 0
    je .l_down
    cmp byte [lp_y], TOP_ROW
    jbe .l_down
    dec byte [lp_y]
.l_down:
    cmp byte [keys+K_S], 0
    je .right
    cmp byte [lp_y], PAD_MAX
    jae .right
    inc byte [lp_y]

.right:
    cmp byte [mode], 2
    jne .ai
    cmp byte [keys+K_UP], 0
    je .r_down
    cmp byte [rp_y], TOP_ROW
    jbe .r_down
    dec byte [rp_y]
.r_down:
    cmp byte [keys+K_DOWN], 0
    je .ai
    cmp byte [rp_y], PAD_MAX
    jae .ai
    inc byte [rp_y]

.ai:
    cmp byte [mode], 1
    jne .done
    dec byte [ai_timer]         ; CPU moves every 3rd frame (beatable)
    jnz .done
    mov byte [ai_timer], 3

    mov al, (TOP_ROW + PAD_MAX) / 2     ; idle: drift to centre
    cmp byte [ball_dx], 0
    jl .track
    cmp byte [ball_x], 30       ; only react once the ball is near
    jb .track
    mov al, [ball_y]
    sub al, PAD_H / 2
.track:
    cmp [rp_y], al
    je .done
    jl .ai_down
    cmp byte [rp_y], TOP_ROW
    jbe .done
    dec byte [rp_y]
    ret
.ai_down:
    cmp byte [rp_y], PAD_MAX
    jae .done
    inc byte [rp_y]
.done:
    ret

update_ball:
    cmp byte [serve_timer], 0
    je .step
    dec byte [serve_timer]
    ret
.step:
    dec byte [ball_timer]
    jnz .ret
    mov al, [ball_delay]
    mov [ball_timer], al

    ; vertical move, bounce off top/bottom walls
    mov al, [ball_y]
    add al, [ball_dy]
    cmp al, TOP_ROW
    jl .bounce
    cmp al, BOT_ROW
    jle .y_ok
.bounce:
    neg byte [ball_dy]
    mov al, [ball_y]
    add al, [ball_dy]
    mov bx, 2712                ; ~440 Hz
    mov cl, 3
    call beep
.y_ok:
    mov [ball_y], al

    ; horizontal move, check paddles
    mov bl, [ball_x]
    add bl, [ball_dx]
    cmp bl, LP_X
    jne .check_right
    mov ah, al
    sub ah, [lp_y]
    cmp ah, PAD_H               ; unsigned: also catches ball above paddle
    jae .move_x
    mov byte [ball_dx], 1
    jmp .hit
.check_right:
    cmp bl, RP_X
    jne .move_x
    mov ah, al
    sub ah, [rp_y]
    cmp ah, PAD_H
    jae .move_x
    mov byte [ball_dx], -1

.hit:
    ; ah = where on the paddle (0..4): top edge sends ball up, bottom down
    cmp ah, 1
    ja .not_top
    mov byte [ball_dy], -1
    jmp .speed
.not_top:
    cmp ah, 3
    jb .speed
    mov byte [ball_dy], 1
.speed:
    inc byte [hits]
    cmp byte [hits], HITS_PER_SPEEDUP
    jb .hit_beep
    mov byte [hits], 0
    cmp byte [ball_delay], MIN_DELAY
    jbe .hit_beep
    dec byte [ball_delay]
.hit_beep:
    mov bx, 1356                ; ~880 Hz
    mov cl, 3
    call beep
.ret:
    ret

.move_x:
    mov [ball_x], bl
    cmp bl, 0
    je .right_scores
    cmp bl, 79
    je .left_scores
    ret
.left_scores:
    inc byte [score_l]
    mov byte [ball_dx], 1       ; serve toward the player who lost the point
    jmp .scored
.right_scores:
    inc byte [score_r]
    mov byte [ball_dx], -1
.scored:
    mov bx, 5424                ; ~220 Hz
    mov cl, 12
    call beep
    ; fall through

; ball to centre, heading in ball_dx direction, random height and slope
reset_ball:
    mov byte [ball_x], 39
    cmp byte [ball_dx], 0
    jg .x_ok
    mov byte [ball_x], 40
.x_ok:
    call rand
    xor ah, ah
    mov cl, 14
    div cl                      ; ah = 0..13
    add ah, 6
    mov [ball_y], ah
    call rand
    mov byte [ball_dy], 1
    test al, 1
    jz .dy_ok
    mov byte [ball_dy], -1
.dy_ok:
    mov byte [ball_delay], START_DELAY
    mov byte [ball_timer], 1
    mov byte [hits], 0
    mov byte [serve_timer], PIT_HZ
    ret

; al/ax = pseudo-random (16-bit LCG)
rand:
    push dx
    mov ax, [seed]
    add ax, [ticks]
    mov dx, 25173
    mul dx
    add ax, 13849
    mov [seed], ax
    mov al, ah                  ; high byte is more random
    pop dx
    ret
