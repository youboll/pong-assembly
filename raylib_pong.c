#include "raylib.h"

int main() {
    // Initialize the window
    InitWindow(800, 450, "Pong Simple - Multiplayer & Speedup");
    SetTargetFPS(60);

    // Initial game state
    int paddle_left_y = 175;
    int paddle_right_y = 175;

    // Ball state (floats for smooth acceleration)
    float ball_x = 400.0f;
    float ball_y = 225.0f;
    float ball_dx = 5.0f;
    float ball_dy = 4.0f;

    // Main game loop
    while (!WindowShouldClose()) {
        // 1. Player 1 Input (Left Paddle: W/S)
        if (IsKeyDown(KEY_W) && paddle_left_y > 10) {
            paddle_left_y -= 6;
        }
        if (IsKeyDown(KEY_S) && paddle_left_y < 340) {
            paddle_left_y += 6;
        }

        // 2. Player 2 Input (Right Paddle: Up/Down arrow keys)
        if (IsKeyDown(KEY_UP) && paddle_right_y > 10) {
            paddle_right_y -= 6;
        }
        if (IsKeyDown(KEY_DOWN) && paddle_right_y < 340) {
            paddle_right_y += 6;
        }

        // 3. Update ball position
        ball_x += ball_dx;
        ball_y += ball_dy;

        // 4. Smoothly increase ball speed over time
        // 1.0005 per frame results in ~3% acceleration per second
        ball_dx *= 1.0005f;
        ball_dy *= 1.0005f;

        // 5. Wall collisions (Top / Bottom)
        if (ball_y < 10 || ball_y > 430) {
            ball_dy = -ball_dy;
        }

        // 6. Left Paddle collision (x: 30 to 50)
        if (ball_dx < 0 && ball_x >= 30 && ball_x <= 50) {
            if (ball_y >= paddle_left_y && ball_y <= paddle_left_y + 100) {
                ball_dx = -ball_dx;
            }
        }

        // 7. Right Paddle collision (x: 750 to 770)
        if (ball_dx > 0 && ball_x >= 750 && ball_x <= 770) {
            if (ball_y >= paddle_right_y && ball_y <= paddle_right_y + 100) {
                ball_dx = -ball_dx;
            }
        }

        // 8. Reset ball if it goes out of screen
        if (ball_x < 0 || ball_x > 800) {
            ball_x = 400.0f;
            ball_y = 225.0f;
            // Reset to original speed and flip starting direction
            ball_dx = (ball_dx > 0) ? -5.0f : 5.0f;
            ball_dy = (ball_dy > 0) ? -4.0f : 4.0f;
        }

        // 9. Draw frame
        BeginDrawing();
        ClearBackground(BLACK);

        // Draw Left Paddle
        DrawRectangle(30, paddle_left_y, 20, 100, WHITE);

        // Draw Right Paddle
        DrawRectangle(750, paddle_right_y, 20, 100, WHITE);

        // Draw Ball
        DrawRectangle((int)ball_x, (int)ball_y, 15, 15, WHITE);

        EndDrawing();
    }

    // Close window
    CloseWindow();
    return 0;
}
