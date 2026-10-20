# Pong

Bootable Pong written in 16-bit x86 assembly. No OS: the BIOS boots the
image straight into the game (VGA text mode, 60 fps, PC speaker sound).

## Build and run

Needs [NASM](https://nasm.us) and [QEMU](https://www.qemu.org).

```
build.bat      :: assemble pong.img
run.bat        :: build, then boot it in QEMU with sound
```

Or by hand:

```
nasm -f bin pong.asm -o pong.img
qemu-system-i386 -drive format=raw,file=pong.img
```

`pong.img` is a 1.44MB floppy image, so `qemu-system-i386 -fda pong.img` works too.

## Controls

| Key       | Action                      |
|-----------|-----------------------------|
| 1 / 2     | One player (vs CPU) / two players |
| W / S     | Left paddle                 |
| Up / Down | Right paddle                |
| ESC       | Back to menu                |
| SPACE     | Continue after a win        |

First to 9 wins. The ball speeds up during long rallies.

## Layout

`pong.asm` is the entry point; it `%include`s the modules in `src/` into
one flat binary.

| File               | Contents |
|--------------------|----------|
| `src/defs.inc`     | Constants: field size, speeds, scancodes, colours |
| `src/boot.asm`     | Stage 1 boot sector: loads the rest of the image to 0x7E00 |
| `src/main.asm`     | Hardware setup and screen flow (title, game loop, game over) |
| `src/game.asm`     | Paddles, CPU player, ball physics, scoring, RNG |
| `src/video.asm`    | Drawing into a back buffer and copying it to VGA memory |
| `src/sound.asm`    | PC speaker beeps |
| `src/timer.asm`    | 60 Hz PIT interrupt and frame wait |
| `src/keyboard.asm` | Keyboard interrupt and key state tables |
| `src/data.asm`     | Strings and game state |
