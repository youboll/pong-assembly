global main

; Funções da Raylib, bem mais fácil que o GLUT
extern InitWindow
extern WindowShouldClose
extern BeginDrawing
extern SetTargetFPS
extern EndDrawing
extern IsKeyDown
extern ClearBackground
extern DrawRectangle
extern CloseWindow

; Teclas - Esses valores foram pegos da raylib
    KEY_W equ 87
    KEY_S equ 83
    KEY_UP equ 265
    KEY_DOWN equ 264

section .data
    width dd 800
    height dd 450
    window_name db "Pong Simple - Multiplayer & Speedup", 0

    ; Raquetes (inteiros 32-bit assinados)
    raquete_dir_y dd 175
    raquete_esq_y dd 175

section .text
main:
    sub rsp, 8 ; Para alinhar a stack em 16 bytes antes de chamadas de funções

    ; Define a taxa de quadros por segundo
    mov rdi, 60
    call SetTargetFPS

    ; Inicializa a janela do jogo
    mov edi, [width]
    mov esi, [height]
    mov rdx, window_name
    call InitWindow

.loop:
    ; Verifica se o jogador tentou fechar a janela
    call WindowShouldClose
    cmp al, 1
    je .fim_loop

    ; 1. Entrada do Jogador 1 (Raquete Esquerda: W/S)
    ; Verifica se a tecla W está pressionada
    mov rdi, KEY_W
    call IsKeyDown
    cmp al, 1
    jne .check_s

    ; Garante que a raquete não passe do topo da tela
    mov eax, [raquete_esq_y]
    cmp eax, 10
    jle .check_s
    sub eax, 6
    mov [raquete_esq_y], eax

.check_s:
    ; Verifica se a tecla S está pressionada
    mov rdi, KEY_S
    call IsKeyDown
    cmp al, 1
    jne .check_up

    ; Garante que a raquete não passe da parte inferior da tela
    mov eax, [raquete_esq_y]
    cmp eax, 340
    jge .check_up
    add eax, 6
    mov [raquete_esq_y], eax

.check_up:
    ; 2. Entrada do Jogador 2 (Raquete Direita: Seta Cima/Seta Baixo)
    ; Verifica se a seta para cima está pressionada
    mov rdi, KEY_UP
    call IsKeyDown
    cmp al, 1
    jne .check_down

    ; Garante que a raquete não passe do topo da tela
    mov eax, [raquete_dir_y]
    cmp eax, 10
    jle .check_down
    sub eax, 6
    mov [raquete_dir_y], eax

.check_down:
    ; Verifica se a seta para baixo está pressionada
    mov rdi, KEY_DOWN
    call IsKeyDown
    cmp al, 1
    jne .draw_frame

    ; Garante que a raquete não passe da parte inferior da tela
    mov eax, [raquete_dir_y]
    cmp eax, 340
    jge .draw_frame
    add eax, 6
    mov [raquete_dir_y], eax

.draw_frame:
    ; Desenha a tela do jogo
    call BeginDrawing

    ; Limpa o fundo com a cor preta (BLACK: 0xFF000000)
    mov edi, 0xFF000000
    call ClearBackground

    ; Desenha a raquete esquerda (30, raquete_esq_y, 20, 100, WHITE)
    mov edi, 30
    mov esi, [raquete_esq_y]
    mov edx, 20
    mov ecx, 100
    mov r8d, 0xFFFFFFFF
    call DrawRectangle

    ; Desenha a raquete direita (750, raquete_dir_y, 20, 100, WHITE)
    mov edi, 750
    mov esi, [raquete_dir_y]
    mov edx, 20
    mov ecx, 100
    mov r8d, 0xFFFFFFFF
    call DrawRectangle

    call EndDrawing
    jmp .loop

.fim_loop:
    ; Fecha a janela e limpa a stack antes do return
    call CloseWindow
    add rsp, 8
    ret
