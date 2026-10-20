; defs.inc - constants shared by all modules

BUF         equ 0x1000          ; back buffer (80*25*2 bytes) in segment 0
PIT_HZ      equ 60
PIT_DIV     equ 1193182 / PIT_HZ

TOP_ROW     equ 2               ; first row the ball/paddles may use
BOT_ROW     equ 23              ; last row the ball/paddles may use
PAD_H       equ 5
PAD_MAX     equ BOT_ROW - PAD_H + 1
LP_X        equ 2               ; left paddle column
RP_X        equ 77              ; right paddle column
WIN_SCORE   equ 9

START_DELAY equ 3               ; frames per ball step at serve
MIN_DELAY   equ 2               ; fastest ball (frames per step)
HITS_PER_SPEEDUP equ 4

; set 1 scancodes
K_ESC       equ 0x01
K_1         equ 0x02
K_2         equ 0x03
K_W         equ 0x11
K_S         equ 0x1F
K_SPACE     equ 0x39
K_UP        equ 0x48
K_DOWN      equ 0x50

; colours
A_TEXT      equ 0x07
A_DIM       equ 0x08
A_BRIGHT    equ 0x0F
A_LEFT      equ 0x0B            ; cyan
A_RIGHT     equ 0x0C            ; red
A_BALL      equ 0x0E            ; yellow
