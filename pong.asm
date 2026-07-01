global main

; Funções da Raylib, bem mais fácil que o GLUT
extern InitWindow
extern WindowShouldClose
extern BeginDrawing
extern SetTargetFPS
extern EndDrawing
extern ClearBackground
extern CloseWindow

section .data
    width dd 800
    height dd 450
    window_name db "Pong Simple - Multiplayer & Speedup", 0

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

    ; Desenha a tela do jogo
    call BeginDrawing

    ; Limpa o fundo com a cor preta (BLACK: 0xFF000000)
    mov edi, 0xFF000000
    call ClearBackground

    call EndDrawing
    jmp .loop

.fim_loop:
    ; Fecha a janela e limpa a stack antes do return
    call CloseWindow
    add rsp, 8
    ret
