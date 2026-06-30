#!/bin/bash
set -e

# Compile C version if raylib_pong.c exists
if [ -f "raylib_pong.c" ]; then
    echo "Compiling C version: raylib_pong.c -> raylib_pong_c..."
    gcc raylib_pong.c -o raylib_pong_c -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
    echo "C version compiled successfully."
fi
