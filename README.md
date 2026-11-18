<div align="center">

<img src="docs/icon.svg" width="88" height="88" alt="Pong">

# Pong

**No OS. Just the BIOS and a ball.**

Bootable Pong written in **16-bit x86 assembly**. There's no operating system: the BIOS boots the image **straight into the game**, in VGA text mode at **60 fps**, with **PC speaker sound**.

[![Assembly](https://img.shields.io/badge/x86-16--bit%20assembly-4cb3f0?style=flat-square&logo=assemblyscript&logoColor=white&labelColor=0d3a55)](pong.asm)
[![NASM](https://img.shields.io/badge/assembler-NASM-4cb3f0?style=flat-square&logo=gnu&logoColor=white&labelColor=0d3a55)](#build-and-run)
[![QEMU](https://img.shields.io/badge/runs%20in-QEMU-4cb3f0?style=flat-square&logo=qemu&logoColor=white&labelColor=0d3a55)](#build-and-run)
[![Image](https://img.shields.io/badge/image-1.44%20MB%20floppy-4cb3f0?style=flat-square&logo=files&logoColor=white&labelColor=0d3a55)](pong.img)

[Build and Run](#build-and-run) &nbsp;&middot;&nbsp; [Controls](#controls) &nbsp;&middot;&nbsp; [Layout](#layout)

</div>

<br>

## Table of Contents

| | |
| :--- | :--- |
| **Setup** | [Prerequisites](#prerequisites) &middot; [Build and Run](#build-and-run) |
| **Play** | [Controls](#controls) |
| **Reference** | [Layout](#layout) |

<br>

## Prerequisites

| Requirement | When |
| :--- | :--- |
| **[NASM](https://nasm.us)** | To assemble `pong.img`. |
| **[QEMU](https://www.qemu.org)** | To boot it. |

<br>

## Build and Run

<details open>
<summary><b>With the scripts</b> (Windows)</summary>

```bat
build.bat      :: assemble pong.img
run.bat        :: build, then boot it in QEMU with sound
```

</details>

<details>
<summary><b>By hand</b></summary>

```sh
nasm -f bin pong.asm -o pong.img
qemu-system-i386 -drive format=raw,file=pong.img
```

</details>

> [!TIP]
> `pong.img` is a 1.44 MB floppy image, so `qemu-system-i386 -fda pong.img` works too.

<br>

## Controls

| Key | Action |
| :--- | :--- |
| `1` / `2` | One player (vs CPU) / two players. |
| `W` / `S` | Left paddle. |
| `Up` / `Down` | Right paddle. |
| `ESC` | Back to the menu. |
| `SPACE` | Continue after a win. |

First to 9 wins. The ball speeds up during long rallies.

<br>

## Layout

`pong.asm` is the entry point; it `%include`s the modules in `src/` into one flat binary.

| File | Contents |
| :--- | :--- |
| `src/defs.inc` | Constants: field size, speeds, scancodes, colours. |
| `src/boot.asm` | Stage 1 boot sector: loads the rest of the image to `0x7E00`. |
| `src/main.asm` | Hardware setup and screen flow (title, game loop, game over). |
| `src/game.asm` | Paddles, CPU player, ball physics, scoring, RNG. |
| `src/video.asm` | Drawing into a back buffer and copying it to VGA memory. |
| `src/sound.asm` | PC speaker beeps. |
| `src/timer.asm` | 60 Hz PIT interrupt and frame wait. |
| `src/keyboard.asm` | Keyboard interrupt and key state tables. |
| `src/data.asm` | Strings and game state. |
