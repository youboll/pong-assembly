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

    ; Bola (floats de precisão simples)
    bola_x dd 400.0
    bola_y dd 225.0
    bola_delta_x dd 5.0
    bola_delta_y dd 4.0

    ; Constantes de ponto flutuante (floats)
    float_zero dd 0.0
    float_one_sec dd 1.0005
    float_ten dd 10.0
    float_four_hundred_thirty dd 430.0
    float_thirty dd 30.0
    float_fifty dd 50.0
    float_seven_hundred_fifty dd 750.0
    float_seven_hundred_seventy dd 770.0
    float_minus_one dd -1.0

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
    jne .update_ball

    ; Garante que a raquete não passe da parte inferior da tela
    mov eax, [raquete_dir_y]
    cmp eax, 340
    jge .update_ball
    add eax, 6
    mov [raquete_dir_y], eax

.update_ball:
    ; 3. Atualiza a posição física da bola usando floats
    ; bola_x = bola_x + bola_delta_x
    movss xmm0, [bola_x]
    addss xmm0, [bola_delta_x]
    movss [bola_x], xmm0

    ; bola_y = bola_y + bola_delta_y
    movss xmm0, [bola_y]
    addss xmm0, [bola_delta_y]
    movss [bola_y], xmm0

    ; 4. Acelera suavemente a bola multiplicando a cada frame (1.0005)
    ; bola_delta_x = bola_delta_x * 1.0005
    movss xmm0, [bola_delta_x]
    mulss xmm0, [float_one_sec]
    movss [bola_delta_x], xmm0

    ; bola_delta_y = bola_delta_y * 1.0005
    movss xmm0, [bola_delta_y]
    mulss xmm0, [float_one_sec]
    movss [bola_delta_y], xmm0

    ; 5. Colisão com as paredes superior e inferior
    ; se bola_y < 10 ou bola_y > 430, invertemos a direção y
    movss xmm0, [bola_y]
    comiss xmm0, [float_ten]
    jb .invert_dy
    comiss xmm0, [float_four_hundred_thirty]
    jbe .collision_left_paddle

.invert_dy:
    movss xmm0, [bola_delta_y]
    mulss xmm0, [float_minus_one]
    movss [bola_delta_y], xmm0

.collision_left_paddle:
    ; 6. Colisão com a Raquete Esquerda (x entre 30 e 50)
    ; Só verifica se a bola estiver se movendo para a esquerda (bola_delta_x < 0)
    movss xmm0, [bola_delta_x]
    comiss xmm0, [float_zero]
    jae .collision_right_paddle

    ; Verifica limites de X da raquete
    movss xmm1, [bola_x]
    comiss xmm1, [float_thirty]
    jb .collision_right_paddle
    comiss xmm1, [float_fifty]
    ja .collision_right_paddle

    ; Converte a posição Y da raquete esquerda para float
    pxor xmm2, xmm2
    cvtsi2ss xmm2, [raquete_esq_y]
    movss xmm0, [bola_y]
    comiss xmm0, xmm2
    jb .collision_right_paddle ; Ignora se a bola estiver acima da raquete

    ; Raquete tem altura 100, verifica se a bola está abaixo da raquete
    mov eax, [raquete_esq_y]
    add eax, 100
    pxor xmm2, xmm2
    cvtsi2ss xmm2, eax
    comiss xmm0, xmm2
    ja .collision_right_paddle ; Ignora se a bola estiver abaixo da raquete

    ; Colisão confirmada: invertemos bola_delta_x
    movss xmm0, [bola_delta_x]
    mulss xmm0, [float_minus_one]
    movss [bola_delta_x], xmm0

.collision_right_paddle:
    ; 7. Colisão com a Raquete Direita (x entre 750 e 770)
    ; Só verifica se a bola estiver se movendo para a direita (bola_delta_x > 0)
    movss xmm0, [bola_delta_x]
    comiss xmm0, [float_zero]
    jbe .draw_frame

    ; Verifica limites de X da raquete
    movss xmm1, [bola_x]
    comiss xmm1, [float_seven_hundred_fifty]
    jb .draw_frame
    comiss xmm1, [float_seven_hundred_seventy]
    ja .draw_frame

    ; Converte a posição Y da raquete direita para float
    pxor xmm2, xmm2
    cvtsi2ss xmm2, [raquete_dir_y]
    movss xmm0, [bola_y]
    comiss xmm0, xmm2
    jb .draw_frame ; Ignora se a bola estiver acima da raquete

    ; Raquete tem altura 100, verifica se a bola está abaixo da raquete
    mov eax, [raquete_dir_y]
    add eax, 100
    pxor xmm2, xmm2
    cvtsi2ss xmm2, eax
    comiss xmm0, xmm2
    ja .draw_frame ; Ignora se a bola estiver abaixo da raquete

    ; Colisão confirmada: invertemos bola_delta_x
    movss xmm0, [bola_delta_x]
    mulss xmm0, [float_minus_one]
    movss [bola_delta_x], xmm0

.draw_frame:
    ; 9. Desenha a tela do jogo
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

    ; Desenha a bola converting float to int truncando
    movss xmm0, [bola_x]
    cvttss2si edi, xmm0
    movss xmm0, [bola_y]
    cvttss2si esi, xmm0
    mov edx, 15
    mov ecx, 15
    mov r8d, 0xFFFFFFFF
    call DrawRectangle

    call EndDrawing
    jmp .loop

.fim_loop:
    ; Fecha a janela e limpa a stack antes do return
    call CloseWindow
    add rsp, 8
    ret
