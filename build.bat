@echo off
rem Assemble pong.img with nasm.
cd /d "%~dp0"
nasm -f bin pong.asm -o pong.img || exit /b 1
echo Built pong.img
