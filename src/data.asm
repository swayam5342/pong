; data.asm - text and game state

banner:
    db "#####  #####  #   #  #####", 0
    db "#   #  #   #  ##  #  #    ", 0
    db "#####  #   #  # # #  #  ##", 0
    db "#      #   #  #  ##  #   #", 0
    db "#      #####  #   #  #####", 0

msg_t1       db "1  -  One player  (vs CPU)", 0
msg_t2       db "2  -  Two players         ", 0
msg_t3       db "Left paddle: W / S      Right paddle: Up / Down", 0
msg_t4       db "First to 9 points wins.  ESC returns to this menu.", 0
msg_t5       db "Press 1 or 2 to start", 0
msg_p1       db "PLAYER 1", 0
msg_p2       db "PLAYER 2", 0
msg_cpu      db "     CPU", 0
msg_pong     db "PONG", 0
msg_p1_wins  db "  PLAYER 1 WINS!  ", 0
msg_p2_wins  db "  PLAYER 2 WINS!  ", 0
msg_cpu_wins db "  CPU WINS!  ", 0
msg_again    db "  Press SPACE to continue  ", 0

seed        dw 0x1234
mode        db 1                ; 1 = vs CPU, 2 = two players
frame       db 0
ai_timer    db 3
lp_y        db 0
rp_y        db 0
ball_x      db 0
ball_y      db 0
ball_dx     db 0
ball_dy     db 0
ball_delay  db 0
ball_timer  db 0
serve_timer db 0
hits        db 0
score_l     db 0
score_r     db 0
