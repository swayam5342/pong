@echo off
rem Build, then boot pong.img in QEMU with PC speaker sound.
cd /d "%~dp0"
call build.bat || exit /b 1
qemu-system-i386 -drive format=raw,file=pong.img -audiodev dsound,id=snd0 -machine pcspk-audiodev=snd0
