# Super Mario Bros - x86 Assembly Game

A low-level platformer game developed in **x86 Assembly Language** (8086) for the COAL course at FAST-NUCES.

## 🕹️ Features
- Real-time movement and gravity logic.
- Multi-channel audio (Jump, Coin, Mushroom, Death, and Theme music).
- Custom VGA graphics handling.
- Score tracking and collision detection.

## 🛠️ How to Run
To run this project, you need a DOS emulator:
1. Download and install [DOSBox](https://www.dosbox.com/).
2. Place `Source.asm` and all `.wav` files in your DOSBox directory.
3. Run the following commands in DOSBox:
   ```asm
   nasm -f bin Source.asm -o game.com  ;(Or use MASM/TASM depending on your code)
   game.com
