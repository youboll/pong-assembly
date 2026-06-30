#!/bin/bash
nasm pong.asm -f elf64 -o asm.o
gcc -no-pie asm.o -lraylib -lGL -lm -lpthread -ldl -lrt -lX11 -o app
