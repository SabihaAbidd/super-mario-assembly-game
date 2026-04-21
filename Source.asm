TITLE Super Mario Console Game (Irvine32)

INCLUDE Irvine32.inc

; ====================================================================================
; DATA SECTION
; ====================================================================================
.data
    ; Page-Based Scrolling System (Like Zelda 1)
    currentPage     DWORD 0          ; Current screen page (0, 1, or 2)
    maxPages        DWORD 2          ; Total pages in level (3 screens: 0, 1, 2)
    pageTransition  BYTE 0           ; Flag for page change
    ; --------------------------------------------------------------------------------
    ; MENU & SYSTEM STRINGS
    ; --------------------------------------------------------------------------------
    titleLine1 BYTE "  _____ _    _ _____  ______ _____    __  __           _____  _____ ____    ____  _____   ____   _____ ",0
    titleLine2 BYTE " / ____| |  | |  __ \|  ____|  __ \  |  \/  |   /\    |  __ \|_   _/ __ \  |  _ \|  __ \ / __ \ / ____|",0
    titleLine3 BYTE "| (___ | |  | | |__) | |__  | |__) | | \  / |  /  \   | |__) | | || |  | | | |_) | |__) | |  | | (___  ",0
    titleLine4 BYTE " \___ \| |  | |  ___/|  __| |  _  /  | |\/| | / /\ \  |  _  /  | || |  | | |  _ <|  _  /| |  | |\___ \ ",0
    titleLine5 BYTE " ____) | |__| | |    | |____| | \ \  | |  | |/ ____ \ | | \ \ _| || |__| | | |_) | | \ \| |__| |____) |",0
    titleLine6 BYTE "|_____/ \____/|_|    |______|_|  \_\ |_|  |_/_/    \_\_|  \_\_____ \____/  |____/|_|  \_ \____/|_____/ ",0

    rollNumber  BYTE "Roll Number: 24I-0587",0
    pressEnter  BYTE "Press ENTER to continue...",0

    menuTitle   BYTE "MAIN MENU",0
    menuOption1 BYTE "1. Start Game",0
    menuOption2 BYTE "2. Start Level 2",0
    menuOption3 BYTE "3. High Score",0
    menuOption4 BYTE "4. Instructions",0
    menuOption5 BYTE "5. Exit",0
    menuPrompt  BYTE "Select an option: ",0

    instrTitle  BYTE "INSTRUCTIONS",0
    instrLine1  BYTE "W / UP Arrow    - Jump",0
    instrLine2  BYTE "A / LEFT Arrow  - Move Left",0
    instrLine3  BYTE "D / RIGHT Arrow - Move Right",0
    instrLine4  BYTE "P               - Pause Game",0
    instrLine5  BYTE "X               - Exit to Menu",0

    highTitle   BYTE "HIGH SCORE",0
    strMario    BYTE "MARIO",0
    highScore   DWORD 0

    pauseLine1  BYTE "=========== PAUSED ===========",0
    pauseLine2  BYTE "   R - Resume     X - Exit    ",0

    ; --------------------------------------------------------------------------------
    ; HUD VARIABLES
    ; --------------------------------------------------------------------------------
    score        DWORD 0
    coins        BYTE  0
    lives        BYTE  3
    gameTime     WORD  400
    
    strMarioHUD BYTE "MARIO ",0
    strLivesHUD BYTE "LIVES x",0
    strCoinHUD  BYTE "COINS : ",0
    strWorldHUD BYTE "WORLD 1-1",0
    strTimeHUD  BYTE "TIME ",0

    ; --------------------------------------------------------------------------------
    ; GAME PHYSICS VARS
    ; --------------------------------------------------------------------------------
    playerX      BYTE 10        
    playerY      BYTE 21
    oldPlayerX   BYTE 10
    oldPlayerY   BYTE 21
    
    velY         SBYTE 0        
    GRAVITY      = 1            
    JUMP_FORCE   = -4           
    JUMP_FORCE_L2 = -4          ; Match Level 1 jump height for Level 2
    onGround     BYTE  1      
    
    checkX       BYTE ?
    checkY       BYTE ?  
    colResult    BYTE ?
    
    ; ============================================================================
    ; POWER-UP SYSTEM - Super Mushroom
    ; ============================================================================
    ; Power states
    POWER_SMALL     = 0                        ; Normal small Mario
    POWER_SUPER     = 1                        ; Powered-up Mario (has mushroom)
    POWER_PROTECT_FRAMES = 45                  ; Temporary invincibility frames
    
    powerState      BYTE POWER_SMALL           ; Current power state
    powerUpTimer    BYTE 0                     ; Timer for power-up protection blink

    ; --------------------------------------------------------------------------------
    ; LEVEL DATA (EXTENDED FOR SCROLLING)
    ; --------------------------------------------------------------------------------
    ; Platforms - extended for 3 pages (using WORD for X to support values > 255)
    PlatCount    = 18
    PlatStartX   WORD 15, 35, 55, 75, 90, 5, 125, 145, 165, 185, 205, 225, 245, 270, 295, 320, 340, 355
    PlatEndX     WORD 24, 44, 64, 84, 99, 14, 134, 154, 174, 194, 214, 234, 254, 279, 304, 329, 349, 364
    PlatY        BYTE 17, 15, 18, 13, 16, 19, 17, 15, 18, 16, 14, 17, 17, 15, 18, 14, 16, 19

    ; ============================================================================
    ; BRICK BLOCK SYSTEM - Classic Mario brown brick platforms with ? blocks
    ; Drawn as SOLID COLORED BLOCKS (no ASCII art)
    ; ============================================================================
    MAX_BRICKS      = 50                       ; Maximum number of brick blocks
    brickX          WORD MAX_BRICKS DUP(?)     ; X position (world coords)
    brickY          BYTE MAX_BRICKS DUP(?)     ; Y position
    brickCount      BYTE 0                     ; Actual number of brick blocks
    
    ; Brick colors - SOLID BLOCKS (background color creates the solid rectangle)
    ; Brown/orange (6) on brown (6) = solid brown block
    GP_BRICK        = 6 + (6 * 16)             ; Solid brown/orange for bricks
    
    ; ============================================================================
    ; PIPE SYSTEM - NES-style 2-tile wide green pipes
    ; Drawn as SOLID GREEN BLOCKS (no ASCII art, just colored rectangles)
    ; ============================================================================
    ; Pipe dimensions
    PipeCount       = 8                        ; Number of pipes
    PipeX           WORD 28, 48, 88, 138, 168, 260, 310, 340
    PipeHeight      BYTE 3,  3,  2,  4,  3,  3,  4,  3
    PIPE_BODY_WIDTH = 2                        ; Main body is 2 tiles wide
    PIPE_TOP_WIDTH  = 4                        ; Top flange is 4 tiles wide (extends 1 on each side)
    
    ; Pipe colors - SOLID BLOCKS (same foreground and background = solid rectangle)
    ; Bright green (10) on bright green (10) = solid green block
    GP_PIPE_BODY    = 10 + (10 * 16)           ; Solid bright green for pipe body
    GP_PIPE_TOP     = 2 + (2 * 16)             ; Solid dark green for pipe top rim
    GP_PIPE_SHADE   = 2 + (10 * 16)            ; Dark green on bright green (shading)
    
    ; --------------------------------------------------------------------------------
    ; COIN SYSTEM - NES MARIO STYLE: Coins ONLY from ? blocks, NOT pre-placed!
    ; --------------------------------------------------------------------------------
    ; NOTE: In classic NES Mario, there are NO coins sitting in the level.
    ; Coins only appear when hitting ? blocks from below, then auto-collect.
    ; The old pre-placed coin system is DISABLED.
    MAX_COINS    = 36                                    ; Legacy - kept for compatibility
    CoinX        WORD MAX_COINS DUP(?)                   ; Legacy arrays (not used)
    CoinY        BYTE MAX_COINS DUP(?)
    CoinActive   BYTE MAX_COINS DUP(?)
    CoinCount    BYTE 0                                   ; Kept at 0 - no pre-placed coins
    COIN_CHAR    BYTE 'o'                                 ; Not used anymore
    COIN_POINTS  = 200                                    ; Points awarded per coin from ? block          

    ; --------------------------------------------------------------------------------
    ; GAME STATE SYSTEM
    ; --------------------------------------------------------------------------------
    ; Game states: 0 = PLAYING, 1 = LEVEL_COMPLETE, 2 = GAME_OVER, 3 = PLAYER_DYING
    STATE_PLAYING       = 0
    STATE_LEVEL_COMPLETE = 1
    STATE_GAME_OVER     = 2
    STATE_PLAYER_DYING  = 3
    
    gameState       BYTE STATE_PLAYING    ; Current game state
    currentLevel    DWORD 1               ; 1 = Level 1, 2 = Level 2
    levelCompleteTimer BYTE 0             ; Timer for level complete sequence
    deathTimer      BYTE 0                ; Timer for death animation
    
    ; Respawn position (level start)
    respawnX        BYTE 10               ; X position to respawn Mario
    respawnY        BYTE 21               ; Y position to respawn Mario
    respawnPage     DWORD 0               ; Page to respawn on
    
    ; Game state strings - Clean minimal design (no boxes/borders)
    strGameOver1    BYTE "GAME OVER",0
    strGameOver2    BYTE "Press ENTER to continue...",0
    
    strLevelComplete1 BYTE "=====================================",0
    strLevelComplete2 BYTE "         LEVEL COMPLETE!            ",0
    strLevelComplete3 BYTE "          BONUS: +1000              ",0
    strLevelComplete4 BYTE "=====================================",0
    
    ; --------------------------------------------------------------------------------
    ; GOOMBA ENEMY SYSTEM
    ; --------------------------------------------------------------------------------
    MAX_GOOMBAS     = 10                  ; Maximum number of goombas
    GOOMBA_POINTS   = 100                 ; Points for defeating a goomba
    GOOMBA_CHAR     BYTE 'G'              ; Character to display for goomba
    
    ; Goomba states: 0 = inactive, 1 = walking, 2 = dying/squished
    GOOMBA_INACTIVE = 0
    GOOMBA_WALKING  = 1
    GOOMBA_DYING    = 2
    
    ; ==========================================================================
    ; GOOMBA SPEED CONTROL - Adjust GOOMBA_MOVE_DELAY to change speed
    ; Higher value = slower goombas. Value of 3 means move every 3rd frame.
    ; ==========================================================================
    GOOMBA_MOVE_DELAY = 4                 ; Move every Nth frame (4 = slower, 1 = fastest)
    
    ; ==========================================================================
    ; STOMP DETECTION CONSTANTS - Adjust for easier/harder stomping
    ; Higher values = easier stomping
    ; ==========================================================================
    STOMP_X_RANGE     = 2                 ; X range for stomp detection (2 = forgiving)
    STOMP_Y_RANGE     = 2                 ; Y range for stomp detection (2 = forgiving)
    DAMAGE_RANGE      = 1                 ; Range for damage (must be close)
    
    ; Goomba data arrays (world coordinates, WORD for X to support > 255)
    goombaX         WORD MAX_GOOMBAS DUP(?)    ; X position (world coords)
    goombaY         BYTE MAX_GOOMBAS DUP(?)    ; Y position
    goombaDir       SBYTE MAX_GOOMBAS DUP(?)   ; Direction: -1 = left, +1 = right
    goombaState     BYTE MAX_GOOMBAS DUP(?)    ; State: 0=inactive, 1=walking, 2=dying
    goombaTimer     BYTE MAX_GOOMBAS DUP(?)    ; Timer for animations/death
    goombaOldX      WORD MAX_GOOMBAS DUP(?)    ; Previous X for erasing
    goombaOldY      BYTE MAX_GOOMBAS DUP(?)    ; Previous Y for erasing
    goombaMoveCounter BYTE MAX_GOOMBAS DUP(?)  ; Frame counter for speed throttling
    
    ; Mario's previous Y for stomp detection
    marioPrevY      BYTE 21                    ; Mario's Y in previous frame
    
    ; Goomba color
    GP_GOOMBA       = 4 + (9 * 16)             ; Dark red on light blue
    GP_GOOMBA_DYING = 6 + (9 * 16)             ; Brown on light blue (squished)
    
    ; ============================================================================
    ; KOOPA TROOPA ENEMY SYSTEM - Shell mechanics with kick + slide
    ; ============================================================================
    MAX_KOOPAS      = 8                        ; Maximum number of koopas
    KOOPA_POINTS    = 200                      ; Points for defeating a koopa
    SHELL_KICK_POINTS = 100                    ; Points for kicking a shell
    SHELL_KILL_POINTS = 500                    ; Points for shell killing another enemy
    
    ; Koopa states: 0 = inactive, 1 = walking, 2 = shell idle, 3 = shell sliding
    KOOPA_INACTIVE      = 0
    KOOPA_WALKING       = 1
    KOOPA_SHELL_IDLE    = 2
    KOOPA_SHELL_SLIDING = 3
    
    ; Koopa speed control - slower than goombas
    KOOPA_MOVE_DELAY    = 6                    ; Move every 6th frame (slower than goombas)
    SHELL_SLIDE_DELAY   = 1                    ; Shells slide fast (every frame)
    
    ; Koopa characters
    KOOPA_WALK_CHAR     BYTE 'K'               ; Walking koopa
    KOOPA_SHELL_CHAR    BYTE 'O'               ; Shell (both idle and sliding)
    
    ; Koopa data arrays (world coordinates, WORD for X to support > 255)
    koopaX          WORD MAX_KOOPAS DUP(?)     ; X position (world coords)
    koopaY          BYTE MAX_KOOPAS DUP(?)     ; Y position
    koopaDir        SBYTE MAX_KOOPAS DUP(?)    ; Direction: -1 = left, +1 = right
    koopaState      BYTE MAX_KOOPAS DUP(?)     ; State: see constants above
    koopaTimer      BYTE MAX_KOOPAS DUP(?)     ; Timer for animations/transitions
    koopaOldX       WORD MAX_KOOPAS DUP(?)     ; Previous X for erasing
    koopaOldY       BYTE MAX_KOOPAS DUP(?)     ; Previous Y for erasing
    koopaMoveCounter BYTE MAX_KOOPAS DUP(?)    ; Frame counter for speed throttling
    
    ; Koopa colors
    GP_KOOPA_WALK   = 10 + (9 * 16)            ; Green on light blue (walking)
    GP_KOOPA_SHELL  = 14 + (9 * 16)            ; Yellow on light blue (shell)
    GP_KOOPA_SLIDE  = 12 + (9 * 16)            ; Red on light blue (sliding shell)
    
    ; --------------------------------------------------------------------------------
    ; QUESTION BLOCK SYSTEM - Mario-style '?' blocks that give coins or mushrooms
    ; --------------------------------------------------------------------------------
    ; Question block states
    QBLOCK_ACTIVE   = 1                        ; Block can be hit for coins
    QBLOCK_USED     = 0                        ; Block already hit, now empty
    
    ; Question block types
    QBLOCK_TYPE_COIN    = 0                    ; Gives coin when hit
    QBLOCK_TYPE_MUSHROOM = 1                   ; Gives mushroom when hit
    
    ; Question block data arrays (world coordinates)
    MAX_QBLOCKS     = 15                       ; Maximum number of question blocks
    qblockX         WORD MAX_QBLOCKS DUP(?)    ; X position (world coords)
    qblockY         BYTE MAX_QBLOCKS DUP(?)    ; Y position
    qblockState     BYTE MAX_QBLOCKS DUP(?)    ; QBLOCK_ACTIVE or QBLOCK_USED
    qblockType      BYTE MAX_QBLOCKS DUP(?)    ; QBLOCK_TYPE_COIN or QBLOCK_TYPE_MUSHROOM
    qblockCount     BYTE 0                     ; Actual number of question blocks
    
    ; Question block appearance
    ; QBLOCK_CHAR is still used as the '?' displayed on the block
    QBLOCK_CHAR     BYTE '?'                   ; Character for active question block
    
    ; Question block colors - SOLID BLOCKS with '?' overlay
    ; Yellow (14) on yellow (14) = solid yellow block, with black '?' on top
    GP_QBLOCK       = 0 + (14 * 16)            ; Black text on solid yellow block
    GP_USEDBLOCK    = 8 + (8 * 16)             ; Solid dark gray (used/empty block)
    
    ; Points for hitting a question block
    QBLOCK_POINTS   = 200                      ; Same as coin points
    
    ; ============================================================================
    ; SUPER MUSHROOM POWER-UP SYSTEM
    ; ============================================================================
    MAX_MUSHROOMS   = 4                        ; Maximum active mushrooms
    MUSHROOM_POINTS = 1000                     ; Points for collecting mushroom
    MUSHROOM_MOVE_DELAY = 3                    ; Horizontal speed control
    MUSHROOM_INACTIVE   = 0
    MUSHROOM_ACTIVE     = 1
    MUSHROOM_REMOVE     = 2
    
    ; Mushroom data arrays (world coordinates)
    mushroomX       WORD MAX_MUSHROOMS DUP(?)  ; X position (world coords)
    mushroomY       BYTE MAX_MUSHROOMS DUP(?)  ; Y position
    mushroomActive  BYTE MAX_MUSHROOMS DUP(?)  ; State: inactive/active/remove
    mushroomDir     SBYTE MAX_MUSHROOMS DUP(?) ; Direction: -1 = left, +1 = right
    mushroomOldX    WORD MAX_MUSHROOMS DUP(?)  ; Previous X for erasing
    mushroomOldY    BYTE MAX_MUSHROOMS DUP(?)  ; Previous Y for erasing
    mushroomMoveCounter BYTE MAX_MUSHROOMS DUP(?) ; Speed throttle counter
    
    ; Mushroom appearance
    MUSHROOM_CHAR   BYTE 'U'                   ; Character for mushroom
    GP_MUSHROOM     = 12 + (9 * 16)            ; Red on light blue (classic mushroom color)
    
    ; --------------------------------------------------------------------------------
    ; COIN POP ANIMATION SYSTEM - Visual effect when hitting question blocks
    ; --------------------------------------------------------------------------------
    MAX_COIN_ANIMS  = 8                        ; Maximum simultaneous coin animations
    
    coinAnimActive  BYTE MAX_COIN_ANIMS DUP(?) ; 1 = animation active, 0 = inactive
    coinAnimX       WORD MAX_COIN_ANIMS DUP(?) ; X position (world coords)
    coinAnimY       BYTE MAX_COIN_ANIMS DUP(?) ; Y position (starts above block)
    coinAnimTimer   BYTE MAX_COIN_ANIMS DUP(?) ; Countdown timer (frames remaining)
    coinAnimStartY  BYTE MAX_COIN_ANIMS DUP(?) ; Starting Y for animation reference
    
    ; Animation parameters
    COIN_ANIM_DURATION = 10                    ; Total frames for animation
    COIN_ANIM_RISE     = 3                     ; How many tiles the coin rises
    
    ; Coin animation color - SOLID GOLD BLOCK
    GP_COIN_ANIM    = 14 + (14 * 16)           ; Solid yellow/gold block
    
    ; --------------------------------------------------------------------------------
    ; FLAGPOLE SYSTEM
    ; --------------------------------------------------------------------------------
    ; Flagpole position (world coordinates) - placed near end of level
    flagpoleX       WORD 350                   ; X position of flagpole (world coords)
    flagpoleTopY    BYTE 8                     ; Top of flagpole (flag position)
    flagpoleBottomY BYTE 21                    ; Bottom of flagpole (ground level - 1)
    flagTouched     BYTE 0                     ; Has Mario touched the flag?
    flagSlideY      BYTE 0                     ; Mario's Y during flag slide animation
    
    ; Flagpole characters
    FLAG_CHAR       BYTE 'F'                   ; Flag character
    POLE_CHAR       BYTE '|'                   ; Pole character
    
    ; Flagpole color
    GP_FLAG         = 10 + (9 * 16)            ; Bright green on light blue
    GP_POLE         = 8 + (9 * 16)             ; Dark gray on light blue
    
    ; Level complete bonus
    LEVEL_BONUS     = 1000                     ; Bonus points for completing level

    ; ============================================================================
    ; HILLS AND GRASS SYSTEM - NES-style background decoration
    ; Drawn as SOLID COLORED BLOCKS (no ASCII art)
    ; ============================================================================
    ; Hill positions (world X coordinates, screen Y varies by size)
    MAX_HILLS       = 6                        ; Number of decorative hills
    hillX           WORD 5, 70, 140, 200, 280, 330     ; X positions
    hillSize        BYTE 3, 2, 3, 2, 3, 2              ; Size: 2=small, 3=large
    
    ; Hill colors - SOLID GREEN BLOCKS
    GP_HILL_BODY    = 2 + (2 * 16)             ; Solid dark green for hill body
    GP_HILL_TOP     = 10 + (10 * 16)           ; Solid bright green for hill top
    GP_HILL_EYES    = 0 + (2 * 16)             ; Black on dark green for eyes
    
    ; Grass colors - Green strip on top of brown ground
    GP_GRASS        = 10 + (10 * 16)           ; Solid bright green grass strip

    ; --------------------------------------------------------------------------------
    ; ART ASSETS
    ; --------------------------------------------------------------------------------
    ; Block character for solid fills
    blockChar    BYTE 219  ; Single solid block character █
    
    ; --------------------------------------------------------------------------------
    ; BLOCKY LETTER PATTERNS (3 wide x 5 tall)
    ; Each byte is a row: bits 0-2 represent columns (1 = filled, 0 = empty)
    ; --------------------------------------------------------------------------------
    ; Letter 'M'
    letterM BYTE 111b, 111b, 101b, 101b, 101b  ; M shape
    ; Letter 'A'
    letterA BYTE 010b, 101b, 111b, 101b, 101b  ; A shape
    ; Letter 'R'
    letterR BYTE 110b, 101b, 110b, 101b, 101b  ; R shape
    ; Letter 'I'
    letterI BYTE 111b, 010b, 010b, 010b, 111b  ; I shape
    ; Letter 'O'
    letterO BYTE 111b, 101b, 101b, 101b, 111b  ; O shape
    ; Letter 'L'
    letterL BYTE 100b, 100b, 100b, 100b, 111b  ; L shape
    ; Letter 'V'
    letterV BYTE 101b, 101b, 101b, 101b, 010b  ; V shape
    ; Letter 'E'
    letterE BYTE 111b, 100b, 110b, 100b, 111b  ; E shape
    ; Letter 'S'
    letterS BYTE 111b, 100b, 111b, 001b, 111b  ; S shape
    ; Letter 'C'
    letterC BYTE 111b, 100b, 100b, 100b, 111b  ; C shape
    ; Letter 'N'
    letterN BYTE 101b, 111b, 111b, 101b, 101b  ; N shape
    ; Letter 'W'
    letterW BYTE 101b, 101b, 101b, 111b, 111b  ; W shape
    ; Letter 'D'
    letterD BYTE 110b, 101b, 101b, 101b, 110b  ; D shape
    ; Letter 'T'
    letterT BYTE 111b, 010b, 010b, 010b, 010b  ; T shape
    ; Letter 'X' (for times symbol)
    letterX BYTE 101b, 101b, 010b, 101b, 101b  ; X shape
    ; Digit '1'
    digit1  BYTE 010b, 110b, 010b, 010b, 111b  ; 1 shape
    ; Digit '-' (hyphen)
    letterHyphen BYTE 000b, 000b, 111b, 000b, 000b  ; - shape
    ; Colon ':'
    letterColon BYTE 000b, 010b, 000b, 010b, 000b  ; : shape          
    
    cloudShape1  BYTE "  *** ",0
    cloudShape2  BYTE " * * * ",0

    cloudLine1 BYTE "      ____                                      ____                                      ____",0
    cloudLine2 BYTE "    /      \                                  /      \                                  /      \",0
    cloudLine3 BYTE "   |  O  O  |                                |  O  O  |                                |  O  O  |",0
    hillLine1  BYTE "          ___                                      ___                                      ___",0
    hillLine2  BYTE "       __/   \__                                __/   \__                                __/   \__",0
    hillLine3  BYTE "   __/         \__                        __/         \__                       __/         \__",0

    ; --------------------------------------------------------------------------------
    ; CONSTANTS & COLORS
    ; --------------------------------------------------------------------------------
    SCREEN_MIN_X  = 0
    SCREEN_MAX_X  = 118            
    PLAY_MIN_Y    = 2   
    PLAY_MAX_Y    = 21 
    GROUND_TOP    = 22
    
    ; Page-based level constants
    PAGE_WIDTH    = 119              ; Width of one screen page
    LEVEL_END     = 235              ; Legacy total width
    LEVEL_MAX_X   = 360              ; Max world X for enemies/power-ups

    COLOR_TITLE   = 14 + (0 * 16)     
    COLOR_MENU    = 15 + (0 * 16)     
    COLOR_CLOUD   = 7  + (0 * 16)     
    COLOR_GROUND  = 6  + (0 * 16)     
    
    ; Block-based Game Colors (foreground + background*16)
    ; SOLID BLOCK COLORS: Use same color for FG and BG for filled rectangles
    ; Sky background uses light blue (9)
    GP_BG         = 9  + (9 * 16)     ; Solid light blue (sky background)
    GP_GROUND     = 6  + (6 * 16)     ; Solid brown (ground block)
    GP_PLAYER        = 12 + (9 * 16)     ; Light red on light blue (Mario)
    GP_PLAYER_SUPER  = 14 + (9 * 16)     ; Yellow on light blue (Super Mario)
    GP_PLAYER_L2     = 12 + (0 * 16)     ; Red on black for Level 2
    GP_PLAYER_SUPER_L2 = 14 + (0 * 16)   ; Yellow on black for Level 2
    GP_PLAT       = 14 + (14 * 16)    ; Solid yellow/tan (platforms)
    GP_CLOUD      = 15 + (15 * 16)    ; Solid white (clouds)
    GP_ERASE      = 9  + (9 * 16)     ; Light blue (for erasing = sky)
    
    ; HUD Colors with high-intensity (bright) mode
    GP_HUD_BG     = 0  + (0 * 16)     ; Black on black (background fill)
    GP_HUD_BRIGHT = 14 + 8 + (0 * 16) ; Bright yellow (14+8) on black - HIGH INTENSITY
    GP_HUD_WHITE  = 15 + 8 + (0 * 16) ; Bright white (15+8) on black - HIGH INTENSITY
    GP_HUD_CYAN   = 11 + 8 + (0 * 16) ; Bright cyan (11+8) on black - HIGH INTENSITY    
    
    ; ====================================================================================
    ; SECTION 9: FILE HANDLING DATA (Paste this INSIDE .data section)
    ; ====================================================================================
    saveFilename    BYTE "mario_save.bin",0
    fileHandle      DWORD ?
    
    ; Buffer for Player Name (32 chars max)
    playerName      BYTE 32 DUP(0)
    strEnterName    BYTE "ENTER PLAYER NAME: ",0
    
    ; Messages
    msgSaved        BYTE "   GAME SAVED!    ",0
    msgLoaded       BYTE "   GAME LOADED!   ",0
    msgErr          BYTE "   SAVE FAILED!   ",0
    
    ; Pause Menu Update String
    pauseSaveOpt    BYTE "   S - Save Game  ",0

    ; Level 2 start flag (reset score/coins when starting directly)
    level2ResetFlag BYTE 0
    ; --------------------------------------------------------------------------------
    ; LEVEL 2 (CASTLE) MAP/TILES
    ; --------------------------------------------------------------------------------
    TILE_EMPTY      = 0
    TILE_WALL       = 1
    TILE_LAVA       = 2
    TILE_BRIDGE     = 3
    TILE_PLATFORM   = 4

    LEVEL2_ROWS     = 25
    LEVEL2_COLS     = 119
    LEVEL2_MAX_PAGES = 3
    LEVEL2_LAVA_ROW = LEVEL2_ROWS-1
    LEVEL2_BRIDGE_ROW = LEVEL2_ROWS-2

    CastleLevelMap  BYTE LEVEL2_ROWS * LEVEL2_COLS DUP(0)

    ; Castle colors (same solid-tile style as level 1)
    GP_CASTLE_BG     = 0  + (0 * 16)   ; Black background
    GP_CASTLE_WALL   = 8  + (8 * 16)   ; Dark gray wall
    GP_CASTLE_LAVA   = 12 + (4 * 16)   ; Red foreground on brown-ish bg
    GP_CASTLE_BRIDGE = 7  + (7 * 16)   ; Gray ground/bridge
    GP_CASTLE_PLAT   = 8  + (8 * 16)   ; Dark gray platform

    ; Firebar (Level 2) data - single rotating fireball
    GP_FIREBAR        = 12 + (0 * 16)   ; Dark orange on black
    FIREBAR_LEN       = 1
    FirebarCenterX    BYTE 70           ; Near top-middle above bridge
    FirebarCenterY    BYTE 6
    FirebarPhase      BYTE 0            ; 0-3
    FirebarTimer      BYTE 6            ; counts down; then phase++
    firebarX          BYTE FIREBAR_LEN DUP(0)
    firebarY          BYTE FIREBAR_LEN DUP(0)
    firebarOldX       BYTE FIREBAR_LEN DUP(0)
    firebarOldY       BYTE FIREBAR_LEN DUP(0)

    ; Bowser boss (Level 2 only)
    GP_BOWSER         = 2 + (7 * 16)     ; Gray/green
    GP_BOWSER_FIRE    = 12 + (0 * 16)    ; Dark orange
    BOWSER_MAX_FIRE   = 3
    BowserX           BYTE 0
    BowserY           BYTE 0
    BowserPrevX       BYTE 0
    BowserPrevY       BYTE 0
    BowserDir         SDWORD ?
    BowserLeftBound   SDWORD ?
    BowserRightBound  SDWORD ?
    BowserFireCooldown SDWORD ?
    BowserFireX       BYTE BOWSER_MAX_FIRE DUP(0)
    BowserFireY       BYTE BOWSER_MAX_FIRE DUP(0)
    BowserFireActive  BYTE BOWSER_MAX_FIRE DUP(0)

    ; Sound file paths (support both Debug folder and project root)
    jumpSoundLocal   BYTE ".\\mario-jump-sound-effect_1.wav",0
    jumpSoundParent  BYTE "..\\mario-jump-sound-effect_1.wav",0
    coinSoundLocal   BYTE ".\\super-mario-coin-sound.wav",0
    coinSoundParent  BYTE "..\\super-mario-coin-sound.wav",0
    enemySoundLocal  BYTE ".\\super-mario-death-sound-sound-effect.wav",0
    enemySoundParent BYTE "..\\super-mario-death-sound-sound-effect.wav",0
    powerSoundLocal  BYTE ".\\super_mario_bros_mushroom_sound_effect.wav",0
    powerSoundParent BYTE "..\\super_mario_bros_mushroom_sound_effect.wav",0
    level1SoundLocal BYTE ".\\level_1.wav",0
    level1SoundParent BYTE "..\\level_1.wav",0
Beep PROTO :DWORD, :DWORD
PlaySoundA PROTO :DWORD, :DWORD, :DWORD   ; from winmm

SND_ASYNC      EQU 00000001h
SND_NODEFAULT  EQU 00000002h
SND_LOOP       EQU 00000008h
SND_FILENAME   EQU 00020000h

INCLUDELIB winmm.lib

; ====================================================================================
; CODE SECTION
; ====================================================================================
.code

; ------------------------------------------------------------
; Level 2 tile sampling helpers (code section)
; ------------------------------------------------------------
Level2GetTile PROC USES ebx edx ; Inputs: AL = x (screen), AH = y; Returns AL = tile id
    movzx ebx, ah
    cmp ebx, LEVEL2_ROWS
    jae L2GetEmpty
    movzx edx, al
    cmp edx, LEVEL2_COLS
    jae L2GetEmpty
    imul ebx, LEVEL2_COLS
    add ebx, edx
    mov al, CastleLevelMap[ebx]
    ret
L2GetEmpty:
    mov al, TILE_EMPTY
    ret
Level2GetTile ENDP

Level2IsSolid PROC ; Inputs: AL=x, AH=y; Returns AL=1 solid, 0 empty
    call Level2GetTile
    cmp al, TILE_WALL
    je L2Solid
    cmp al, TILE_BRIDGE
    je L2Solid
    mov al, 0
    ret
L2Solid:
    mov al, 1
    ret
Level2IsSolid ENDP

Level2IsPlatform PROC ; Inputs: AL=x, AH=y; Returns AL=1 if platform
    call Level2GetTile
    cmp al, TILE_PLATFORM
    sete al
    ret
Level2IsPlatform ENDP

Level2IsLava PROC ; Inputs: AL=x, AH=y; Returns AL=1 if lava
    call Level2GetTile
    cmp al, TILE_LAVA
    sete al
    ret
Level2IsLava ENDP

; ------------------------------------------------------------
; Level 2 helpers: erase a tile-sized region at (AL=x, AH=y) using map tile color
; ------------------------------------------------------------
Level2EraseAt PROC USES eax edx
    call Level2GetTile

    cmp al, TILE_WALL
    je L2EA_Wall
    cmp al, TILE_LAVA
    je L2EA_Lava
    cmp al, TILE_BRIDGE
    je L2EA_Bridge
    cmp al, TILE_PLATFORM
    je L2EA_Plat

    mov eax, GP_CASTLE_BG
    jmp L2EA_Draw
L2EA_Wall:
    mov eax, GP_CASTLE_WALL
    jmp L2EA_Draw
L2EA_Lava:
    mov eax, GP_CASTLE_LAVA
    jmp L2EA_Draw
L2EA_Bridge:
    mov eax, GP_CASTLE_BRIDGE
    jmp L2EA_Draw
L2EA_Plat:
    mov eax, GP_CASTLE_PLAT

L2EA_Draw:
    call SetTextColor
    mov dh, ah
    mov dl, al
    call Gotoxy
    mov al, ' '
    call WriteChar
    ret
Level2EraseAt ENDP

; ------------------------------------------------------------
; Firebar routines (Level 2) - simple single fireball, 4 phases
; ------------------------------------------------------------
InitFirebar PROC
    mov FirebarPhase, 0
    mov FirebarTimer, 6
    mov al, FirebarCenterX
    mov firebarX[0], al
    mov firebarOldX[0], al
    mov al, FirebarCenterY
    mov firebarY[0], al
    mov firebarOldY[0], al
    ret
InitFirebar ENDP

; Erase previous fireball
EraseFirebar PROC USES eax
    mov al, firebarOldX[0]
    mov ah, firebarOldY[0]
    call Level2EraseAt
    ret
EraseFirebar ENDP

; Update fireball position (4 simple phases)
UpdateFirebar PROC USES eax
    cmp currentLevel, 2
    jne UFBDone
    dec FirebarTimer
    cmp FirebarTimer, 0
    jne UFBDone
    mov FirebarTimer, 6
    mov al, FirebarPhase
    inc al
    and al, 3
    mov FirebarPhase, al

    ; Save old pos
    mov al, firebarX[0]
    mov firebarOldX[0], al
    mov al, firebarY[0]
    mov firebarOldY[0], al

    ; Compute new pos based on phase
    mov al, FirebarCenterX
    mov ah, FirebarCenterY
    cmp FirebarPhase, 0
    je FBP_Ph0
    cmp FirebarPhase, 1
    je FBP_Ph1
    cmp FirebarPhase, 2
    je FBP_Ph2
    ; phase 3
    dec al         ; cx-1
    inc ah         ; cy+1
    jmp FBP_Store
FBP_Ph2:
    ; (cx, cy+1)
    inc ah
    jmp FBP_Store
FBP_Ph1:
    ; (cx+1, cy+1)
    inc al
    inc ah
    jmp FBP_Store
FBP_Ph0:
    ; (cx+1, cy)
    inc al
FBP_Store:
    mov firebarX[0], al
    mov firebarY[0], ah
UFBDone:
    ret
UpdateFirebar ENDP

; Draw current fireball
DrawFirebar PROC USES eax
    cmp currentLevel, 2
    jne DrawFBDone
    mov dh, firebarY[0]
    mov dl, firebarX[0]
    cmp dh, LEVEL2_ROWS
    jae DrawFBDone
    cmp dl, LEVEL2_COLS
    jae DrawFBDone
    call Gotoxy
    mov eax, GP_FIREBAR
    call SetTextColor
    mov al, 'o'
    call WriteChar
DrawFBDone:
    ret
DrawFirebar ENDP

CheckFirebarCollision PROC USES ecx esi
    mov ecx, FIREBAR_LEN
    mov esi, 0
CFBC_Loop:
    mov al, firebarX[esi]
    cmp al, playerX
    jne CFBC_Next
    mov al, firebarY[esi]
    cmp al, playerY
    je CFBC_Hit
CFBC_Next:
    inc esi
    loop CFBC_Loop
    mov al, 0
    ret
CFBC_Hit:
    mov al, 1
    ret
CheckFirebarCollision ENDP

; ------------------------------------------------------------
; Bowser boss (Level 2)
; ------------------------------------------------------------
InitBowser PROC
    ; Bowser patrol on bridge near right side
    mov BowserX, 100
    mov BowserY, LEVEL2_BRIDGE_ROW-1
    mov al, BowserX
    mov BowserPrevX, al
    mov al, BowserY
    mov BowserPrevY, al
    mov BowserLeftBound, 96
    mov BowserRightBound, 110
    mov BowserDir, -1
    mov BowserFireCooldown, 45

    mov ecx, BOWSER_MAX_FIRE
    mov esi, 0
InitBowserLoop:
    mov BowserFireActive[esi], 0
    mov BowserFireX[esi], 0
    mov BowserFireY[esi], 0
    inc esi
    loop InitBowserLoop
    ret
InitBowser ENDP

UpdateBowser PROC USES eax ebx ecx
    cmp currentLevel, 2
    jne UB_Done

    ; remember previous position for erase
    mov al, BowserX
    mov BowserPrevX, al
    mov al, BowserY
    mov BowserPrevY, al

    ; Horizontal patrol
    movzx eax, BowserX
    mov   ebx, BowserDir
    add eax, ebx
    mov ecx, BowserLeftBound
    cmp eax, ecx
    jge UB_CheckRight
    mov eax, ecx
    mov BowserDir, 1
    jmp UB_Store
UB_CheckRight:
    mov ecx, BowserRightBound
    cmp eax, ecx
    jle UB_Store
    mov eax, ecx
    mov BowserDir, -1
UB_Store:
    mov BowserX, al

    ; Fire cooldown + spawn
    mov eax, BowserFireCooldown
    dec eax
    cmp eax, 0
    jg UB_SaveCooldown
    mov eax, 45
    mov ecx, BOWSER_MAX_FIRE
    mov esi, 0
UB_FindSlot:
    mov bl, BowserFireActive[esi]
    cmp bl, 0
    je UB_Spawn
    inc esi
    loop UB_FindSlot
    jmp UB_SaveCooldown
UB_Spawn:
    mov BowserFireActive[esi], 1
    mov bl, BowserX
    cmp bl, 0
    je UB_SaveCooldown
    dec bl
    mov BowserFireX[esi], bl
    mov bl, BowserY
    mov BowserFireY[esi], bl
UB_SaveCooldown:
    mov BowserFireCooldown, eax

UB_Done:
    ret
UpdateBowser ENDP

; Returns AL=1 if Mario hit by fire
UpdateBowserFireballs PROC USES ecx esi ebx edx
    xor al, al
    cmp currentLevel, 2
    jne UBF_Done

    mov ecx, BOWSER_MAX_FIRE
    mov esi, 0
UBF_Loop:
    mov bl, BowserFireActive[esi]
    cmp bl, 0
    je UBF_Next

    mov bl, BowserFireX[esi]
    cmp bl, 0
    je UBF_Deactivate
    dec bl
    mov BowserFireX[esi], bl

    mov dl, BowserFireY[esi]
    cmp dl, playerY
    jne UBF_NextCheck
    cmp bl, playerX
    jne UBF_NextCheck
    mov BowserFireActive[esi], 0
    mov al, 1
    ret

UBF_NextCheck:
    cmp bl, 0
    jne UBF_Next

UBF_Deactivate:
    mov BowserFireActive[esi], 0

UBF_Next:
    inc esi
    loop UBF_Loop

UBF_Done:
    ret
UpdateBowserFireballs ENDP

DrawBowser PROC USES eax
    cmp currentLevel, 2
    jne DB_Done
    mov eax, GP_BOWSER
    call SetTextColor
    mov dh, BowserY
    mov dl, BowserX
    call Gotoxy
    mov al, 'B'
    call WriteChar
DB_Done:
    ret
DrawBowser ENDP

DrawBowserFireballs PROC USES eax ecx esi
    cmp currentLevel, 2
    jne DBF_Done
    mov eax, GP_BOWSER_FIRE
    call SetTextColor
    mov ecx, BOWSER_MAX_FIRE
    mov esi, 0
DBF_Loop:
    mov al, BowserFireActive[esi]
    cmp al, 0
    je DBF_Next
    mov dh, BowserFireY[esi]
    mov dl, BowserFireX[esi]
    call Gotoxy
    mov al, 'o'
    call WriteChar
DBF_Next:
    inc esi
    loop DBF_Loop
DBF_Done:
    ret
DrawBowserFireballs ENDP

; ------------------------------------------------------------
; Sound helpers
; ------------------------------------------------------------
PlayJumpSound PROC
    invoke PlaySoundA, OFFSET jumpSoundLocal, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
    cmp eax, 0
    jne PJS_Done
    invoke PlaySoundA, OFFSET jumpSoundParent, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
PJS_Done:
    ret
PlayJumpSound ENDP

PlayCoinSound PROC
    invoke PlaySoundA, OFFSET coinSoundLocal, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
    cmp eax, 0
    jne PCS_Done
    invoke PlaySoundA, OFFSET coinSoundParent, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
PCS_Done:
    ret
PlayCoinSound ENDP

PlayEnemyDefeatSound PROC
    invoke PlaySoundA, OFFSET enemySoundLocal, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
    cmp eax, 0
    jne PEDS_Done
    invoke PlaySoundA, OFFSET enemySoundParent, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
PEDS_Done:
    ret
PlayEnemyDefeatSound ENDP

PlayPowerupSound PROC
    invoke PlaySoundA, OFFSET powerSoundLocal, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
    cmp eax, 0
    jne PPS_Done
    invoke PlaySoundA, OFFSET powerSoundParent, 0, SND_FILENAME OR SND_ASYNC OR SND_NODEFAULT
PPS_Done:
    ret
PlayPowerupSound ENDP

PlayLevel1Music PROC
    invoke PlaySoundA, OFFSET level1SoundLocal, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP OR SND_NODEFAULT
    cmp eax, 0
    jne PL1_Done
    invoke PlaySoundA, OFFSET level1SoundParent, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP OR SND_NODEFAULT
PL1_Done:
    ret
PlayLevel1Music ENDP

StopAllSounds PROC
    invoke PlaySoundA, 0, 0, 0
    ret
StopAllSounds ENDP

EraseBowser PROC USES eax ebx ecx edx
    cmp currentLevel, 2
    jne EB_Done
    ; erase only the previous spot
    mov dl, BowserPrevX
    mov dh, BowserPrevY
    mov al, dl
    mov ah, dh
    call Level2EraseAt
EB_Done:
    ret
EraseBowser ENDP

; ------------------------------------------------------------
; Level2ErasePlayer: redraw underlying tile at old position
; ------------------------------------------------------------
Level2ErasePlayer PROC USES eax edx
    mov al, oldPlayerX
    mov ah, oldPlayerY
    call Level2GetTile

    ; Choose color by tile
    cmp al, TILE_WALL
    je L2EraseWall
    cmp al, TILE_LAVA
    je L2EraseLava
    cmp al, TILE_BRIDGE
    je L2EraseBridge
    cmp al, TILE_PLATFORM
    je L2ErasePlat

    ; Empty/background
    mov eax, GP_CASTLE_BG
    jmp L2EraseDraw

L2EraseWall:
    mov eax, GP_CASTLE_WALL
    jmp L2EraseDraw
L2EraseLava:
    mov eax, GP_CASTLE_LAVA
    jmp L2EraseDraw
L2EraseBridge:
    mov eax, GP_CASTLE_BRIDGE
    jmp L2EraseDraw
L2ErasePlat:
    mov eax, GP_CASTLE_PLAT

L2EraseDraw:
    call SetTextColor
    mov dh, oldPlayerY
    mov dl, oldPlayerX
    call Gotoxy
    mov al, ' '
    call WriteChar
    ret
Level2ErasePlayer ENDP

main PROC
   call LoadGameData       ; <--- Load high scores/progress on startup
    call ShowTitleScreen

mainMenuLoop:
    call ShowMainMenu
    call ReadChar

    cmp al, '1'
    je  startGame
    cmp al, '2'
    je  startGameLevel2
    cmp al, '3'
    je  showHigh
    cmp al, '4'
    je  showInstr
    cmp al, '5'
    je  exitProgram
    jmp mainMenuLoop

startGame:
    mov currentLevel, 1
    call InputPlayerName
    call RunGame
    jmp mainMenuLoop

startGameLevel2:
    mov currentLevel, 2
    mov level2ResetFlag, 1            ; direct Level 2 start: reset score/coins
    call InputPlayerName
    call RunGameLevel2
    jmp mainMenuLoop

showHigh:
    call ShowHighScore
    jmp mainMenuLoop

showInstr:
    call ShowInstructions
    jmp mainMenuLoop

exitProgram:
    call Clrscr
    exit
main ENDP



; ============================================================
; MENU PROCEDURES
; ============================================================
ShowTitleScreen PROC
    mov eax, COLOR_MENU
    call SetTextColor
    call Clrscr
    mov eax, COLOR_CLOUD
    call SetTextColor
    mov dh, 2
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET cloudLine1
    call WriteString
    mov dh, 3
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET cloudLine2
    call WriteString
    mov dh, 4
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET cloudLine3
    call WriteString
    mov eax, COLOR_TITLE
    call SetTextColor
    mov dh, 7
    mov dl, 12
    call Gotoxy
    mov edx, OFFSET titleLine1
    call WriteString
    mov dh, 8
    mov dl, 12
    call Gotoxy
    mov edx, OFFSET titleLine2
    call WriteString
    mov dh, 9
    mov dl, 12
    call Gotoxy
    mov edx, OFFSET titleLine3
    call WriteString
    mov dh, 10
    mov dl, 12
    call Gotoxy
    mov edx, OFFSET titleLine4
    call WriteString
    mov dh, 11
    mov dl, 12
    call Gotoxy
    mov edx, OFFSET titleLine5
    call WriteString
    mov dh, 12
    mov dl, 12
    call Gotoxy
    mov edx, OFFSET titleLine6
    call WriteString
    mov eax, COLOR_MENU
    call SetTextColor
    mov dh, 15
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET rollNumber
    call WriteString
    mov eax, COLOR_GROUND
    call SetTextColor
    mov dh, 20
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET hillLine1
    call WriteString
    mov dh, 21
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET hillLine2
    call WriteString
    mov dh, 22
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET hillLine3
    call WriteString
    mov eax, COLOR_MENU
    call SetTextColor
    mov dh, 24
    mov dl, 48
    call Gotoxy
    mov edx, OFFSET pressEnter
    call WriteString
waitForEnter:
    call ReadChar
    cmp  al, 13
    jne  waitForEnter
    ret
ShowTitleScreen ENDP

ShowMainMenu PROC
    mov eax, COLOR_MENU
    call SetTextColor
    call Clrscr
    mov eax, COLOR_TITLE
    call SetTextColor
    mov dh, 8
    mov dl, 55
    call Gotoxy
    mov edx, OFFSET menuTitle
    call WriteString
    mov eax, COLOR_MENU
    call SetTextColor
    mov dh, 11
    mov dl, 52
    call Gotoxy
    mov edx, OFFSET menuOption1
    call WriteString
    mov dh, 13
    mov dl, 52
    call Gotoxy
    mov edx, OFFSET menuOption2
    call WriteString
    mov dh, 15
    mov dl, 52
    call Gotoxy
    mov edx, OFFSET menuOption3
    call WriteString
    mov dh, 17
    mov dl, 52
    call Gotoxy
    mov edx, OFFSET menuOption4
    call WriteString
    mov dh, 19
    mov dl, 52
    call Gotoxy
    mov edx, OFFSET menuOption5
    call WriteString
    mov dh, 20
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET menuPrompt
    call WriteString
    ret
ShowMainMenu ENDP

ShowInstructions PROC
    mov eax, COLOR_MENU
    call SetTextColor
    call Clrscr
    mov eax, COLOR_TITLE
    call SetTextColor
    mov dh, 5
    mov dl, 54
    call Gotoxy
    mov edx, OFFSET instrTitle
    call WriteString
    mov eax, COLOR_MENU
    call SetTextColor
    mov dh, 8
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET instrLine1
    call WriteString
    mov dh, 10
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET instrLine2
    call WriteString
    mov dh, 12
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET instrLine3
    call WriteString
    mov dh, 14
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET instrLine4
    call WriteString
    mov dh, 16
    mov dl, 45
    call Gotoxy
    mov edx, OFFSET instrLine5
    call WriteString
    mov dh, 24
    mov dl, 48
    call Gotoxy
    mov edx, OFFSET pressEnter
    call WriteString
waitInstr:
    call ReadChar
    cmp  al, 13
    jne  waitInstr
    ret
ShowInstructions ENDP

ShowHighScore PROC
    mov eax, COLOR_MENU
    call SetTextColor
    call Clrscr
    mov eax, COLOR_TITLE
    call SetTextColor
    mov dh, 5
    mov dl, 55
    call Gotoxy
    mov edx, OFFSET highTitle
    call WriteString
    mov eax, COLOR_MENU
    call SetTextColor
    mov dh, 10
    mov dl, 58
    call Gotoxy
    
    ; Show saved player name if available, otherwise default "MARIO"
    mov al, playerName              ; First character of name buffer
    cmp al, 0
    je UseDefaultHighName
    mov edx, OFFSET playerName
    jmp WriteHighName
UseDefaultHighName:
    mov edx, OFFSET strMario
WriteHighName:
    call WriteString
    mov dh, 12
    mov dl, 58
    call Gotoxy
    mov eax, highScore
    call WriteDec
    mov dh, 24
    mov dl, 48
    call Gotoxy
    mov edx, OFFSET pressEnter
    call WriteString
waitHigh:
    call ReadChar
    cmp  al, 13
    jne  waitHigh
    ret
ShowHighScore ENDP

; ============================================================
; DRAWING PROCEDURES
; ============================================================

; DrawBlockyLetter: Draws a 3x5 blocky letter
; Input: DH = start row, DL = start col, ESI = pattern address, EAX = color
DrawBlockyLetter PROC USES eax ebx ecx edx esi
    push eax  ; Save color
    mov bl, dh  ; BL = current row counter
    mov ecx, 5  ; 5 rows
    
DrawLetterRowLoop:
    mov dh, bl  ; Set row
    mov bh, dl  ; BH = start column
    
    ; Load pattern byte for this row
    mov al, BYTE PTR [esi]
    inc esi
    
    ; Draw 3 columns based on bits 0, 1, 2
    push ecx
    mov ecx, 3
    mov ah, al  ; AH = pattern byte
    
DrawLetterColLoop:
    test ah, 1  ; Test bit 0
    jz SkipPixel
    
    ; Draw block
    push eax
    mov dl, bh  ; Set column
    call Gotoxy
    pop eax
    push eax
    mov eax, [esp + 24]  ; Get saved color from outer stack
    call SetTextColor
    mov al, 219  ; Block character
    call WriteChar
    pop eax
    
SkipPixel:
    shr ah, 1  ; Shift to next bit
    inc bh     ; Next column
    loop DrawLetterColLoop
    
    pop ecx
    inc bl  ; Next row
    loop DrawLetterRowLoop
    
    pop eax  ; Clean up stack
    ret
DrawBlockyLetter ENDP

; FillBackground: Fills entire play area with sky blue
FillBackground PROC USES eax ecx edx
    mov eax, GP_BG
    call SetTextColor
    
    ; Fill entire screen from row 0 to row 24 with sky blue
    mov dh, 0
FillBgRowLoop:
    cmp dh, 25
    jge FillBgDone
    
    mov dl, 0
    call Gotoxy
    
    ; Write 119 spaces (full width)
    mov ecx, 119
FillBgColLoop:
    mov al, ' '
    call WriteChar
    loop FillBgColLoop
    
    inc dh
    jmp FillBgRowLoop
    
FillBgDone:
    ret
FillBackground ENDP

DrawClouds PROC USES eax ecx edx
    ; =========================================================================
    ; CLOUDS - Drawn as SOLID WHITE BLOCKS (spaces with white background)
    ; No ASCII art, just colored rectangles like NES style
    ; =========================================================================
    mov eax, GP_CLOUD
    call SetTextColor
    
    ; Cloud 1 at position (10, 4-5) - Fluffy cloud shape
    mov dh, 4
    mov dl, 10
    call Gotoxy
    mov ecx, 6
Cloud1Row1:
    mov al, ' '                           ; Space with white background = solid white
    call WriteChar
    loop Cloud1Row1
    
    mov dh, 5
    mov dl, 9
    call Gotoxy
    mov ecx, 8
Cloud1Row2:
    mov al, ' '
    call WriteChar
    loop Cloud1Row2
    
    ; Cloud 2 at position (50, 5-6)
    mov dh, 5
    mov dl, 50
    call Gotoxy
    mov ecx, 6
Cloud2Row1:
    mov al, ' '
    call WriteChar
    loop Cloud2Row1
    
    mov dh, 6
    mov dl, 49
    call Gotoxy
    mov ecx, 8
Cloud2Row2:
    mov al, ' '
    call WriteChar
    loop Cloud2Row2
    
    ; Cloud 3 at position (90, 4-5)
    mov dh, 4
    mov dl, 90
    call Gotoxy
    mov ecx, 6
Cloud3Row1:
    mov al, ' '
    call WriteChar
    loop Cloud3Row1
    
    mov dh, 5
    mov dl, 89
    call Gotoxy
    mov ecx, 8
Cloud3Row2:
    mov al, ' '
    call WriteChar
    loop Cloud3Row2
    
    ret
DrawClouds ENDP

DrawPlatforms PROC USES eax ebx ecx edx esi edi
    ; =========================================================================
    ; PLATFORMS - Drawn as SOLID COLORED BLOCKS (spaces with colored background)
    ; =========================================================================
    mov eax, GP_PLAT
    call SetTextColor
    mov ecx, PlatCount
    mov esi, 0
    
    ; Calculate page offset: pageOffset = currentPage * PAGE_WIDTH
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx  ; EAX = pageOffset
    mov edi, eax  ; EDI = pageOffset
    
DrawPlatLoop:
    push ecx
    
    ; Check if platform overlaps with current page
    movzx eax, WORD PTR PlatEndX[esi*2]
    cmp eax, edi
    jb SkipPlatform  ; Platform ends before page starts
    
    movzx eax, WORD PTR PlatStartX[esi*2]
    mov ebx, edi
    add ebx, PAGE_WIDTH
    cmp eax, ebx
    jae SkipPlatform  ; Platform starts after page ends
    
    ; Platform is visible - calculate screen coordinates
    movzx eax, WORD PTR PlatStartX[esi*2]
    sub eax, edi
    cmp eax, 0
    jge StartXOK
    xor eax, eax  ; If negative, start at 0
StartXOK:
    mov dl, al  ; Screen X
    
    movzx ebx, WORD PTR PlatEndX[esi*2]
    sub ebx, edi
    cmp ebx, 118
    jle EndXOK
    mov ebx, 118
EndXOK:
    
    ; Calculate visible width
    sub ebx, eax
    inc ebx  ; width = endX - startX + 1
    
    ; Draw platform as solid block (spaces with colored background)
    mov dh, PlatY[esi]
    call Gotoxy
    
    mov ecx, ebx
DrawPlatWidth:
    push ecx
    mov al, ' '                           ; Space with colored background = solid block
    call WriteChar
    pop ecx
    dec ecx
    jnz DrawPlatWidth
    
SkipPlatform:
    inc esi
    pop ecx
    dec ecx
    jnz DrawPlatLoop
    ret
DrawPlatforms ENDP

DrawPipes PROC USES eax ebx ecx edx esi edi
    ; =========================================================================
    ; NES-STYLE PIPES - Drawn as SOLID GREEN BLOCKS
    ; Pipe body is 2 tiles wide, top flange extends 1 tile on each side (4 wide)
    ; No ASCII characters - just colored spaces for solid rectangles
    ; =========================================================================
    mov ecx, PipeCount
    mov esi, 0
    
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    
DrawPipeLoop:
    push ecx
    
    ; Check if pipe overlaps with current page
    movzx eax, WORD PTR PipeX[esi*2]
    add eax, PIPE_TOP_WIDTH               ; Account for flange width
    cmp eax, edi
    jb SkipPipe                           ; Pipe ends before page starts
    
    movzx eax, WORD PTR PipeX[esi*2]
    sub eax, 1                            ; Flange extends 1 left of body
    mov ebx, edi
    add ebx, PAGE_WIDTH
    cmp eax, ebx
    jae SkipPipe                          ; Pipe starts after page ends
    
    ; Calculate screen X for pipe body center
    movzx eax, WORD PTR PipeX[esi*2]
    sub eax, edi
    
    ; Store body X in stack for reference
    push eax                              ; [esp] = body screen X
    
    ; Calculate Top Y (where pipe starts)
    movzx ebx, PipeHeight[esi]
    mov cl, GROUND_TOP
    sub cl, bl
    mov dh, cl                            ; DH = top Y of pipe
    mov ch, bl                            ; CH = height counter
    
    ; =========================================================================
    ; DRAW PIPE TOP FLANGE (wider rim, 4 tiles wide, dark green)
    ; Flange is 1 tile on each side of the 2-tile body
    ; =========================================================================
    mov eax, GP_PIPE_TOP
    call SetTextColor
    
    ; Flange starts 1 tile left of body
    mov eax, [esp]                        ; Get body X
    dec eax                               ; Flange X = body X - 1
    
    ; Check left bound
    cmp eax, 0
    jge FlangeLeftOK
    xor eax, eax
FlangeLeftOK:
    mov dl, al
    call Gotoxy
    
    ; Draw 4 spaces for the flange (solid dark green block)
    push ecx
    mov ecx, PIPE_TOP_WIDTH
DrawFlangeLoop:
    ; Check right bound
    cmp dl, 118
    ja FlangeRowDone
    mov al, ' '
    call WriteChar
    inc dl
    loop DrawFlangeLoop
FlangeRowDone:
    pop ecx
    
    ; =========================================================================
    ; DRAW PIPE BODY (2 tiles wide, bright green)
    ; =========================================================================
    mov eax, GP_PIPE_BODY
    call SetTextColor
    
    inc dh                                ; Move down one row (below flange)
    dec ch                                ; One row used for flange
    
DrawPipeBodyLoop:
    cmp ch, 0
    je PipeBodyDone
    
    ; Get body X from stack
    mov eax, [esp]
    
    ; Check bounds
    cmp eax, 0
    jl NextPipeRow
    cmp eax, 117
    jg NextPipeRow
    
    mov dl, al
    call Gotoxy
    
    ; Draw 2 spaces for body (solid bright green)
    mov al, ' '
    call WriteChar
    inc dl
    cmp dl, 119
    jge NextPipeRow
    call Gotoxy
    mov al, ' '
    call WriteChar
    
NextPipeRow:
    inc dh                                ; Next row down
    dec ch
    jmp DrawPipeBodyLoop

PipeBodyDone:
    pop eax                               ; Clean up stack (body X)

SkipPipe:
    inc esi
    pop ecx
    dec ecx
    jnz DrawPipeLoop
    ret
DrawPipes ENDP

DrawGround PROC USES eax ecx edx
    ; =========================================================================
    ; GROUND - Drawn as SOLID BROWN BLOCKS with GREEN GRASS on top
    ; Like NES Mario: green grass strip on top of brown dirt
    ; =========================================================================
    
    ; First draw green grass strip at GROUND_TOP row
    mov eax, GP_GRASS
    call SetTextColor
    mov dh, GROUND_TOP
    mov dl, 0
    call Gotoxy
    mov ecx, 119
DrawGrassLoop:
    mov al, ' '                           ; Space with green background = grass
    call WriteChar
    loop DrawGrassLoop
    
    ; Now draw brown ground below the grass (2 rows of dirt)
    mov eax, GP_GROUND
    call SetTextColor
    
    mov dh, GROUND_TOP
    inc dh                                ; Start one row below grass
DrawGroundRowLoop:
    cmp dh, GROUND_TOP + 3
    jge DrawGroundDone
    
    mov dl, 0
    call Gotoxy
    
    ; Draw 119 spaces across (solid brown)
    mov ecx, 119
DrawGroundColLoop:
    mov al, ' '                           ; Space with brown background = dirt
    call WriteChar
    loop DrawGroundColLoop
    
    inc dh
    jmp DrawGroundRowLoop
    
DrawGroundDone:
    ret
DrawGround ENDP

; =========================================================================
; DrawHills: Render decorative green hills in background
; Drawn as simple SOLID GREEN BLOCKS (NES style)
; Hills are drawn BEFORE pipes/platforms so they appear behind
; =========================================================================
DrawHills PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    
    mov ecx, MAX_HILLS                    ; Load constant into ECX
    mov esi, 0
    
DrawHillLoop:
    push ecx
    
    ; Calculate screen X = worldX - pageOffset
    movzx eax, WORD PTR hillX[esi*2]
    sub eax, edi
    
    ; Check if hill is visible (rough check)
    cmp eax, -10
    jl SkipHill
    cmp eax, 125
    jg SkipHill
    
    ; EAX = base screen X, store in EBX for later use
    mov ebx, eax
    
    ; Get hill size for this hill
    movzx ecx, hillSize[esi]              ; Size: 2 or 3 (row counter)
    
    ; Draw hill from bottom to top
    mov dh, GROUND_TOP
    dec dh                                ; Start one row above ground
    
DrawHillRowLoop:
    cmp ecx, 0
    je DrawHillDone
    
    ; Calculate row width = (current_row * 2 + 1)
    push eax
    mov eax, ecx
    shl eax, 1
    inc eax                               ; Width in EAX
    push eax                              ; Save width
    
    ; Calculate row X offset (center the narrower rows)
    ; Offset = baseX + (hillSize - currentRow)
    push ecx
    movzx eax, hillSize[esi]
    sub eax, ecx                          ; hillSize - currentRow
    add eax, ebx                          ; Add base X
    pop ecx
    
    ; Check bounds
    cmp eax, 0
    jl SkipHillRowDraw
    cmp eax, 118
    jg SkipHillRowDraw
    
    mov dl, al
    call Gotoxy
    
    ; Set hill color (dark green solid block)
    push eax
    mov eax, GP_HILL_BODY
    call SetTextColor
    pop eax
    
    ; Draw width spaces (solid green)
    pop eax                               ; Get width
    push ecx
    mov ecx, eax
DrawHillColLoop:
    cmp dl, 118
    jg DoneHillCol
    push eax
    mov al, ' '
    call WriteChar
    pop eax
    inc dl
    loop DrawHillColLoop
DoneHillCol:
    pop ecx
    pop eax                               ; Clean up pushed EAX from earlier
    jmp SkipHillRowDrawEnd
    
SkipHillRowDraw:
    pop eax                               ; Clean width
    pop eax                               ; Clean saved EAX
    
SkipHillRowDrawEnd:
    dec dh                                ; Move up one row
    dec ecx
    jmp DrawHillRowLoop
    
DrawHillDone:
    
SkipHill:
    inc esi
    pop ecx
    dec ecx
    jnz DrawHillLoop
    
    ret
DrawHills ENDP

DrawInitialScreen PROC
    ; =========================================================================
    ; DRAW ALL LEVEL ELEMENTS IN PROPER ORDER (back to front)
    ; NES-style solid block graphics
    ; =========================================================================
    
    ; 1. Fill entire background with sky blue
    call FillBackground
    
    ; 2. Draw clouds (white solid blocks in sky)
    call DrawClouds
    
    ; 3. Draw decorative hills (green blocks behind everything)
    call DrawHills
    
    ; 4. Draw ground with grass (green strip on brown dirt)
    call DrawGround
    
    ; 5. Draw pipes (solid green blocks, wide NES-style)
    call DrawPipes
    
    ; 6. Draw platforms (solid colored blocks)
    call DrawPlatforms
    
    ; 7. Draw brick blocks (solid brown blocks)
    call DrawBricks
    
    ; 8. Draw question blocks (yellow blocks with '?')
    call DrawQuestionBlocks
    
    ; 9. Draw flagpole
    call DrawFlagpole
    
    ; 10. Draw goombas (enemies)
    call DrawGoombas
    
    ret
DrawInitialScreen ENDP

DrawPlayer PROC
    ; In page-based scrolling, playerX is already screen coordinate (0-118)
    cmp powerState, POWER_SUPER
    jne DrawSmallMario
    mov eax, GP_PLAYER_SUPER
    cmp currentLevel, 2
    jne SetPlayerColor
    mov eax, GP_PLAYER_SUPER_L2
    jmp SetPlayerColor
DrawSmallMario:
    mov eax, GP_PLAYER
    cmp currentLevel, 2
    jne SetPlayerColor
    mov eax, GP_PLAYER_L2
SetPlayerColor:
    call SetTextColor
    mov dh, playerY
    mov dl, playerX
    call Gotoxy
    mov al, 'M'
    call WriteChar
    ret
DrawPlayer ENDP

; ============================================================
; COIN SYSTEM PROCEDURES
; ============================================================

; InitCoins: Initialize coin positions for Level 1-1
; Sets up coin positions and marks them as active
; ====================================================================================
; InitCoins - DISABLED FOR NES MARIO STYLE
; In classic NES Mario, there are NO pre-placed coins in the level!
; Coins ONLY come from hitting ? blocks from below.
; This procedure is kept for compatibility but does nothing except clear the arrays.
; ====================================================================================
InitCoins PROC USES eax ecx esi
    ; Clear all coin data - no coins pre-placed in level
    mov ecx, MAX_COINS
    mov esi, 0
ClearCoinsLoop:
    mov CoinActive[esi], 0
    mov WORD PTR CoinX[esi*2], 0
    mov CoinY[esi], 0
    inc esi
    loop ClearCoinsLoop
    
    ; No coins in the level at start - just like NES Mario!
    mov CoinCount, 0
    
    ret
InitCoins ENDP

; ====================================================================================
; DrawCoins - DISABLED FOR NES MARIO STYLE
; No pre-placed coins exist, so nothing to draw.
; Coins only appear as animations from ? blocks (handled by DrawCoinAnimations)
; ====================================================================================
DrawCoins PROC
    ; Do nothing - no pre-placed coins in NES Mario style
    ret
DrawCoins ENDP

; CheckCoinCollisions: Detects and handles Mario collecting coins
; Checks if Mario overlaps with any active coin
; Updates score and coins count on collection
; ====================================================================================
; CheckCoinCollisions - DISABLED FOR NES MARIO STYLE
; No pre-placed coins to check collision with!
; Coins are auto-collected when ? blocks are hit (handled in CheckQuestionBlockHit)
; ====================================================================================
CheckCoinCollisions PROC
    ; Do nothing - no pre-placed coins in NES Mario style
    ret
CheckCoinCollisions ENDP

; SMART ERASE: Redraws blocks based on what should be at that position
ErasePlayer PROC USES eax ebx ecx edx esi edi
    ; In page-based scrolling, position is already in screen coords
    mov dh, oldPlayerY
    mov dl, oldPlayerX
    call Gotoxy

    ; 1. Ground Overlap Check
    cmp dh, GROUND_TOP
    jge RedrawGround

    ; 2. Platform Overlap Check (convert screen to world coords)
    ; Calculate page offset
    push edx
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx  ; EAX = pageOffset
    mov edi, eax  ; EDI = pageOffset
    
    movzx ebx, dl  ; Screen X
    add ebx, edi  ; EBX = World X (full 32-bit, no overflow)
    pop edx
    mov checkY, dh
    
    ; Check Platforms (using world coords) - WORD arrays
    mov ecx, PlatCount
    mov esi, 0
ChkPlatErase:
    mov al, PlatY[esi]
    cmp checkY, al
    jne NextPlatErase
    movzx eax, WORD PTR PlatStartX[esi*2]
    cmp ebx, eax
    jb NextPlatErase
    movzx eax, WORD PTR PlatEndX[esi*2]
    cmp ebx, eax
    ja NextPlatErase
    jmp RedrawPlat
NextPlatErase:
    inc esi
    loop ChkPlatErase

    ; 3. Check Bricks (using world coords) - WORD array
    movzx ecx, brickCount
    cmp ecx, 0
    je ChkPipeEraseStart
    mov esi, 0
ChkBrickErase:
    mov al, brickY[esi]
    cmp checkY, al
    jne NextBrickErase
    movzx eax, WORD PTR brickX[esi*2]
    cmp ebx, eax
    jne NextBrickErase
    jmp RedrawBrick
NextBrickErase:
    inc esi
    loop ChkBrickErase
    
ChkPipeEraseStart:
    ; 4. Check Pipes (using world coords) - WORD array
    ; Must check for both flange (4 wide at top) and body (2 wide below)
    mov ecx, PipeCount
    mov esi, 0
ChkPipeErase:
    ; Calculate pipe top Y
    movzx eax, PipeHeight[esi]
    mov dl, GROUND_TOP
    sub dl, al                            ; DL = Top Y of pipe
    
    ; Check if Mario's Y is within pipe height
    cmp checkY, dl
    jb NextPipeErase                      ; Above pipe top
    cmp checkY, GROUND_TOP
    jae NextPipeErase                     ; Below pipe (at or below ground)
    
    ; Mario is at pipe Y level - check if at top row (flange) or body
    cmp checkY, dl
    jne CheckPipeBodyX
    
    ; At top row - check flange (4 tiles wide, extends 1 left of body)
    movzx eax, WORD PTR PipeX[esi*2]
    dec eax                               ; Flange starts 1 tile left
    cmp ebx, eax
    jb NextPipeErase
    add eax, PIPE_TOP_WIDTH
    dec eax
    cmp ebx, eax
    ja NextPipeErase
    jmp RedrawPipeTop
    
CheckPipeBodyX:
    ; Below top row - check body (2 tiles wide)
    movzx eax, WORD PTR PipeX[esi*2]
    cmp ebx, eax
    jb NextPipeErase
    add eax, PIPE_BODY_WIDTH
    dec eax
    cmp ebx, eax
    ja NextPipeErase
    
    ; Found overlapping pipe
    jmp RedrawPipeBody
NextPipeErase:
    inc esi
    loop ChkPipeErase
    
    ; 5. Check Question Blocks (using world coords) - WORD array
    movzx ecx, qblockCount
    cmp ecx, 0
    je EraseWithSky
    mov esi, 0
ChkQBlockErase:
    mov al, qblockY[esi]
    cmp checkY, al
    jne NextQBlockErase
    movzx eax, WORD PTR qblockX[esi*2]
    cmp ebx, eax
    jne NextQBlockErase
    
    ; Found question block - check if active or used
    cmp qblockState[esi], QBLOCK_ACTIVE
    je RedrawQBlock
    jmp RedrawUsedBlock
    
NextQBlockErase:
    inc esi
    loop ChkQBlockErase

EraseWithSky:
    ; Default: Erase with space in sky blue
    mov eax, GP_BG
    call SetTextColor
    mov al, ' '
    call WriteChar
    ret

RedrawGround:
    ; Check if this is grass row (first row of ground)
    cmp dh, GROUND_TOP
    jne RedrawDirt
    mov eax, GP_GRASS                     ; Solid green grass
    call SetTextColor
    mov al, ' '
    call WriteChar
    ret
RedrawDirt:
    mov eax, GP_GROUND                    ; Solid brown dirt
    call SetTextColor
    mov al, ' '                           ; Space with brown background
    call WriteChar
    ret

RedrawPlat:
    mov eax, GP_PLAT
    call SetTextColor
    mov al, ' '                           ; Space with colored background
    call WriteChar
    ret

RedrawBrick:
    mov eax, GP_BRICK
    call SetTextColor
    mov al, ' '                           ; Solid brown block
    call WriteChar
    ret

RedrawQBlock:
    mov eax, GP_QBLOCK
    call SetTextColor
    mov al, QBLOCK_CHAR                   ; Question mark on yellow
    call WriteChar
    ret

RedrawUsedBlock:
    mov eax, GP_USEDBLOCK
    call SetTextColor
    mov al, ' '                           ; Solid dark block
    call WriteChar
    ret

RedrawPipeTop:
    mov eax, GP_PIPE_TOP                  ; Dark green flange
    call SetTextColor
    mov al, ' '
    call WriteChar
    ret

RedrawPipeBody:
    mov eax, GP_PIPE_BODY                 ; Bright green pipe body
    call SetTextColor
    mov al, ' '
    call WriteChar
    ret

ErasePlayerDone:
    ret
ErasePlayer ENDP

DrawHUD PROC USES eax edx
    ; HUD color: white text on black for Level 2, original sky for Level 1
    cmp  currentLevel, 2
    jne  HudSky
    mov  eax, 15 + (0 * 16) ; White on black
    jmp  HudColorSet
HudSky:
    mov  eax, 0 + (9 * 16)  ; Black text on light blue
HudColorSet:
    call SetTextColor
    mov  dh, 1
    mov  dl, 2
    call Gotoxy
    mov  edx, OFFSET strMarioHUD
    call WriteString
    mov  eax, score
    call WriteDec
    mov  dh, 2
    mov  dl, 2
    call Gotoxy
    mov  edx, OFFSET strLivesHUD
    call WriteString
    movzx eax, lives
    call WriteDec
    mov  dh, 1
    mov  dl, 50
    call Gotoxy
    mov  edx, OFFSET strCoinHUD
    call WriteString
    movzx eax, coins
    call WriteDec
    mov  dh, 1
    mov  dl, 85
    call Gotoxy
    mov  edx, OFFSET strWorldHUD
    call WriteString
    mov  dh, 1
    mov  dl, 108
    call Gotoxy
    mov  edx, OFFSET strTimeHUD
    call WriteString
    movzx eax, gameTime
    call WriteDec
    ret
DrawHUD ENDP

; ============================================================
; COLLISION LOGIC
; ============================================================

; IsWallOrGround: Checks Pipes and Ground Only
; Inputs: AL = X (screen coords), AH = Y
; Returns: AL = 1 (Solid), AL = 0 (Empty)
IsWallOrGround PROC USES ebx ecx edx esi edi
    ; Level 2: use castle collision
    cmp currentLevel, 2
    jne L1WallGround
    call Level2IsSolid
    ret

L1WallGround:
    movzx ebx, al  ; Save screen X in EBX
    mov checkY, ah

    ; 1. Check Ground
    cmp ah, GROUND_TOP
    jae ReturnSolid

    ; Calculate page offset for world coordinate conversion
    mov eax, currentPage
    push ebx
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax  ; EDI = pageOffset
    pop ebx

    ; 2. Check Pipes (convert screen X to world X)
    add ebx, edi  ; EBX = worldX (full 32-bit, no overflow)
    
    mov ecx, PipeCount
    mov esi, 0
CheckPipes:
    ; Check Y
    movzx eax, PipeHeight[esi]
    mov dl, GROUND_TOP
    sub dl, al ; DL is Top Y
    cmp checkY, dl
    jb NextPipe ; Above pipe
    
    ; Check X (world coordinates) - WORD array
    ; Pipe body is PIPE_BODY_WIDTH wide (2 tiles)
    movzx eax, WORD PTR PipeX[esi*2]
    cmp ebx, eax
    jb NextPipe ; Left of pipe
    add eax, PIPE_BODY_WIDTH
    dec eax      ; End X
    cmp ebx, eax
    ja NextPipe ; Right of pipe
    
    jmp ReturnSolid
NextPipe:
    inc esi
    loop CheckPipes

    mov al, 0
    ret
ReturnSolid:
    mov al, 1
    ret
IsWallOrGround ENDP

; IsPlatform: Checks Platforms Only
; Inputs: AL = X (screen coords), AH = Y
; Returns: AL = 1 (Hit), AL = 0 (Empty)
IsPlatform PROC USES ebx ecx edx esi edi
    ; Level 2 platforms from castle map
    cmp currentLevel, 2
    jne L1Platform
    call Level2IsPlatform
    ret

L1Platform:
    movzx ebx, al  ; Save screen X in EBX
    mov checkY, ah
    
    ; Calculate page offset
    mov eax, currentPage
    push ebx
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax  ; EDI = pageOffset
    pop ebx
    
    ; Convert screen X to world X (EBX = worldX, full 32-bit)
    add ebx, edi  ; EBX = worldX (no overflow now!)

    mov ecx, PlatCount
    mov esi, 0
CheckPlats:
    mov al, PlatY[esi]
    cmp checkY, al
    jne NextPlat
    ; Use WORD array access with esi*2
    movzx eax, WORD PTR PlatStartX[esi*2]
    cmp ebx, eax
    jb NextPlat
    movzx eax, WORD PTR PlatEndX[esi*2]
    cmp ebx, eax
    ja NextPlat
    jmp ReturnPlatSolid
NextPlat:
    inc esi
    loop CheckPlats

    mov al, 0
    ret
ReturnPlatSolid:
    mov al, 1
    ret
IsPlatform ENDP

; ============================================================
; QUESTION BLOCK SYSTEM PROCEDURES
; ============================================================

; ------------------------------------------------------------
; InitBricks: Initialize brick blocks in the level
; Creates classic NES Mario brick platforms
; Bricks are placed in rows with question blocks embedded
; ------------------------------------------------------------
InitBricks PROC USES eax ecx esi
    mov esi, 0
    
    ; ========================================================================
    ; PAGE 0 - STARTING AREA (like NES Mario 1-1)
    ; First brick row at Y=13 - forms a platform with ? blocks embedded
    ; ========================================================================
    
    ; First block group: X = 16-24 (? blocks at 18, 20, 22)
    mov WORD PTR brickX[esi*2], 16
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 17
    mov brickY[esi], 13
    inc esi
    
    ; 18 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 19
    mov brickY[esi], 13
    inc esi
    
    ; 20 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 21
    mov brickY[esi], 13
    inc esi
    
    ; 22 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 23
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 24
    mov brickY[esi], 13
    inc esi
    
    ; Second brick row near first pipe - higher platform
    mov WORD PTR brickX[esi*2], 38
    mov brickY[esi], 11
    inc esi
    
    mov WORD PTR brickX[esi*2], 39
    mov brickY[esi], 11
    inc esi
    
    mov WORD PTR brickX[esi*2], 40
    mov brickY[esi], 11
    inc esi
    
    ; Third brick row - mid-level with ? block
    mov WORD PTR brickX[esi*2], 55
    mov brickY[esi], 14
    inc esi
    
    ; 56 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 57
    mov brickY[esi], 14
    inc esi
    
    mov WORD PTR brickX[esi*2], 58
    mov brickY[esi], 14
    inc esi
    
    mov WORD PTR brickX[esi*2], 59
    mov brickY[esi], 14
    inc esi
    
    ; Long brick row near end of page 0
    mov WORD PTR brickX[esi*2], 78
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 79
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 80
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 81
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 82
    mov brickY[esi], 13
    inc esi
    
    ; ========================================================================
    ; PAGE 1 - MID SECTION
    ; ========================================================================
    
    ; Brick platform with question block in middle
    mov WORD PTR brickX[esi*2], 128
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 129
    mov brickY[esi], 13
    inc esi
    
    ; 130 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 131
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 132
    mov brickY[esi], 13
    inc esi
    
    ; Higher brick group with ? block
    mov WORD PTR brickX[esi*2], 153
    mov brickY[esi], 11
    inc esi
    
    mov WORD PTR brickX[esi*2], 154
    mov brickY[esi], 11
    inc esi
    
    ; 155 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 156
    mov brickY[esi], 11
    inc esi
    
    mov WORD PTR brickX[esi*2], 157
    mov brickY[esi], 11
    inc esi
    
    ; Long platform
    mov WORD PTR brickX[esi*2], 190
    mov brickY[esi], 12
    inc esi
    
    mov WORD PTR brickX[esi*2], 191
    mov brickY[esi], 12
    inc esi
    
    mov WORD PTR brickX[esi*2], 192
    mov brickY[esi], 12
    inc esi
    
    mov WORD PTR brickX[esi*2], 193
    mov brickY[esi], 12
    inc esi
    
    mov WORD PTR brickX[esi*2], 194
    mov brickY[esi], 12
    inc esi
    
    ; ========================================================================
    ; PAGE 2 - END SECTION (before flagpole)
    ; ========================================================================
    
    ; Brick platform with question block
    mov WORD PTR brickX[esi*2], 248
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 249
    mov brickY[esi], 13
    inc esi
    
    ; 250 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 251
    mov brickY[esi], 13
    inc esi
    
    mov WORD PTR brickX[esi*2], 252
    mov brickY[esi], 13
    inc esi
    
    ; Final brick row
    mov WORD PTR brickX[esi*2], 278
    mov brickY[esi], 12
    inc esi
    
    mov WORD PTR brickX[esi*2], 279
    mov brickY[esi], 12
    inc esi
    
    ; 280 = question block (skip)
    
    mov WORD PTR brickX[esi*2], 281
    mov brickY[esi], 12
    inc esi
    
    mov WORD PTR brickX[esi*2], 282
    mov brickY[esi], 12
    inc esi
    
    mov brickCount, 37                    ; Total brick count
    ret
InitBricks ENDP

; ------------------------------------------------------------
; InitQuestionBlocks: Initialize question blocks in NES Mario style
; ? blocks are embedded WITHIN brick platforms, not floating alone
; ------------------------------------------------------------
InitQuestionBlocks PROC USES eax ecx esi
    ; Clear all question blocks first
    mov ecx, MAX_QBLOCKS
    mov esi, 0
ClearQBlocksLoop:
    mov qblockState[esi], QBLOCK_USED    ; Inactive by default
    mov qblockType[esi], QBLOCK_TYPE_COIN
    inc esi
    loop ClearQBlocksLoop
    
    ; ========================================================================
    ; PAGE 0 - STARTING AREA (matching NES Mario 1-1 layout)
    ; ========================================================================
    
    ; First ? block group - embedded in brick row at Y=13
    mov esi, 0
    mov WORD PTR qblockX[esi*2], 18      ; Center of first brick platform
    mov qblockY[esi], 13
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    inc esi
    mov WORD PTR qblockX[esi*2], 20
    mov qblockY[esi], 13
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_MUSHROOM
    
    inc esi
    mov WORD PTR qblockX[esi*2], 22
    mov qblockY[esi], 13
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    ; High ? block above pipe
    inc esi
    mov WORD PTR qblockX[esi*2], 39
    mov qblockY[esi], 11
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    ; Single ? block near stairs
    inc esi
    mov WORD PTR qblockX[esi*2], 56
    mov qblockY[esi], 14
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    ; ========================================================================
    ; PAGE 1 - MID SECTION
    ; ========================================================================
    
    ; ? block in brick platform
    inc esi
    mov WORD PTR qblockX[esi*2], 130
    mov qblockY[esi], 13
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    ; Higher ? block group
    inc esi
    mov WORD PTR qblockX[esi*2], 155
    mov qblockY[esi], 11
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_MUSHROOM
    
    ; Long platform ? block
    inc esi
    mov WORD PTR qblockX[esi*2], 192
    mov qblockY[esi], 12
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    ; ========================================================================
    ; PAGE 2 - END SECTION
    ; ========================================================================
    
    ; Final ? blocks before flagpole
    inc esi
    mov WORD PTR qblockX[esi*2], 250
    mov qblockY[esi], 13
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    inc esi
    mov WORD PTR qblockX[esi*2], 272
    mov qblockY[esi], 12
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_MUSHROOM
    
    inc esi
    mov WORD PTR qblockX[esi*2], 300
    mov qblockY[esi], 13
    mov qblockState[esi], QBLOCK_ACTIVE
    mov qblockType[esi], QBLOCK_TYPE_COIN
    
    mov qblockCount, 11                   ; Total question blocks
    
    ret
InitQuestionBlocks ENDP

; ------------------------------------------------------------
; DrawBricks: Render all brick blocks on screen
; Drawn as SOLID BROWN BLOCKS (spaces with brown background)
; Like NES Mario brick platforms
; ------------------------------------------------------------
DrawBricks PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    
    movzx ecx, brickCount
    cmp ecx, 0
    je DrawBricksDone
    
    mov esi, 0
    
    ; Set brick color once (solid brown)
    mov eax, GP_BRICK
    call SetTextColor
    
DrawBrickLoop:
    push ecx
    
    ; Calculate screen X = worldX - pageOffset
    movzx eax, WORD PTR brickX[esi*2]
    sub eax, edi
    
    ; Check if brick is on current page (visible)
    cmp eax, 0
    jl NextBrickDraw
    cmp eax, 118
    jg NextBrickDraw
    
    ; Check Y bounds
    mov dh, brickY[esi]
    cmp dh, PLAY_MIN_Y
    jb NextBrickDraw
    cmp dh, GROUND_TOP
    jae NextBrickDraw
    
    mov dl, al                            ; Screen X
    call Gotoxy
    
    ; Draw brick as solid brown block (space with brown background)
    mov al, ' '
    call WriteChar
    
NextBrickDraw:
    inc esi
    pop ecx
    dec ecx
    jnz DrawBrickLoop
    
DrawBricksDone:
    ret
DrawBricks ENDP

; ------------------------------------------------------------
; DrawQuestionBlocks: Render all question blocks on screen
; Active: SOLID YELLOW BLOCK with black '?' on it
; Used: SOLID DARK GRAY BLOCK (empty)
; ------------------------------------------------------------
DrawQuestionBlocks PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    
    movzx ecx, qblockCount
    cmp ecx, 0
    je DrawQBlocksDone
    
    mov esi, 0
    
DrawQBlockLoop:
    push ecx
    
    ; Calculate screen X = worldX - pageOffset
    movzx eax, WORD PTR qblockX[esi*2]
    sub eax, edi
    
    ; Check if block is on current page (visible)
    cmp eax, 0
    jl NextQBlockDraw
    cmp eax, 118
    jg NextQBlockDraw
    
    ; Check Y bounds
    mov dh, qblockY[esi]
    cmp dh, PLAY_MIN_Y
    jb NextQBlockDraw
    cmp dh, GROUND_TOP
    jae NextQBlockDraw
    
    mov dl, al                            ; Screen X
    call Gotoxy
    
    ; Set color and character based on state
    cmp qblockState[esi], QBLOCK_ACTIVE
    je DrawActiveQBlock
    
    ; Draw used block - SOLID DARK GRAY (space with gray background)
    mov eax, GP_USEDBLOCK
    call SetTextColor
    mov al, ' '                           ; Solid dark block
    call WriteChar
    jmp NextQBlockDraw
    
DrawActiveQBlock:
    ; Draw active question block - SOLID YELLOW with black '?' on it
    mov eax, GP_QBLOCK                    ; Black text on yellow background
    call SetTextColor
    mov al, QBLOCK_CHAR                   ; Question mark character
    call WriteChar
    
NextQBlockDraw:
    inc esi
    pop ecx
    dec ecx
    jnz DrawQBlockLoop
    
DrawQBlocksDone:
    ret
DrawQuestionBlocks ENDP

; ------------------------------------------------------------
; CheckQuestionBlockHit: Check if Mario hit a question block from below
; Called when Mario is moving upward and hits something
; Input: AL = Mario's screen X, AH = Mario's Y (the tile he hit)
; Returns: AL = 1 if hit a question block, AL = 0 otherwise
; ------------------------------------------------------------
CheckQuestionBlockHit PROC USES ebx ecx edx esi edi
    ; Save Mario's position
    movzx ebx, al                         ; Screen X
    mov checkY, ah                        ; Y position
    
    ; Calculate page offset to convert screen X to world X
    mov eax, currentPage
    push ebx
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    pop ebx
    
    ; Convert screen X to world X
    add ebx, edi                          ; EBX = world X
    
    ; Check each question block
    movzx ecx, qblockCount
    cmp ecx, 0
    je NoQBlockHit
    
    mov esi, 0
    
CheckQBlockLoop:
    ; Skip inactive/used blocks
    cmp qblockState[esi], QBLOCK_ACTIVE
    jne NextQBlockCheck
    
    ; Check Y match (must be exact or within 1 tile)
    mov al, qblockY[esi]
    cmp checkY, al
    jne NextQBlockCheck
    
    ; Check X match (within 1 tile for forgiving hitbox)
    movzx eax, WORD PTR qblockX[esi*2]
    sub eax, ebx                          ; Difference
    cmp eax, 0
    jge CheckQBlockXPos
    neg eax
CheckQBlockXPos:
    cmp eax, 1                            ; Within 1 tile?
    ja NextQBlockCheck
    
    ; ==========================================================
    ; HIT! Mario hit an active question block from below
    ; ==========================================================
    
    ; 1. Change block state to USED
    mov qblockState[esi], QBLOCK_USED
    
    ; 2. Award base points for hitting the block
    mov eax, score
    add eax, QBLOCK_POINTS
    mov score, eax
    
    ; Prepare spawn coordinates (world X / Y above the block)
    movzx eax, WORD PTR qblockX[esi*2]
    movzx edx, qblockY[esi]
    dec edx
    
    ; 3. Determine reward type (coin vs mushroom)
    cmp qblockType[esi], QBLOCK_TYPE_MUSHROOM
    je SpawnMushroomReward
    
    ; Coin reward: increment coins and spawn coin animation
    inc coins
    push esi
    push ebx
    call SpawnCoinAnimation
    pop ebx
    pop esi
    jmp UpdateQBlockHUD
    
SpawnMushroomReward:
    ; Mushroom reward: spawn a mushroom power-up
    push esi
    push ebx
    call SpawnMushroom
    pop ebx
    pop esi
    
UpdateQBlockHUD:
    ; Update HUD to show new score/coins
    push esi
    push ebx
    push edi
    call DrawHUD
    pop edi
    pop ebx
    pop esi
    call PlayCoinSound
    
    ; Return success
    mov al, 1
    ret
    
NextQBlockCheck:
    inc esi
    dec ecx
    jnz CheckQBlockLoop
    
NoQBlockHit:
    mov al, 0
    ret
CheckQuestionBlockHit ENDP

; ============================================================
; COIN POP ANIMATION PROCEDURES
; ============================================================

; ------------------------------------------------------------
; InitCoinAnimations: Clear all coin animation slots
; ------------------------------------------------------------
InitCoinAnimations PROC USES ecx esi
    mov ecx, MAX_COIN_ANIMS
    mov esi, 0
ClearCoinAnimLoop:
    mov coinAnimActive[esi], 0
    mov coinAnimTimer[esi], 0
    inc esi
    loop ClearCoinAnimLoop
    ret
InitCoinAnimations ENDP

; ------------------------------------------------------------
; SpawnCoinAnimation: Start a new coin pop animation
; Input: EAX = world X position, EDX = starting Y position
; ------------------------------------------------------------
SpawnCoinAnimation PROC USES ebx ecx esi
    ; Find a free animation slot
    mov ecx, MAX_COIN_ANIMS
    mov esi, 0
    
FindFreeSlot:
    cmp coinAnimActive[esi], 0
    je FoundFreeSlot
    inc esi
    loop FindFreeSlot
    
    ; No free slot available, just skip
    ret
    
FoundFreeSlot:
    ; Initialize the animation
    mov WORD PTR coinAnimX[esi*2], ax     ; World X
    mov coinAnimY[esi], dl                 ; Starting Y
    mov coinAnimStartY[esi], dl            ; Remember start for reference
    mov coinAnimTimer[esi], COIN_ANIM_DURATION
    mov coinAnimActive[esi], 1             ; Activate animation
    
    ret
SpawnCoinAnimation ENDP

; ------------------------------------------------------------
; UpdateCoinAnimations: Update all active coin animations
; Moves coins upward and decrements timers
; ------------------------------------------------------------
UpdateCoinAnimations PROC USES eax ecx esi
    mov ecx, MAX_COIN_ANIMS
    mov esi, 0
    
UpdateCoinAnimLoop:
    ; Skip inactive animations
    cmp coinAnimActive[esi], 0
    je NextCoinAnim
    
    ; Decrement timer
    dec coinAnimTimer[esi]
    
    ; Check if animation is done
    cmp coinAnimTimer[esi], 0
    je DeactivateCoinAnim
    
    ; Move coin upward (only during first half of animation)
    cmp coinAnimTimer[esi], COIN_ANIM_DURATION / 2
    jb NextCoinAnim                        ; Second half: coin fades/stays
    
    ; First half: move coin upward
    cmp coinAnimY[esi], 3                  ; Don't go off top of screen
    jbe NextCoinAnim
    dec coinAnimY[esi]
    jmp NextCoinAnim
    
DeactivateCoinAnim:
    mov coinAnimActive[esi], 0
    
NextCoinAnim:
    inc esi
    loop UpdateCoinAnimLoop
    
    ret
UpdateCoinAnimations ENDP

; ------------------------------------------------------------
; EraseCoinAnimations: Clear coins from their previous positions
; Called before updating/drawing to prevent ghost trails
; ------------------------------------------------------------
EraseCoinAnimations PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    
    mov ecx, MAX_COIN_ANIMS
    mov esi, 0
    
EraseCoinAnimLoop:
    push ecx
    
    ; Skip inactive animations
    cmp coinAnimActive[esi], 0
    je NextCoinAnimErase
    
    ; Calculate screen X = worldX - pageOffset
    movzx eax, WORD PTR coinAnimX[esi*2]
    sub eax, edi
    
    ; Check if on current page
    cmp eax, 0
    jl NextCoinAnimErase
    cmp eax, 118
    jg NextCoinAnimErase
    
    ; Check Y bounds
    mov dh, coinAnimY[esi]
    cmp dh, 1
    jb NextCoinAnimErase
    cmp dh, GROUND_TOP
    jae NextCoinAnimErase
    
    mov dl, al                            ; Screen X
    call Gotoxy
    
    ; Erase with sky color (background)
    mov eax, GP_BG
    call SetTextColor
    mov al, ' '
    call WriteChar
    
NextCoinAnimErase:
    inc esi
    pop ecx
    dec ecx
    jnz EraseCoinAnimLoop
    
    ret
EraseCoinAnimations ENDP

; ------------------------------------------------------------
; DrawCoinAnimations: Render all active coin pop animations
; Drawn as SOLID GOLD BLOCKS that rise up and fade
; These are purely visual and don't affect collision
; ------------------------------------------------------------
DrawCoinAnimations PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; EDI = pageOffset
    
    mov ecx, MAX_COIN_ANIMS
    mov esi, 0
    
DrawCoinAnimLoop:
    push ecx
    
    ; Skip inactive animations
    cmp coinAnimActive[esi], 0
    je NextCoinAnimDraw
    
    ; Calculate screen X = worldX - pageOffset
    movzx eax, WORD PTR coinAnimX[esi*2]
    sub eax, edi
    
    ; Check if on current page
    cmp eax, 0
    jl NextCoinAnimDraw
    cmp eax, 118
    jg NextCoinAnimDraw
    
    ; Check Y bounds
    mov dh, coinAnimY[esi]
    cmp dh, 1
    jb NextCoinAnimDraw
    cmp dh, GROUND_TOP
    jae NextCoinAnimDraw
    
    mov dl, al                            ; Screen X
    call Gotoxy
    
    ; Draw the animated coin as VISIBLE YELLOW 'o' character
    mov eax, 14 + (9 * 16)                ; Bright yellow on blue background (visible!)
    call SetTextColor
    mov al, 'o'                           ; Lowercase 'o' for coin
    call WriteChar
    
NextCoinAnimDraw:
    inc esi
    pop ecx
    dec ecx
    jnz DrawCoinAnimLoop
    
    ret
DrawCoinAnimations ENDP

; ============================================================================
; SUPER MUSHROOM PROCEDURES
; ============================================================================

; ------------------------------------------------------------
; InitMushrooms: Clear all mushroom slots
; ------------------------------------------------------------
InitMushrooms PROC USES ecx esi
    mov ecx, MAX_MUSHROOMS
    mov esi, 0
ClearMushroomsLoop:
    mov mushroomActive[esi], MUSHROOM_INACTIVE
    mov mushroomDir[esi], 1
    mov mushroomMoveCounter[esi], 0
    mov WORD PTR mushroomX[esi*2], 0
    mov mushroomY[esi], 0
    mov WORD PTR mushroomOldX[esi*2], 0
    mov mushroomOldY[esi], 0
    inc esi
    loop ClearMushroomsLoop
    ret
InitMushrooms ENDP

; ------------------------------------------------------------
; SpawnMushroom: Activate a mushroom at given world X/Y
; Inputs: EAX = world X, EDX = Y (tile above block)
; ------------------------------------------------------------
SpawnMushroom PROC USES ebx ecx esi
    mov ecx, MAX_MUSHROOMS
    mov esi, 0
FindFreeMushroom:
    cmp mushroomActive[esi], MUSHROOM_INACTIVE
    je FoundMushroomSlot
    inc esi
    loop FindFreeMushroom
    ret                                ; No free slot
    
FoundMushroomSlot:
    mov WORD PTR mushroomX[esi*2], ax
    mov mushroomY[esi], dl
    mov WORD PTR mushroomOldX[esi*2], ax
    mov mushroomOldY[esi], dl
    mov mushroomDir[esi], 1
    mov mushroomMoveCounter[esi], 0
    mov mushroomActive[esi], MUSHROOM_ACTIVE
    ret
SpawnMushroom ENDP

; ------------------------------------------------------------
; UpdateMushrooms: Move active mushrooms and apply gravity
; ------------------------------------------------------------
UpdateMushrooms PROC USES eax ebx ecx edx esi edi
    mov ecx, MAX_MUSHROOMS
    mov esi, 0
    
UpdateMushroomLoop:
    push ecx
    
    cmp mushroomActive[esi], MUSHROOM_ACTIVE
    jne NextMushroomUpdate
    
    ; Save old position for erasing
    movzx eax, WORD PTR mushroomX[esi*2]
    mov WORD PTR mushroomOldX[esi*2], ax
    mov al, mushroomY[esi]
    mov mushroomOldY[esi], al
    
    ; Calculate page offset for world->screen conversions
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; pageOffset
    
    ; Horizontal movement with throttle
    inc mushroomMoveCounter[esi]
    mov al, mushroomMoveCounter[esi]
    cmp al, MUSHROOM_MOVE_DELAY
    jb SkipMushroomHorizontal
    mov mushroomMoveCounter[esi], 0
    
    movzx ebx, WORD PTR mushroomX[esi*2]
    movsx eax, mushroomDir[esi]
    add ebx, eax
    
    ; Deactivate if out of world bounds
    cmp ebx, 0
    jl DeactivateMushroom
    cmp ebx, LEVEL_MAX_X
    jg DeactivateMushroom
    
    ; Check wall collision when on current page
    mov eax, ebx
    sub eax, edi
    mov dl, al
    cmp eax, 0
    jl SkipMushroomWallCheck
    cmp eax, 118
    jg SkipMushroomWallCheck
    
    mov al, dl
    mov ah, mushroomY[esi]
    call IsWallOrGround
    cmp al, 1
    je ReverseMushroomDir
    
SkipMushroomWallCheck:
    mov WORD PTR mushroomX[esi*2], bx
    jmp ApplyMushroomGravity
    
ReverseMushroomDir:
    neg mushroomDir[esi]
    
SkipMushroomHorizontal:
ApplyMushroomGravity:
    ; Convert to screen coordinates for gravity checks
    movzx eax, WORD PTR mushroomX[esi*2]
    sub eax, edi
    mov dl, al
    cmp eax, 0
    jl NextMushroomUpdate
    cmp eax, 118
    jg NextMushroomUpdate
    
    mov al, dl
    mov ah, mushroomY[esi]
    inc ah
    call IsWallOrGround
    cmp al, 1
    je NextMushroomUpdate
    
    mov al, dl
    mov ah, mushroomY[esi]
    inc ah
    call IsPlatform
    cmp al, 1
    je NextMushroomUpdate
    
    inc mushroomY[esi]
    cmp mushroomY[esi], GROUND_TOP + 1
    jb NextMushroomUpdate
    mov mushroomActive[esi], MUSHROOM_INACTIVE
    jmp NextMushroomUpdate
    
DeactivateMushroom:
    mov mushroomActive[esi], MUSHROOM_INACTIVE
    
NextMushroomUpdate:
    inc esi
    pop ecx
    dec ecx
    jnz UpdateMushroomLoop
    
    ret
UpdateMushrooms ENDP

; ------------------------------------------------------------
; EraseMushrooms: Clear mushrooms from their old positions
; ------------------------------------------------------------
EraseMushrooms PROC USES eax ebx ecx edx esi edi
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax
    
    mov ecx, MAX_MUSHROOMS
    mov esi, 0
    
EraseMushroomLoop:
    push ecx
    
    cmp mushroomActive[esi], MUSHROOM_INACTIVE
    je NextEraseMushroom
    
    movzx eax, WORD PTR mushroomOldX[esi*2]
    sub eax, edi
    cmp eax, 0
    jl SkipEraseWrite
    cmp eax, 118
    jg SkipEraseWrite
    
    mov dh, mushroomOldY[esi]
    cmp dh, PLAY_MIN_Y
    jb SkipEraseWrite
    cmp dh, GROUND_TOP
    jae SkipEraseWrite
    
    mov dl, al
    call Gotoxy
    mov eax, GP_BG
    call SetTextColor
    mov al, ' '
    call WriteChar
    
SkipEraseWrite:
    cmp mushroomActive[esi], MUSHROOM_REMOVE
    jne NextEraseMushroom
    mov mushroomActive[esi], MUSHROOM_INACTIVE
    
NextEraseMushroom:
    inc esi
    pop ecx
    dec ecx
    jnz EraseMushroomLoop
    
    ret
EraseMushrooms ENDP

; ------------------------------------------------------------
; DrawMushrooms: Render active mushrooms on current page
; ------------------------------------------------------------
DrawMushrooms PROC USES eax ebx ecx edx esi edi
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax
    
    mov ecx, MAX_MUSHROOMS
    mov esi, 0
    
DrawMushroomLoop:
    push ecx
    
    cmp mushroomActive[esi], MUSHROOM_ACTIVE
    jne NextDrawMushroom
    
    movzx eax, WORD PTR mushroomX[esi*2]
    sub eax, edi
    cmp eax, 0
    jl NextDrawMushroom
    cmp eax, 118
    jg NextDrawMushroom
    
    mov dh, mushroomY[esi]
    cmp dh, PLAY_MIN_Y
    jb NextDrawMushroom
    cmp dh, GROUND_TOP
    jae NextDrawMushroom
    
    mov dl, al
    call Gotoxy
    mov eax, GP_MUSHROOM
    call SetTextColor
    mov al, MUSHROOM_CHAR
    call WriteChar
    
NextDrawMushroom:
    inc esi
    pop ecx
    dec ecx
    jnz DrawMushroomLoop
    
    ret
DrawMushrooms ENDP

; ------------------------------------------------------------
; HandleMarioMushroomCollision: Check Mario vs mushrooms
; Returns: AL = 1 if mushroom collected, 0 otherwise
; ------------------------------------------------------------
HandleMarioMushroomCollision PROC USES ebx ecx edx esi edi
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; pageOffset
    
    movzx ebx, playerX
    add ebx, edi                         ; Mario world X
    
    mov ecx, MAX_MUSHROOMS
    mov esi, 0
    
CheckMushroomCollisionLoop:
    push ecx
    
    cmp mushroomActive[esi], MUSHROOM_ACTIVE
    jne NextMushroomCollision
    
    movzx eax, WORD PTR mushroomX[esi*2]
    sub eax, ebx
    cmp eax, 0
    jge CheckMushroomXPos
    neg eax
CheckMushroomXPos:
    cmp eax, 1
    ja NextMushroomCollision
    
    movzx eax, mushroomY[esi]
    movzx edx, playerY
    sub eax, edx
    cmp eax, 0
    jge CheckMushroomYPos
    neg eax
CheckMushroomYPos:
    cmp eax, 1
    ja NextMushroomCollision
    
    ; Collect mushroom!
    mov mushroomActive[esi], MUSHROOM_REMOVE
    mov powerState, POWER_SUPER
    mov powerUpTimer, POWER_PROTECT_FRAMES
    
    mov eax, score
    add eax, MUSHROOM_POINTS
    mov score, eax
    
    ; Update HUD and player color
    push esi
    push edi
    call DrawHUD
    pop edi
    pop esi
    call DrawPlayer
    call PlayPowerupSound
    
    pop ecx
    mov al, 1
    ret
    
NextMushroomCollision:
    inc esi
    pop ecx
    dec ecx
    jnz CheckMushroomCollisionLoop
    
    mov al, 0
    ret
HandleMarioMushroomCollision ENDP

; ------------------------------------------------------------
; ApplyMarioDamage: Handle damage with power-up logic
; Returns: AL = 1 if Mario should die, 0 if damage absorbed
; ------------------------------------------------------------
ApplyMarioDamage PROC
    ; If currently protected, ignore damage
    cmp powerUpTimer, 0
    jne IgnoreDamage
    
    ; If super, shrink back to small instead of dying
    cmp powerState, POWER_SUPER
    jne MarioShouldDie
    
    mov powerState, POWER_SMALL
    mov powerUpTimer, POWER_PROTECT_FRAMES
    call DrawPlayer
    mov al, 0
    ret
    
IgnoreDamage:
    mov al, 0
    ret
    
MarioShouldDie:
    mov al, 1
    ret
ApplyMarioDamage ENDP

; ------------------------------------------------------------
; IsQuestionBlock: Check if a position contains a question block
; Input: AL = X (screen coords), AH = Y
; Returns: AL = 1 if question block (active or used), 0 if not
; Note: This is for collision detection - blocks are solid
; ------------------------------------------------------------
IsQuestionBlock PROC USES ebx ecx edx esi edi
    movzx ebx, al                         ; Screen X
    mov checkY, ah
    
    ; Calculate page offset
    mov eax, currentPage
    push ebx
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; pageOffset
    pop ebx
    
    ; Convert to world X
    add ebx, edi                          ; EBX = world X
    
    ; Check each question block
    movzx ecx, qblockCount
    cmp ecx, 0
    je NotQBlock
    
    mov esi, 0
    
CheckIsQBlockLoop:
    ; Check Y match
    mov al, qblockY[esi]
    cmp checkY, al
    jne NextIsQBlock
    
    ; Check X match
    movzx eax, WORD PTR qblockX[esi*2]
    cmp ebx, eax
    jne NextIsQBlock
    
    ; Found a question block at this position
    mov al, 1
    ret
    
NextIsQBlock:
    inc esi
    dec ecx
    jnz CheckIsQBlockLoop
    
NotQBlock:
    mov al, 0
    ret
IsQuestionBlock ENDP

; ------------------------------------------------------------
; IsBrick: Check if a position contains a brick block
; Input: AL = X (screen coords), AH = Y
; Returns: AL = 1 if brick block exists, 0 if not
; Note: Bricks are solid obstacles like question blocks
; ------------------------------------------------------------
IsBrick PROC USES ebx ecx edx esi edi
    movzx ebx, al                         ; Screen X
    mov checkY, ah
    
    ; Calculate page offset
    mov eax, currentPage
    push ebx
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                          ; pageOffset
    pop ebx
    
    ; Convert to world X
    add ebx, edi                          ; EBX = world X
    
    ; Check each brick block
    movzx ecx, brickCount
    cmp ecx, 0
    je NotBrick
    
    mov esi, 0
    
CheckIsBrickLoop:
    ; Check Y match
    mov al, brickY[esi]
    cmp checkY, al
    jne NextIsBrick
    
    ; Check X match
    movzx eax, WORD PTR brickX[esi*2]
    cmp ebx, eax
    jne NextIsBrick
    
    ; Found a brick at this position
    mov al, 1
    ret
    
NextIsBrick:
    inc esi
    dec ecx
    jnz CheckIsBrickLoop
    
NotBrick:
    mov al, 0
    ret
IsBrick ENDP

; ============================================================
; GOOMBA ENEMY SYSTEM PROCEDURES
; ============================================================

; ------------------------------------------------------------
; InitGoombas: Initialize all goombas for the level
; Places goombas at strategic positions across the level
; ------------------------------------------------------------
InitGoombas PROC USES eax ecx esi
    ; Clear all goombas first
    mov ecx, MAX_GOOMBAS
    mov esi, 0
ClearGoombasLoop:
    mov goombaState[esi], GOOMBA_INACTIVE
    mov goombaTimer[esi], 0
    mov goombaMoveCounter[esi], 0       ; Initialize speed throttle counter
    inc esi
    loop ClearGoombasLoop
    
    ; Place goombas across the level
    ; Goomba 0: Page 0, near first platform
    mov esi, 0
    mov WORD PTR goombaX[esi*2], 40
    mov goombaY[esi], 21                ; Ground level
    mov goombaDir[esi], -1              ; Moving left
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    mov goombaMoveCounter[esi], 0       ; Start counter at 0
    
    ; Goomba 1: Page 0, middle area
    inc esi
    mov WORD PTR goombaX[esi*2], 70
    mov goombaY[esi], 21
    mov goombaDir[esi], 1               ; Moving right
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 2: Page 0, near pipe
    inc esi
    mov WORD PTR goombaX[esi*2], 100
    mov goombaY[esi], 21
    mov goombaDir[esi], -1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 3: Page 1, early area
    inc esi
    mov WORD PTR goombaX[esi*2], 130
    mov goombaY[esi], 21
    mov goombaDir[esi], 1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 4: Page 1, middle
    inc esi
    mov WORD PTR goombaX[esi*2], 175
    mov goombaY[esi], 21
    mov goombaDir[esi], -1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 5: Page 1, late area
    inc esi
    mov WORD PTR goombaX[esi*2], 210
    mov goombaY[esi], 21
    mov goombaDir[esi], 1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 6: Page 2, middle (MOVED AWAY from page start - NOT at X=255)
    inc esi
    mov WORD PTR goombaX[esi*2], 290
    mov goombaY[esi], 21
    mov goombaDir[esi], -1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 7: Page 2, late
    inc esi
    mov WORD PTR goombaX[esi*2], 310
    mov goombaY[esi], 21
    mov goombaDir[esi], 1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 8: Page 2, late (before flagpole)
    inc esi
    mov WORD PTR goombaX[esi*2], 330
    mov goombaY[esi], 21
    mov goombaDir[esi], -1
    mov goombaState[esi], GOOMBA_WALKING
    mov goombaTimer[esi], 0
    
    ; Goomba 9: Reserved/inactive
    inc esi
    mov goombaState[esi], GOOMBA_INACTIVE
    
    ret
InitGoombas ENDP

; ------------------------------------------------------------
; UpdateGoombas: Update all goomba positions and states
; Handles movement, gravity, wall collision, edge detection
; INCLUDES SPEED THROTTLING - goombas only move every Nth frame
; Adjust GOOMBA_MOVE_DELAY constant to change speed
; ------------------------------------------------------------
UpdateGoombas PROC USES eax ebx ecx edx esi edi
    mov ecx, MAX_GOOMBAS
    mov esi, 0
    
UpdateGoombaLoop:
    push ecx
    
    ; Check goomba state
    cmp goombaState[esi], GOOMBA_INACTIVE
    je NextGoombaUpdate
    
    ; Handle dying state (countdown timer)
    cmp goombaState[esi], GOOMBA_DYING
    jne GoombaWalkingUpdate
    
    ; Dying: decrement timer, deactivate when done
    dec goombaTimer[esi]
    cmp goombaTimer[esi], 0
    ja NextGoombaUpdate
    mov goombaState[esi], GOOMBA_INACTIVE
    jmp NextGoombaUpdate
    
GoombaWalkingUpdate:
    ; ==========================================================================
    ; SPEED THROTTLING: Only move goomba every GOOMBA_MOVE_DELAY frames
    ; This fixes the "too fast" bug by slowing down goomba movement
    ; ==========================================================================
    inc goombaMoveCounter[esi]          ; Increment frame counter
    mov al, goombaMoveCounter[esi]
    cmp al, GOOMBA_MOVE_DELAY           ; Check if it's time to move
    jb SkipGoombaMovement               ; Not yet - skip horizontal movement
    
    ; Reset counter and proceed with movement
    mov goombaMoveCounter[esi], 0
    
    ; Save old position for erasing
    movzx eax, WORD PTR goombaX[esi*2]
    mov WORD PTR goombaOldX[esi*2], ax
    mov al, goombaY[esi]
    mov goombaOldY[esi], al
    
    ; Apply horizontal movement based on direction
    movsx eax, goombaDir[esi]           ; Get direction (-1 or +1)
    movzx ebx, WORD PTR goombaX[esi*2]  ; Get current X
    add ebx, eax                         ; Apply movement
    
    ; Boundary check (don't go below 0)
    cmp ebx, 0
    jl ReverseGoombaDir
    cmp ebx, 370                         ; Max world X
    jg ReverseGoombaDir
    
    ; Check for wall collision at new position
    ; Convert world X to screen X for collision check
    push esi
    push ecx
    
    mov eax, currentPage
    push ebx
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    pop ebx
    
    ; Calculate screen X
    mov eax, ebx                         ; New world X
    sub eax, edi                         ; Screen X = world X - pageOffset
    
    ; Only check collision if goomba is on current page
    cmp eax, 0
    jl SkipWallCheck
    cmp eax, 118
    jg SkipWallCheck
    
    ; Check wall collision
    mov ah, goombaY[esi]
    call IsWallOrGround
    cmp al, 1
    je ReverseGoombaDirPop
    
    ; Check if there's ground ahead (edge detection)
    mov eax, ebx
    sub eax, edi
    mov ah, goombaY[esi]
    inc ah                               ; Check one tile below
    call IsWallOrGround
    cmp al, 1
    jne ReverseGoombaDirPop              ; No ground ahead, turn around
    
SkipWallCheck:
    pop ecx
    pop esi
    
    ; Apply the movement
    mov WORD PTR goombaX[esi*2], bx
    jmp ApplyGoombaGravity
    
ReverseGoombaDirPop:
    pop ecx
    pop esi
    
ReverseGoombaDir:
    ; Reverse direction
    neg goombaDir[esi]
    jmp ApplyGoombaGravity
    
SkipGoombaMovement:
    ; Speed throttle not ready - skip horizontal movement but still apply gravity
    ; Save old position for erasing (even when not moving horizontally)
    movzx eax, WORD PTR goombaX[esi*2]
    mov WORD PTR goombaOldX[esi*2], ax
    mov al, goombaY[esi]
    mov goombaOldY[esi], al
    
ApplyGoombaGravity:
    ; Apply gravity - check if goomba should fall
    push esi
    push ecx
    
    ; Get world X and convert to screen coords
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; pageOffset
    
    movzx eax, WORD PTR goombaX[esi*2]
    sub eax, edi                         ; Screen X
    
    ; Check ground below goomba
    mov ah, goombaY[esi]
    inc ah                               ; Y + 1 (below)
    
    ; Only apply gravity if on screen
    cmp al, 0
    jl SkipGoombaGravity
    cmp al, 118
    jg SkipGoombaGravity
    
    call IsWallOrGround
    cmp al, 1
    je SkipGoombaGravity                 ; On solid ground
    
    ; Also check platforms
    movzx eax, WORD PTR goombaX[esi*2]
    sub eax, edi
    mov ah, goombaY[esi]
    inc ah
    call IsPlatform
    cmp al, 1
    je SkipGoombaGravity                 ; On platform
    
    ; Fall down
    inc goombaY[esi]
    
    ; Check if fell off screen (below ground)
    cmp goombaY[esi], GROUND_TOP + 2
    jb SkipGoombaGravity
    mov goombaState[esi], GOOMBA_INACTIVE ; Deactivate if fell too far
    
SkipGoombaGravity:
    pop ecx
    pop esi
    
NextGoombaUpdate:
    inc esi
    pop ecx
    dec ecx
    jnz UpdateGoombaLoop
    
    ret
UpdateGoombas ENDP

; ------------------------------------------------------------
; DrawGoombas: Render all active goombas on screen
; Converts world coordinates to screen coordinates
; ------------------------------------------------------------
DrawGoombas PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    mov ecx, MAX_GOOMBAS
    mov esi, 0
    
DrawGoombaLoop:
    push ecx
    
    ; Check if goomba is active
    cmp goombaState[esi], GOOMBA_INACTIVE
    je NextGoombaDraw
    
    ; Calculate screen X = worldX - pageOffset
    movzx eax, WORD PTR goombaX[esi*2]
    sub eax, edi
    
    ; Check if goomba is on current page (visible)
    cmp eax, 0
    jl NextGoombaDraw
    cmp eax, 118
    jg NextGoombaDraw
    
    ; Check Y bounds
    mov dh, goombaY[esi]
    cmp dh, PLAY_MIN_Y
    jb NextGoombaDraw
    cmp dh, GROUND_TOP
    jae NextGoombaDraw
    
    mov dl, al                           ; Screen X
    call Gotoxy
    
    ; Set color based on state
    cmp goombaState[esi], GOOMBA_DYING
    je DrawDyingGoomba
    
    ; Normal walking goomba
    mov eax, GP_GOOMBA
    call SetTextColor
    mov al, GOOMBA_CHAR
    call WriteChar
    jmp NextGoombaDraw
    
DrawDyingGoomba:
    ; Squished/dying goomba (flat appearance)
    mov eax, GP_GOOMBA_DYING
    call SetTextColor
    mov al, '_'                          ; Flat/squished character
    call WriteChar
    
NextGoombaDraw:
    inc esi
    pop ecx
    dec ecx
    jnz DrawGoombaLoop
    
    ret
DrawGoombas ENDP

; ------------------------------------------------------------
; EraseGoombas: Erase goombas from their old positions
; Called before drawing at new positions
; ------------------------------------------------------------
EraseGoombas PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    mov ecx, MAX_GOOMBAS
    mov esi, 0
    
EraseGoombaLoop:
    push ecx
    
    ; Skip inactive goombas
    cmp goombaState[esi], GOOMBA_INACTIVE
    je NextGoombaErase
    
    ; Calculate old screen X
    movzx eax, WORD PTR goombaOldX[esi*2]
    sub eax, edi
    
    ; Check if old position was on screen
    cmp eax, 0
    jl NextGoombaErase
    cmp eax, 118
    jg NextGoombaErase
    
    mov dh, goombaOldY[esi]
    cmp dh, PLAY_MIN_Y
    jb NextGoombaErase
    cmp dh, GROUND_TOP
    jae NextGoombaErase
    
    mov dl, al
    call Gotoxy
    
    ; Erase with sky blue background
    mov eax, GP_BG
    call SetTextColor
    mov al, ' '
    call WriteChar
    
NextGoombaErase:
    inc esi
    pop ecx
    dec ecx
    jnz EraseGoombaLoop
    
    ret
EraseGoombas ENDP

; ------------------------------------------------------------
; HandleMarioGoombaCollision: Check and handle Mario-Goomba collisions
; 
; SIMPLIFIED STOMP LOGIC - Much more forgiving!
; STOMP = Mario is falling AND Mario's Y <= Goomba's Y (Mario above/at goomba)
; DAMAGE = Any other collision
;
; Returns: AL = 1 if Mario was hurt, AL = 0 otherwise
; ------------------------------------------------------------
HandleMarioGoombaCollision PROC USES ebx ecx edx esi edi
    ; Calculate page offset for world coordinate conversion
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    ; Calculate Mario's world X
    movzx ebx, playerX
    add ebx, edi                         ; EBX = Mario world X
    
    mov ecx, MAX_GOOMBAS
    mov esi, 0
    
CheckGoombaCollisionLoop:
    push ecx
    
    ; Skip inactive or dying goombas
    cmp goombaState[esi], GOOMBA_WALKING
    jne NextGoombaCollision
    
    ; ================================================================
    ; STEP 1: Check X collision (use STOMP_X_RANGE for forgiving hitbox)
    ; ================================================================
    movzx eax, WORD PTR goombaX[esi*2]
    sub eax, ebx                         ; Difference: goombaX - marioWorldX
    
    ; Get absolute value of X difference
    cmp eax, 0
    jge CheckGoombaXPos
    neg eax
CheckGoombaXPos:
    cmp eax, STOMP_X_RANGE               ; Within range horizontally?
    ja NextGoombaCollision               ; No X overlap, skip this goomba
    
    ; ================================================================
    ; STEP 2: Check Y proximity (use STOMP_Y_RANGE)
    ; ================================================================
    movzx eax, goombaY[esi]              ; Goomba Y
    movzx edx, playerY                   ; Mario's current Y
    
    ; Save goombaY for stomp check
    push eax
    
    ; Calculate absolute Y difference
    sub eax, edx                         ; goombaY - marioY
    cmp eax, 0
    jge CheckGoombaYPos
    neg eax
CheckGoombaYPos:
    cmp eax, STOMP_Y_RANGE               ; Within range vertically?
    pop eax                              ; Restore goombaY (in EAX)
    ja NextGoombaCollision               ; No collision, skip
    
    ; ================================================================
    ; STEP 3: SIMPLIFIED STOMP CHECK
    ; Stomp if: Mario is falling AND Mario is above or at goomba level
    ; (Lower Y value = higher on screen)
    ; ================================================================
    
    ; Check if Mario is falling (velY > 0)
    cmp velY, 0
    jle CheckDamageCollision             ; Not falling, check if damage
    
    ; Check if Mario is above or at goomba (marioY <= goombaY)
    ; EAX still has goombaY from above
    cmp edx, eax                         ; marioY (EDX) <= goombaY (EAX)?
    ja CheckDamageCollision              ; Mario is BELOW goomba, not a stomp
    
    ; ================================================================
    ; VALID STOMP! Mario defeats the goomba
    ; ================================================================
    mov goombaState[esi], GOOMBA_DYING
    mov goombaTimer[esi], 15             ; Death animation frames
    call PlayEnemyDefeatSound
    
    ; Bounce Mario upward
    mov velY, -3                         ; Upward bounce
    mov onGround, 0                      ; Mario is now airborne
    
    ; Award points (hook into existing score system)
    mov eax, score
    add eax, GOOMBA_POINTS
    mov score, eax
    
    ; Update HUD to show new score
    push esi
    push ebx
    push edi
    call DrawHUD
    pop edi
    pop ebx
    pop esi
    
    ; Return success (no damage)
    jmp NextGoombaCollision
    
CheckDamageCollision:
    ; ================================================================
    ; Check if this is actually a close enough collision for damage
    ; Must be within DAMAGE_RANGE on both axes
    ; ================================================================
    movzx eax, WORD PTR goombaX[esi*2]
    sub eax, ebx
    cmp eax, 0
    jge CheckDamageXPos
    neg eax
CheckDamageXPos:
    cmp eax, DAMAGE_RANGE                ; Must be within range for damage
    ja NextGoombaCollision
    
    movzx eax, goombaY[esi]
    movzx edx, playerY
    sub eax, edx
    cmp eax, 0
    jge CheckDamageYPos
    neg eax
CheckDamageYPos:
    cmp eax, DAMAGE_RANGE                ; Must be within range for damage
    ja NextGoombaCollision
    
    ; Close collision but not a stomp = DAMAGE
    pop ecx                              ; Balance the stack
    mov al, 1                            ; Return 1 = Mario hurt
    ret
    
NextGoombaCollision:
    inc esi
    pop ecx
    dec ecx
    jnz CheckGoombaCollisionLoop
    
    mov al, 0                            ; Return 0 = Mario not hurt
    ret
HandleMarioGoombaCollision ENDP

; ============================================================
; KOOPA TROOPA ENEMY SYSTEM PROCEDURES
; ============================================================

; ------------------------------------------------------------
; InitKoopas: Initialize all koopas for the level
; Places koopas at strategic positions across the level
; ------------------------------------------------------------
InitKoopas PROC USES eax ecx esi
    ; Clear all koopas first
    mov ecx, MAX_KOOPAS
    mov esi, 0
ClearKoopasLoop:
    mov koopaState[esi], KOOPA_INACTIVE
    mov koopaTimer[esi], 0
    mov koopaMoveCounter[esi], 0
    inc esi
    loop ClearKoopasLoop
    
    ; Place koopas on ALL pages, but NOT at the start of each page
    ; Position them in middle-to-late sections of each page
    ; ================================================================
    ; PAGE 0 KOOPAS (X: 0-119) - 2 koopas, middle/late positions only
    ; ================================================================
    ; Koopa 0: Page 0, middle area (avoid start)
    mov esi, 0
    mov WORD PTR koopaX[esi*2], 60
    mov koopaY[esi], 21
    mov koopaDir[esi], 1                 ; Moving right
    mov koopaState[esi], KOOPA_WALKING
    mov koopaTimer[esi], 0
    mov koopaMoveCounter[esi], 0
    
    ; Koopa 1: Page 0, late area
    inc esi
    mov WORD PTR koopaX[esi*2], 95
    mov koopaY[esi], 21
    mov koopaDir[esi], -1                ; Moving left
    mov koopaState[esi], KOOPA_WALKING
    mov koopaTimer[esi], 0
    
    ; ================================================================
    ; PAGE 1 KOOPAS (X: 120-239) - 2 koopas, middle/late positions
    ; ================================================================
    ; Koopa 2: Page 1, middle area
    inc esi
    mov WORD PTR koopaX[esi*2], 170
    mov koopaY[esi], 21
    mov koopaDir[esi], 1
    mov koopaState[esi], KOOPA_WALKING
    mov koopaTimer[esi], 0
    
    ; Koopa 3: Page 1, late area
    inc esi
    mov WORD PTR koopaX[esi*2], 210
    mov koopaY[esi], 21
    mov koopaDir[esi], -1
    mov koopaState[esi], KOOPA_WALKING
    mov koopaTimer[esi], 0
    
    ; ================================================================
    ; PAGE 2 KOOPAS (X: 240-359) - ONLY late-positioned koopa (FAR from start)
    ; ================================================================
    ; Koopa 4: Page 2, late area ONLY (NOT at X=280 - moved to X=315)
    inc esi
    mov WORD PTR koopaX[esi*2], 315
    mov koopaY[esi], 21
    mov koopaDir[esi], -1
    mov koopaState[esi], KOOPA_WALKING
    mov koopaTimer[esi], 0
    
    ; Skip remaining slots on page 2
    inc esi
    mov koopaState[esi], KOOPA_INACTIVE
    
    ; Remaining koopas: inactive
    inc esi
    mov ecx, MAX_KOOPAS
    sub ecx, 6                           ; Already processed 5 active + 1 inactive = 6 total
SetInactiveKoopas:
    mov koopaState[esi], KOOPA_INACTIVE
    inc esi
    dec ecx
    jnz SetInactiveKoopas
    
    ret
InitKoopas ENDP

; ------------------------------------------------------------
; UpdateKoopas: Update all koopa positions and states
; Handles walking, shell idle, shell sliding, collisions
; ------------------------------------------------------------
UpdateKoopas PROC USES eax ebx ecx edx esi edi
    mov ecx, MAX_KOOPAS
    mov esi, 0
    
UpdateKoopaLoop:
    push ecx
    
    ; Check koopa state
    cmp koopaState[esi], KOOPA_INACTIVE
    je NextKoopaUpdate
    
    ; Save old position for erasing
    movzx eax, WORD PTR koopaX[esi*2]
    mov WORD PTR koopaOldX[esi*2], ax
    mov al, koopaY[esi]
    mov koopaOldY[esi], al
    
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    ; ================================================================
    ; HANDLE DIFFERENT KOOPA STATES
    ; ================================================================
    
    ; Check if SHELL_SLIDING
    cmp koopaState[esi], KOOPA_SHELL_SLIDING
    je UpdateSlidingShell
    
    ; Check if SHELL_IDLE (no movement, just gravity)
    cmp koopaState[esi], KOOPA_SHELL_IDLE
    je ApplyKoopaGravity
    
    ; Otherwise KOOPA_WALKING - use speed throttle
    ; ================================================================
    ; WALKING STATE: Horizontal movement with speed throttle
    ; ================================================================
    inc koopaMoveCounter[esi]
    mov al, koopaMoveCounter[esi]
    cmp al, KOOPA_MOVE_DELAY
    jb ApplyKoopaGravity                 ; Not ready to move yet
    
    ; Reset counter
    mov koopaMoveCounter[esi], 0
    
    ; Move horizontally based on direction
    movzx ebx, WORD PTR koopaX[esi*2]    ; Current X (world coords)
    movsx eax, koopaDir[esi]             ; Direction (-1 or +1)
    add ebx, eax                         ; New X
    
    ; Bounds check: don't go below 0 or beyond level end
    cmp ebx, 0
    jl ReverseKoopaDir
    cmp ebx, 360
    jg ReverseKoopaDir
    
    ; Save new X for collision checks
    push esi
    push ecx
    
    ; Calculate screen X
    mov eax, ebx                         ; New world X
    sub eax, edi                         ; Screen X = world X - pageOffset
    
    ; Only check collision if koopa is on current page
    cmp eax, 0
    jl SkipKoopaWallCheck
    cmp eax, 118
    jg SkipKoopaWallCheck
    
    ; Check wall collision
    mov ah, koopaY[esi]
    call IsWallOrGround
    cmp al, 1
    je ReverseKoopaDirPop
    
    ; Check if there's ground ahead (edge detection)
    mov eax, ebx
    sub eax, edi
    mov ah, koopaY[esi]
    inc ah                               ; Check one tile below
    call IsWallOrGround
    cmp al, 1
    jne ReverseKoopaDirPop               ; No ground ahead, turn around
    
SkipKoopaWallCheck:
    pop ecx
    pop esi
    
    ; Apply the movement
    mov WORD PTR koopaX[esi*2], bx
    jmp ApplyKoopaGravity
    
ReverseKoopaDirPop:
    pop ecx
    pop esi
    
ReverseKoopaDir:
    ; Reverse direction
    neg koopaDir[esi]
    jmp ApplyKoopaGravity

UpdateSlidingShell:
    ; ================================================================
    ; SLIDING SHELL STATE: Fast horizontal movement
    ; ================================================================
    ; Shells slide every frame (no throttle)
    movzx ebx, WORD PTR koopaX[esi*2]    ; Current X (world coords)
    movsx eax, koopaDir[esi]             ; Direction (-1 or +1)
    add ebx, eax                         ; New X
    
    ; Bounds check
    cmp ebx, 0
    jl StopShellSlide
    cmp ebx, 360
    jg StopShellSlide
    
    ; Check wall collision
    push esi
    push ecx
    
    mov eax, ebx
    sub eax, edi                         ; Screen X
    cmp eax, 0
    jl SkipShellWallCheck
    cmp eax, 118
    jg SkipShellWallCheck
    
    mov ah, koopaY[esi]
    call IsWallOrGround
    cmp al, 1
    je StopShellSlidePop                 ; Hit wall, stop
    
SkipShellWallCheck:
    pop ecx
    pop esi
    
    ; Apply movement
    mov WORD PTR koopaX[esi*2], bx
    
    ; Check for enemy collisions (shell kills enemies)
    push esi
    push ecx
    call HandleShellEnemyCollision
    pop ecx
    pop esi
    
    jmp ApplyKoopaGravity
    
StopShellSlidePop:
    pop ecx
    pop esi
    
StopShellSlide:
    ; Shell hit wall or boundary - stop sliding
    mov koopaState[esi], KOOPA_SHELL_IDLE
    jmp ApplyKoopaGravity
    
ApplyKoopaGravity:
    ; Apply gravity - check if koopa should fall
    push esi
    push ecx
    
    ; Get world X and convert to screen coords
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; pageOffset
    
    movzx eax, WORD PTR koopaX[esi*2]
    sub eax, edi                         ; Screen X
    
    ; Check ground below koopa
    mov ah, koopaY[esi]
    inc ah                               ; Y + 1 (below)
    
    ; Only apply gravity if on screen
    cmp al, 0
    jl SkipKoopaGravity
    cmp al, 118
    jg SkipKoopaGravity
    
    call IsWallOrGround
    cmp al, 1
    je SkipKoopaGravity                  ; On solid ground
    
    ; Also check platforms
    movzx eax, WORD PTR koopaX[esi*2]
    sub eax, edi
    mov ah, koopaY[esi]
    inc ah
    call IsPlatform
    cmp al, 1
    je SkipKoopaGravity                  ; On platform
    
    ; Fall down
    inc koopaY[esi]
    
    ; Check if fell off screen
    cmp koopaY[esi], GROUND_TOP + 2
    jb SkipKoopaGravity
    mov koopaState[esi], KOOPA_INACTIVE  ; Deactivate if fell too far
    
SkipKoopaGravity:
    pop ecx
    pop esi
    
NextKoopaUpdate:
    inc esi
    pop ecx
    dec ecx
    jnz UpdateKoopaLoop
    
    ret
UpdateKoopas ENDP

; ------------------------------------------------------------
; DrawKoopas: Render all active koopas on screen
; Converts world coordinates to screen coordinates
; ------------------------------------------------------------
DrawKoopas PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    mov ecx, MAX_KOOPAS
    mov esi, 0
    
DrawKoopaLoop:
    push ecx
    
    ; Skip inactive koopas
    cmp koopaState[esi], KOOPA_INACTIVE
    je NextKoopaDraw
    
    ; Convert world X to screen X
    movzx eax, WORD PTR koopaX[esi*2]
    sub eax, edi                         ; Screen X = world X - pageOffset
    
    ; Only draw if on screen
    cmp eax, 0
    jl NextKoopaDraw
    cmp eax, 118
    jg NextKoopaDraw
    
    ; Set cursor position
    mov dh, koopaY[esi]
    mov dl, al
    call Gotoxy
    
    ; Choose character and color based on state
    cmp koopaState[esi], KOOPA_WALKING
    je DrawWalkingKoopa
    
    ; Shell state (idle or sliding)
    cmp koopaState[esi], KOOPA_SHELL_SLIDING
    je DrawSlidingShell
    
    ; Otherwise SHELL_IDLE
    mov eax, GP_KOOPA_SHELL              ; Yellow shell
    call SetTextColor
    mov al, KOOPA_SHELL_CHAR
    call WriteChar
    jmp NextKoopaDraw
    
DrawWalkingKoopa:
    mov eax, GP_KOOPA_WALK               ; Green koopa
    call SetTextColor
    mov al, KOOPA_WALK_CHAR
    call WriteChar
    jmp NextKoopaDraw
    
DrawSlidingShell:
    mov eax, GP_KOOPA_SLIDE              ; Red sliding shell
    call SetTextColor
    mov al, KOOPA_SHELL_CHAR
    call WriteChar
    
NextKoopaDraw:
    inc esi
    pop ecx
    dec ecx
    jnz DrawKoopaLoop
    
    ret
DrawKoopas ENDP

; ------------------------------------------------------------
; EraseKoopas: Erase koopas from their old positions
; Called before drawing at new positions
; ------------------------------------------------------------
EraseKoopas PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    mov ecx, MAX_KOOPAS
    mov esi, 0
    
EraseKoopaLoop:
    push ecx
    
    ; Skip inactive koopas
    cmp koopaState[esi], KOOPA_INACTIVE
    je NextKoopaErase
    
    ; Convert old world X to screen X
    movzx eax, WORD PTR koopaOldX[esi*2]
    sub eax, edi                         ; Screen X = world X - pageOffset
    
    ; Only erase if on screen
    cmp eax, 0
    jl NextKoopaErase
    cmp eax, 118
    jg NextKoopaErase
    
    ; Set cursor position
    mov dh, koopaOldY[esi]
    mov dl, al
    call Gotoxy
    
    ; Erase with sky blue background
    mov eax, GP_BG
    call SetTextColor
    mov al, ' '
    call WriteChar
    
NextKoopaErase:
    inc esi
    pop ecx
    dec ecx
    jnz EraseKoopaLoop
    
    ret
EraseKoopas ENDP

; ------------------------------------------------------------
; HandleMarioKoopaCollision: Check and handle Mario-Koopa collisions
; 
; STOMP = Mario falling + above koopa → koopa becomes shell (or stops shell)
; KICK = Mario hits idle shell from side → shell starts sliding
; DAMAGE = Mario hits walking koopa or sliding shell from side
; 
; Returns: AL = 1 if Mario was hurt, AL = 0 otherwise
; ------------------------------------------------------------
HandleMarioKoopaCollision PROC USES ebx ecx edx esi edi
    ; Calculate page offset for world coordinate conversion
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    ; Mario's world X
    movzx ebx, playerX
    add ebx, edi                         ; Mario world X
    
    mov ecx, MAX_KOOPAS
    mov esi, 0
    
KoopaCollisionLoop:
    push ecx
    
    ; Skip inactive koopas
    cmp koopaState[esi], KOOPA_INACTIVE
    je NextKoopaCollision
    
    ; ================================================================
    ; STEP 1: Check X proximity
    ; ================================================================
    movzx eax, WORD PTR koopaX[esi*2]    ; Koopa world X
    sub eax, ebx                         ; koopaX - marioX
    cmp eax, 0
    jge CheckKoopaXPos
    neg eax
CheckKoopaXPos:
    cmp eax, STOMP_X_RANGE               ; Within range horizontally?
    ja NextKoopaCollision
    
    ; ================================================================
    ; STEP 2: Check Y proximity
    ; ================================================================
    movzx eax, koopaY[esi]               ; Koopa Y
    movzx edx, playerY                   ; Mario's current Y
    
    ; Save koopaY for stomp check
    push eax
    
    ; Calculate absolute Y difference
    sub eax, edx                         ; koopaY - marioY
    cmp eax, 0
    jge CheckKoopaYPos
    neg eax
CheckKoopaYPos:
    cmp eax, STOMP_Y_RANGE
    pop eax                              ; Restore koopaY (in EAX)
    ja NextKoopaCollision
    
    ; ================================================================
    ; STEP 3: Check collision type based on state and Mario's movement
    ; ================================================================
    
    ; Check if Mario is falling (velY > 0) and above koopa
    cmp velY, 0
    jle CheckKickOrDamage                ; Not falling, check kick/damage
    
    ; Check if Mario is above koopa (marioY <= koopaY)
    cmp edx, eax                         ; marioY (EDX) <= koopaY (EAX)?
    ja CheckKickOrDamage                 ; Mario below, not a stomp
    
    ; ================================================================
    ; STOMP: Turn walking koopa into shell, or stop sliding shell
    ; ================================================================
    cmp koopaState[esi], KOOPA_WALKING
    je StompWalkingKoopa
    
    cmp koopaState[esi], KOOPA_SHELL_SLIDING
    je StopSlidingShell
    
    ; Idle shell stomped - no effect, just bounce Mario
    jmp BouncePlayerKoopa
    
StompWalkingKoopa:
    ; Walking koopa → shell idle
    mov koopaState[esi], KOOPA_SHELL_IDLE
    mov koopaTimer[esi], 0
    
    ; Award points
    mov eax, score
    add eax, KOOPA_POINTS
    mov score, eax
    
    ; Bounce Mario
    mov velY, -3
    mov onGround, 0
    
    ; Update HUD
    push esi
    push ebx
    push edi
    call DrawHUD
    pop edi
    pop ebx
    pop esi
    
    jmp NextKoopaCollision
    
StopSlidingShell:
    ; Sliding shell stomped → idle
    mov koopaState[esi], KOOPA_SHELL_IDLE
    mov koopaTimer[esi], 0
    
BouncePlayerKoopa:
    ; Bounce Mario
    mov velY, -3
    mov onGround, 0
    
    jmp NextKoopaCollision
    
CheckKickOrDamage:
    ; ================================================================
    ; Not a stomp - check if shell kick or damage collision
    ; ================================================================
    
    ; Check if it's an idle shell
    cmp koopaState[esi], KOOPA_SHELL_IDLE
    jne CheckDamageKoopa                 ; Not idle shell, check damage
    
    ; ================================================================
    ; KICK IDLE SHELL: Start it sliding
    ; ================================================================
    ; Determine kick direction based on Mario's position
    movzx eax, WORD PTR koopaX[esi*2]    ; Koopa world X
    cmp ebx, eax                         ; Compare Mario X with Koopa X
    jl KickRight                         ; Mario left of shell, kick right
    
KickLeft:
    mov koopaDir[esi], -1                ; Kick left
    jmp StartShellSlide
    
KickRight:
    mov koopaDir[esi], 1                 ; Kick right
    
StartShellSlide:
    mov koopaState[esi], KOOPA_SHELL_SLIDING
    
    ; Award kick points
    mov eax, score
    add eax, SHELL_KICK_POINTS
    mov score, eax
    
    ; Update HUD
    push esi
    push ebx
    push edi
    call DrawHUD
    pop edi
    pop ebx
    pop esi
    
    jmp NextKoopaCollision
    
CheckDamageKoopa:
    ; ================================================================
    ; DAMAGE: Walking koopa or sliding shell hits Mario
    ; ================================================================
    ; Check if within damage range
    movzx eax, WORD PTR koopaX[esi*2]
    sub eax, ebx
    cmp eax, 0
    jge CheckDamageKoopaXPos
    neg eax
CheckDamageKoopaXPos:
    cmp eax, DAMAGE_RANGE
    ja NextKoopaCollision
    
    movzx eax, koopaY[esi]
    movzx edx, playerY
    sub eax, edx
    cmp eax, 0
    jge CheckDamageKoopaYPos
    neg eax
CheckDamageKoopaYPos:
    cmp eax, DAMAGE_RANGE
    ja NextKoopaCollision
    
    ; Close collision = DAMAGE
    pop ecx                              ; Balance stack
    mov al, 1                            ; Return 1 = Mario hurt
    ret
    
NextKoopaCollision:
    inc esi
    pop ecx
    dec ecx
    jnz KoopaCollisionLoop
    
    mov al, 0                            ; Return 0 = Mario not hurt
    ret
HandleMarioKoopaCollision ENDP

; ------------------------------------------------------------
; HandleShellEnemyCollision: Check if sliding shell hits enemies
; Called during shell movement to kill goombas/koopas it touches
; ESI = current koopa index (must be in SHELL_SLIDING state)
; ------------------------------------------------------------
HandleShellEnemyCollision PROC USES eax ebx ecx edx edi
    ; Shell position
    movzx ebx, WORD PTR koopaX[esi*2]    ; Shell world X
    movzx edx, koopaY[esi]               ; Shell Y
    
    ; ================================================================
    ; Check collision with all goombas
    ; ================================================================
    mov ecx, MAX_GOOMBAS
    mov edi, 0
    
CheckShellGoombaLoop:
    push ecx
    
    ; Skip inactive/dying goombas
    cmp goombaState[edi], GOOMBA_WALKING
    jne NextShellGoomba
    
    ; Check X proximity
    movzx eax, WORD PTR goombaX[edi*2]
    sub eax, ebx
    cmp eax, 0
    jge CheckShellGoombaX
    neg eax
CheckShellGoombaX:
    cmp eax, 1                           ; Within 1 tile
    ja NextShellGoomba
    
    ; Check Y match
    movzx eax, goombaY[edi]
    cmp eax, edx
    jne NextShellGoomba
    
    ; Shell hit goomba - kill it!
    mov goombaState[edi], GOOMBA_DYING
    mov goombaTimer[edi], 10
    
    ; Award points
    mov eax, score
    add eax, SHELL_KILL_POINTS
    mov score, eax
    
    ; Update HUD
    push esi
    push edi
    call DrawHUD
    pop edi
    pop esi
    
NextShellGoomba:
    inc edi
    pop ecx
    dec ecx
    jnz CheckShellGoombaLoop
    
    ; ================================================================
    ; Check collision with other koopas
    ; ================================================================
    mov ecx, MAX_KOOPAS
    mov edi, 0
    
CheckShellKoopaLoop:
    push ecx
    
    ; Skip self
    cmp edi, esi
    je NextShellKoopa
    
    ; Skip inactive koopas
    cmp koopaState[edi], KOOPA_INACTIVE
    je NextShellKoopa
    
    ; Skip other sliding shells (they pass through each other)
    cmp koopaState[edi], KOOPA_SHELL_SLIDING
    je NextShellKoopa
    
    ; Check X proximity
    movzx eax, WORD PTR koopaX[edi*2]
    sub eax, ebx
    cmp eax, 0
    jge CheckShellKoopaX
    neg eax
CheckShellKoopaX:
    cmp eax, 1
    ja NextShellKoopa
    
    ; Check Y match
    movzx eax, koopaY[edi]
    cmp eax, edx
    jne NextShellKoopa
    
    ; Shell hit koopa - turn it into idle shell or kill it
    cmp koopaState[edi], KOOPA_WALKING
    je HitWalkingKoopa
    
    ; Hit idle shell - kill it
    mov koopaState[edi], KOOPA_INACTIVE
    jmp AwardShellKoopaPoints
    
HitWalkingKoopa:
    mov koopaState[edi], KOOPA_SHELL_IDLE
    
AwardShellKoopaPoints:
    ; Award points
    mov eax, score
    add eax, SHELL_KILL_POINTS
    mov score, eax
    
    ; Update HUD
    push esi
    push edi
    call DrawHUD
    pop edi
    pop esi
    
NextShellKoopa:
    inc edi
    pop ecx
    dec ecx
    jnz CheckShellKoopaLoop
    
    ret
HandleShellEnemyCollision ENDP

; ============================================================
; LIFE SYSTEM PROCEDURES
; ============================================================

; ------------------------------------------------------------
; InitPlayerLives: Initialize player lives and respawn position
; ------------------------------------------------------------
InitPlayerLives PROC
    mov lives, 3                         ; Start with 3 lives
    mov respawnX, 10                     ; Respawn X position
    mov respawnY, 21                     ; Respawn Y position (ground level)
    mov respawnPage, 0                   ; Respawn on page 0
    ret
InitPlayerLives ENDP

; ------------------------------------------------------------
; CheckPlayerDeathConditions: Check if Mario should die
; Returns: AL = 1 if Mario should die, AL = 0 otherwise
; ------------------------------------------------------------
CheckPlayerDeathConditions PROC USES ebx
    ; Level 2 lava check
    cmp currentLevel, 2
    jne L1DeathCheck
    mov al, playerX
    mov ah, playerY
    call Level2IsLava
    cmp al, 1
    je PlayerShouldDie

L1DeathCheck:
    ; Check 1: Did Mario fall below the level?
    cmp playerY, GROUND_TOP + 2
    jae PlayerShouldDie
    
    ; Check 2: Goomba collision is handled separately
    ; (HandleMarioGoombaCollision returns 1 if Mario was hurt)
    
    mov al, 0                            ; Not dead
    ret
    
PlayerShouldDie:
    mov al, 1                            ; Should die
    ret
CheckPlayerDeathConditions ENDP

; ------------------------------------------------------------
; HandlePlayerDeath: Process Mario's death
; Decrements lives, shows death animation, respawns or game over
; ------------------------------------------------------------
HandlePlayerDeath PROC USES eax ebx ecx edx
    ; Set dying state
    mov gameState, STATE_PLAYER_DYING
    mov deathTimer, 30                   ; Death animation frames
    
    ; Decrement lives
    dec lives
    
    ; Update HUD to show new lives count
    call DrawHUD
    
    ; Brief pause for death effect
    mov eax, 500
    call Delay
    
    ; Check if game over
    cmp lives, 0
    je TriggerGameOver
    
    ; Respawn Mario
    mov al, respawnX
    mov playerX, al
    mov oldPlayerX, al
    mov al, respawnY
    mov playerY, al
    mov oldPlayerY, al
    mov marioPrevY, al                   ; Reset for stomp detection
    mov velY, 0
    mov onGround, 1
    mov powerState, POWER_SMALL
    mov powerUpTimer, 0
    
    ; Reset to respawn page
    mov eax, respawnPage
    mov currentPage, eax
    
    ; Redraw the screen
    call InitQuestionBlocks               ; Reset question blocks so they reappear
    call InitGoombas                     ; Reset goombas
    call InitKoopas                      ; Reset koopas
    call InitCoinAnimations              ; Clear any active coin animations
    call InitMushrooms                   ; Clear any active mushrooms
    call DrawInitialScreen               ; Draws everything including goombas
    call DrawGoombas
    call DrawKoopas
    call DrawMushrooms
    call DrawPlayer
    call DrawHUD
    
    ; Note: Question blocks are NOT reset on death - once hit, they stay used
    ; This is classic Mario behavior
    
    ; Reset game state to playing
    mov gameState, STATE_PLAYING
    ret
    
TriggerGameOver:
    mov gameState, STATE_GAME_OVER
    ret
HandlePlayerDeath ENDP

; ------------------------------------------------------------
; ShowGameOverScreen: Display CLEAN game over screen
; NO red background - just simple white text on sky blue
; ------------------------------------------------------------
ShowGameOverScreen PROC USES eax edx ecx
    ; Clear screen with sky blue background first
    call FillBackground
    
    ; Use WHITE text on the existing sky blue background - clean and minimal
    mov eax, 15 + (9 * 16)               ; Bright white on light blue (sky)
    call SetTextColor
    
    ; "GAME OVER" - centered at row 10
    ; Screen is ~119 wide, "GAME OVER" is 9 chars, center = (119-9)/2 = 55
    mov dh, 10
    mov dl, 55
    call Gotoxy
    mov edx, OFFSET strGameOver1
    call WriteString
    
    ; "Press ENTER to continue..." - centered at row 12
    ; String is 26 chars, center = (119-26)/2 = 46
    mov dh, 12
    mov dl, 46
    call Gotoxy
    mov edx, OFFSET strGameOver2
    call WriteString
    
    ; Update high score if current score is higher
    mov eax, score
    cmp eax, highScore
    jbe SkipHighScoreUpdate
    mov highScore, eax
SkipHighScoreUpdate:
    
    ; Wait for ENTER key
WaitGameOverKey:
    call ReadChar
    cmp al, 13                           ; ENTER key
    jne WaitGameOverKey
    
    ret
ShowGameOverScreen ENDP

; ============================================================
; FLAGPOLE & LEVEL COMPLETION PROCEDURES
; ============================================================

; ------------------------------------------------------------
; DrawFlagpole: Render the flagpole at end of level
; ------------------------------------------------------------
DrawFlagpole PROC USES eax ebx ecx edx esi edi
    ; Calculate page offset
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; EDI = pageOffset
    
    ; Calculate screen X = flagpoleX - pageOffset
    movzx eax, flagpoleX
    sub eax, edi
    
    ; Check if flagpole is on current page
    cmp eax, 0
    jl FlagpoleDone
    cmp eax, 118
    jg FlagpoleDone
    
    mov dl, al                           ; Screen X
    
    ; Draw flag at top
    mov eax, GP_FLAG
    call SetTextColor
    mov dh, flagpoleTopY
    call Gotoxy
    mov al, FLAG_CHAR
    call WriteChar
    
    ; Draw pole from top+1 to bottom
    mov eax, GP_POLE
    call SetTextColor
    
    movzx ecx, flagpoleBottomY
    movzx eax, flagpoleTopY
    inc eax                              ; Start one below flag
    sub ecx, eax                         ; Height of pole
    inc ecx
    
    mov dh, al                           ; Start Y
DrawPoleLoop:
    push ecx
    call Gotoxy
    mov al, POLE_CHAR
    call WriteChar
    inc dh
    pop ecx
    loop DrawPoleLoop
    
FlagpoleDone:
    ret
DrawFlagpole ENDP

; ------------------------------------------------------------
; CheckFlagpoleCollision: Check if Mario touched the flagpole
; Returns: AL = 1 if touched, AL = 0 otherwise
; ------------------------------------------------------------
CheckFlagpoleCollision PROC USES ebx edi
    ; Skip if already touched
    cmp flagTouched, 1
    je AlreadyTouched
    
    ; Calculate Mario's world X
    mov eax, currentPage
    mov ebx, PAGE_WIDTH
    mul ebx
    mov edi, eax                         ; pageOffset
    
    movzx ebx, playerX
    add ebx, edi                         ; Mario world X
    
    ; Check if Mario's X is at flagpole (within 1 tile)
    movzx eax, flagpoleX
    sub eax, ebx
    
    ; Get absolute difference
    cmp eax, 0
    jge CheckFlagXPositive
    neg eax
CheckFlagXPositive:
    cmp eax, 1                           ; Within 1 tile?
    ja FlagNotTouched
    
    ; Check Y - Mario must be between flag top and bottom
    mov al, playerY
    cmp al, flagpoleTopY
    jb FlagNotTouched
    cmp al, flagpoleBottomY
    ja FlagNotTouched
    
    ; Flagpole touched!
    mov flagTouched, 1
    mov al, 1
    ret
    
AlreadyTouched:
FlagNotTouched:
    mov al, 0
    ret
CheckFlagpoleCollision ENDP

; ------------------------------------------------------------
; RunLevelCompleteSequence: Handle level completion animation
; Mario slides down the pole, bonus awarded, message shown
; ------------------------------------------------------------
RunLevelCompleteSequence PROC USES eax ebx ecx edx
    ; Set game state
    mov gameState, STATE_LEVEL_COMPLETE
    
    ; Initialize slide position
    mov al, playerY
    mov flagSlideY, al
    
    ; Slide Mario down the flagpole
SlideLoop:
    ; Erase Mario at current position
    call ErasePlayer
    
    ; Move Mario down
    inc flagSlideY
    mov al, flagSlideY
    mov playerY, al
    mov oldPlayerY, al
    
    ; Draw Mario at new position
    call DrawPlayer
    
    ; Delay for animation
    mov eax, 50
    call Delay
    
    ; Check if reached bottom
    mov al, flagSlideY
    cmp al, flagpoleBottomY
    jb SlideLoop
    
    ; Award bonus points (hook into existing score system)
    mov eax, score
    add eax, LEVEL_BONUS
    mov score, eax
    
    ; Update high score if needed
    cmp eax, highScore
    jbe SkipLevelHighScore
    mov highScore, eax
SkipLevelHighScore:
    
    ; Update HUD
    call DrawHUD
    
    ; Show level complete message
    mov eax, 14 + (2 * 16)               ; Yellow on green background
    call SetTextColor
    
    mov dh, 9
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET strLevelComplete1
    call WriteString
    
    mov dh, 10
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET strLevelComplete2
    call WriteString
    
    mov dh, 11
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET strLevelComplete3
    call WriteString
    
    mov dh, 12
    mov dl, 40
    call Gotoxy
    mov edx, OFFSET strLevelComplete4
    call WriteString
    
    ; Wait a moment
    mov eax, 3000
    call Delay
    
    ret
RunLevelCompleteSequence ENDP

; ============================================================
; CORE GAME LOOP
; ============================================================
RunGame PROC
    ; ------------------------------------------------------------------------
    ; GAME INITIALIZATION
    ; ------------------------------------------------------------------------
    
    ; Initialize player position
    mov  playerX, 10           
    mov  playerY, PLAY_MAX_Y
    mov  oldPlayerX, 10
    mov  oldPlayerY, PLAY_MAX_Y
    mov  marioPrevY, PLAY_MAX_Y          ; Initialize for stomp detection
    mov  velY, 0
    mov  onGround, 1           
    
    ; Reset power state
    mov  powerState, POWER_SMALL
    mov  powerUpTimer, 0
    
    ; Reset score and coins for new game
    mov  score, 0
    mov  coins, 0
    
    ; Initialize game state
    mov  gameState, STATE_PLAYING
    mov  flagTouched, 0
    call PlayLevel1Music
    
    ; Initialize life system
    call InitPlayerLives
    
    ; Initialize coin positions (disabled - no pre-placed coins)
    call InitCoins
    
    ; Initialize brick blocks (NES Mario style brown platforms)
    call InitBricks
    
    ; Initialize question blocks (NES Mario style ? blocks)
    call InitQuestionBlocks
    
    ; Initialize coin pop animations
    call InitCoinAnimations
    
    ; Initialize mushroom system
    call InitMushrooms
    
    ; Initialize goombas
    call InitGoombas
    
    ; Initialize koopas
    call InitKoopas
    
    ; Initialize page at level start
    mov currentPage, 0

    ; Draw initial screen with all elements
    call DrawInitialScreen
    call DrawGoombas                      ; Draw enemies on initial page
    call DrawKoopas                       ; Draw koopas on initial page
    call DrawMushrooms                    ; Draw any active mushrooms
    call DrawPlayer                       ; Draw Mario
    call DrawHUD                          ; Draw HUD

GameLoop:
    ; ------------------------------------------------------------------------
    ; CHECK GAME STATE - Handle different states
    ; ------------------------------------------------------------------------
    
    ; Check if game over
    cmp  gameState, STATE_GAME_OVER
    je   HandleGameOverState
    
    ; Check if level complete
    cmp  gameState, STATE_LEVEL_COMPLETE
    je   HandleLevelCompleteState
    
    ; Check if player dying
    cmp  gameState, STATE_PLAYER_DYING
    je   HandleDyingState
    
    ; Normal playing state continues below
    jmp  NormalGameFrame
    
HandleGameOverState:
    call ShowGameOverScreen
    jmp  ExitGame
    
HandleLevelCompleteState:
    call RunLevelCompleteSequence
    mov  currentLevel, 2                 ; Force Level 2 after finishing Level 1
    mov  level2ResetFlag, 0              ; Keep score/coins when coming from Level 1
    call RunGameLevel2
    jmp  ExitGame
    
HandleDyingState:
    ; Death is handled in HandlePlayerDeath
    jmp  ExitGame
    
NormalGameFrame:
    mov  eax, 33       ; 30 FPS (33ms)
    call Delay

    ; Tick down temporary power-up protection timer
    cmp  powerUpTimer, 0
    jle  SkipPowerTimer
    dec  powerUpTimer
SkipPowerTimer:

    ; ==========================================================================
    ; SAVE MARIO'S PREVIOUS Y - Required for proper stomp detection
    ; Must be done BEFORE physics update each frame
    ; ==========================================================================
    mov  al, playerY
    mov  marioPrevY, al

    ; --- GRAVITY / JUMP PHYSICS ---
    mov  al, velY
    add  al, GRAVITY
    mov  velY, al

    cmp  al, 0
    je   InputCheck
    jg   MovingDown
    jl   MovingUp

MovingUp:
    neg  al
    movzx ecx, al      
StepUpLoop:
    dec  playerY
    mov  al, playerX
    mov  ah, playerY
    call IsWallOrGround
    cmp  al, 1
    je   HitHead
    
    ; Also check platforms (make them solid, block from below too)
    mov  al, playerX
    mov  ah, playerY
    call IsPlatform
    cmp  al, 1
    je   HitHead
    
    ; Check question blocks (they are solid obstacles)
    mov  al, playerX
    mov  ah, playerY
    call IsQuestionBlock
    cmp  al, 1
    je   HitHead
    
    ; Check brick blocks (solid obstacles)
    mov  al, playerX
    mov  ah, playerY
    call IsBrick
    cmp  al, 1
    je   HitHead
    
    loop StepUpLoop
    jmp  InputCheck

HitHead:
    ; Before stopping, check if we hit a question block
    ; If so, award coin and trigger animation
    mov  al, playerX
    mov  ah, playerY
    call CheckQuestionBlockHit
    ; Continue regardless of result - head still hit something
    
    inc  playerY       
    mov  velY, 0
    jmp  InputCheck

MovingDown:
    movzx ecx, al      
StepDownLoop:
    inc  playerY
    
    ; 1. Check Ground/Pipes
    mov  al, playerX
    mov  ah, playerY
    call IsWallOrGround
    cmp  al, 1
    je   Land
    
    ; 2. Check Platforms (One-way)
    mov  al, playerX
    mov  ah, playerY
    call IsPlatform
    cmp  al, 1
    je   Land

    loop StepDownLoop
    mov  onGround, 0   
    jmp  InputCheck

Land:
    dec  playerY       
    mov  velY, 0
    mov  onGround, 1
    jmp  InputCheck

    ; --- INPUT HANDLING ---
InputCheck:
    ; ------------------------------------------------------------------------
    ; COLLISION CHECKS (every frame)
    ; ------------------------------------------------------------------------
    
    ; Check for coin collisions
    call CheckCoinCollisions
    
    ; Check for mushroom pickups (power-ups)
    call HandleMarioMushroomCollision
    
    ; Check for flagpole collision (level complete)
    call CheckFlagpoleCollision
    cmp  al, 1
    je   TriggerLevelComplete
    
    ; Check for goomba collisions
    call HandleMarioGoombaCollision
    cmp  al, 1
    jne  AfterGoombaDamage
    call ApplyMarioDamage
    cmp  al, 1
    je   TriggerPlayerDeath
AfterGoombaDamage:
    
    ; Check for koopa collisions
    call HandleMarioKoopaCollision
    cmp  al, 1
    jne  AfterKoopaDamage
    call ApplyMarioDamage
    cmp  al, 1
    je   TriggerPlayerDeath
AfterKoopaDamage:
    
    ; Check other death conditions (falling off screen, etc.)
    call CheckPlayerDeathConditions
    cmp  al, 1
    je   TriggerPlayerDeath
    
    ; ------------------------------------------------------------------------
    ; UPDATE ENEMIES AND ANIMATIONS (logic only)
    ; ------------------------------------------------------------------------
    call EraseGoombas                     ; Clear goombas at old positions
    call EraseKoopas                      ; Clear koopas at old positions
    call EraseMushrooms                   ; Clear mushrooms at old positions
    call EraseCoinAnimations              ; Clear coin pops at old positions
    call UpdateGoombas                    ; Update enemy positions/states
    call UpdateKoopas                     ; Update koopa positions/states
    call UpdateMushrooms                  ; Update mushroom movement/gravity
    call UpdateCoinAnimations             ; Update coin pop movement/timers
    
    jmp  ProcessInput
    
TriggerLevelComplete:
    mov  gameState, STATE_LEVEL_COMPLETE
    jmp  LoopEnd
    
TriggerPlayerDeath:
    call HandlePlayerDeath
    jmp  LoopEnd
    
ProcessInput:
    call ReadKey       
    jz   NoKeyPressed         

    cmp  al, 'p'
    jne  CheckP2
    jmp  DoPause
CheckP2:
    cmp  al, 'P'
    jne  CheckX1
    jmp  DoPause
CheckX1:
    cmp  al, 'x'
    jne  CheckX2
    jmp  ExitGame
CheckX2:
    cmp  al, 'X'
    jne  CheckW1
    jmp  ExitGame
CheckW1:
    cmp  al, 'w'
    jne  CheckW2
    jmp  DoJump
CheckW2:
    cmp  al, 'W'
    jne  CheckUp
    jmp  DoJump
CheckUp:
    cmp  ah, 48h       
    jne  CheckA1
    jmp  DoJump
CheckA1:
    cmp  al, 'a'
    jne  CheckA2
    jmp  DoLeft
CheckA2:
    cmp  al, 'A'
    jne  CheckLeft
    jmp  DoLeft
CheckLeft:
    cmp  ah, 4Bh       
    jne  CheckD1
    jmp  DoLeft
CheckD1:
    cmp  al, 'd'
    jne  CheckD2
    jmp  DoRight
CheckD2:
    cmp  al, 'D'
    jne  CheckRight
    jmp  DoRight
CheckRight:
    cmp  ah, 4Dh       
    jne  NoKeyPressed
    jmp  DoRight
    
NoKeyPressed:
    jmp  NoKey

DoPause:
    ; Draw pause text with white on sky blue background (no black box)
    mov eax, 15 + (9 * 16)  ; White text on light blue background
    call SetTextColor
    mov dh, 10
    mov dl, 44
    call Gotoxy
    mov edx, OFFSET pauseLine1
    call WriteString
    mov dh, 11
    mov dl, 44
    call Gotoxy
    mov edx, OFFSET pauseLine2
    call WriteString

    ; --- ADD THIS BLOCK ---
    mov dh, 12
    mov dl, 44
    call Gotoxy
    mov edx, OFFSET pauseSaveOpt  ; Show "S - Save Game"
    call WriteString
    ; ------


PauseInputLoop:
    call ReadChar  
    cmp al, 'r'     
    je  ResumeGame
    cmp al, 'R'
    je  ResumeGame
    cmp al, 'x'     
    je  ExitGame
    cmp al, 'X'
    je  ExitGame
    ; --- ADD THIS BLOCK ---
    cmp al, 's'
    je  SaveGameAction
    cmp al, 'S'
    je  SaveGameAction
    ; ----------------------
    jmp PauseInputLoop


    ; --- ADD THIS BLOCK AFTER PauseInputLoop ---
    SaveGameAction:
    call SaveGameData
    jmp ResumeGame

ResumeGame:
    ; Just erase the pause text with sky blue and continue
    mov eax, GP_BG
    call SetTextColor
    mov dh, 10
    mov dl, 44
    call Gotoxy
    mov ecx, 30  ; Length of pauseLine1
ErasePauseLine1:
    mov al, ' '
    call WriteChar
    loop ErasePauseLine1
    
    mov dh, 11
    mov dl, 44
    call Gotoxy
    mov ecx, 30  ; Length of pauseLine2
ErasePauseLine2:
    mov al, ' '
    call WriteChar
    loop ErasePauseLine2
    
    ; Redraw all game elements in case pause text overlapped them
    call DrawPipes
    call DrawPlatforms
    call DrawBricks
    call DrawQuestionBlocks
    call DrawFlagpole
    call DrawGoombas
    call DrawKoopas
    call DrawMushrooms
    call DrawCoinAnimations
    call DrawPlayer
    
    jmp  GameLoop

DoJump:
    cmp  onGround, 1
    jne  SkipJump
    mov  velY, JUMP_FORCE
    mov  onGround, 0
    call PlayJumpSound
SkipJump:
    jmp  NoKeyPressed

DoLeft:
    mov  al, playerX
    cmp  al, 0  ; At left edge of current page?
    ja   NormalMoveLeft
    
    ; At edge - check if can go to previous page
    cmp currentPage, 0
    je SkipLeft  ; Already at first page
    
    ; Load previous page
    dec currentPage
    mov playerX, SCREEN_MAX_X  ; Place Mario at right edge of previous page
    mov pageTransition, 1  ; Flag to redraw entire screen
    jmp SkipLeft
    
NormalMoveLeft:
    dec  al
    mov  ah, playerY
    call IsWallOrGround 
    cmp  al, 1
    je   SkipLeft
    dec  playerX
    
SkipLeft:
    jmp  NoKeyPressed

DoRight:
    mov  al, playerX
    cmp  al, SCREEN_MAX_X  ; At right edge of current page?
    jb   NormalMoveRight
    
    ; At edge - check if can go to next page
    mov eax, currentPage
    cmp eax, maxPages
    jae SkipRight  ; Already at last page
    
    ; Load next page
    inc currentPage
    mov playerX, 0  ; Place Mario at left edge of new page
    mov pageTransition, 1  ; Flag to redraw entire screen
    jmp SkipRight
    
NormalMoveRight:
    inc  al
    mov  ah, playerY
    call IsWallOrGround 
    cmp  al, 1
    je   SkipRight
    inc  playerX
    
SkipRight:
    jmp  NoKeyPressed

NoKey:
    ; Check if page transition occurred
    cmp pageTransition, 1
    jne CheckPlayerMoved
    
    ; Page transition - redraw entire screen
    mov pageTransition, 0
    call DrawInitialScreen                ; Draws everything including bricks & qblocks
    call DrawGoombas                      ; Draw enemies on new page
    call DrawKoopas                       ; Draw koopas on new page
    call DrawMushrooms                    ; Draw mushrooms visible on page
    call DrawCoinAnimations               ; Draw any active coin pop animations on top
    call DrawPlayer
    call DrawHUD
    
    mov  al, playerX
    mov  oldPlayerX, al
    mov  al, playerY
    mov  oldPlayerY, al
    jmp  LoopEnd

CheckPlayerMoved:
    ; Check if Mario moved
    mov  al, playerX
    cmp  al, oldPlayerX 
    jne  DoRedraw
    mov  al, playerY
    cmp  al, oldPlayerY
    jne  DoRedraw
    jmp  DrawEntities

DoRedraw:
    call ErasePlayer
    mov  al, playerX
    mov  oldPlayerX, al
    mov  al, playerY
    mov  oldPlayerY, al
    call DrawPlayer
    jmp  DrawEntities

DrawEntities:
    ; Draw enemies and coin animations once per frame (after Mario)
    call DrawGoombas
    call DrawKoopas
    call DrawMushrooms
    call DrawCoinAnimations

LoopEnd:
    jmp  GameLoop

ExitGame:
    call StopAllSounds
    ret
RunGame ENDP


; ------------------------------------------------------------
; LEVEL 2 PLACEHOLDER LOOP (black background, minimal logic)
; ------------------------------------------------------------
RunGameLevel2 PROC
    mov currentLevel, 2
    mov currentPage, 0
    mov pageTransition, 0
    mov flagTouched, 0
    mov gameState, STATE_PLAYING

    ; Start at left side above ground
    mov playerX, 10
    mov playerY, PLAY_MAX_Y
    mov oldPlayerX, 10
    mov oldPlayerY, PLAY_MAX_Y
    mov marioPrevY, PLAY_MAX_Y
    mov velY, 0
    mov onGround, 1
    ; Level 2 respawn point (start of castle)
    mov respawnX, 10
    mov respawnY, PLAY_MAX_Y
    mov respawnPage, 0

    ; If Level 2 started directly (not from Level 1), reset score/coins
    cmp level2ResetFlag, 1
    jne SkipL2Reset
    mov score, 0
    mov coins, 0
    mov level2ResetFlag, 0
SkipL2Reset:

    ; Clear to black for placeholder Level 2
    mov eax, GP_HUD_BG
    call SetTextColor
    call Clrscr

    ; Build and draw castle once
    call InitCastleLevelMap
    call InitFirebar
    call InitBowser
    call DrawLevel2
    call DrawBowser
    call DrawBowserFireballs
    call DrawHUD
    call DrawPlayer
    mov al, playerX
    mov oldPlayerX, al
    mov al, playerY
    mov oldPlayerY, al

Level2Loop:
    mov eax, 33
    call Delay

    ; Erase Mario at old position using castle tiles
    call Level2ErasePlayer
    ; Erase firebar at old positions
    call EraseFirebar
    ; Erase Bowser at old position
    call EraseBowser

    ; --- GRAVITY / JUMP PHYSICS (mirrors Level 1) ---
    mov  al, velY
    add  al, GRAVITY
    mov  velY, al

    cmp  al, 0
    je   L2_InputCheck
    jg   L2_MovingDown
    jl   L2_MovingUp

L2_MovingUp:
    neg  al
    movzx ecx, al
L2_StepUpLoop:
    dec  playerY
    mov  al, playerX
    mov  ah, playerY
    call IsWallOrGround
    cmp  al, 1
    je   L2_HitHead

    mov  al, playerX
    mov  ah, playerY
    call IsPlatform
    cmp  al, 1
    je   L2_HitHead

    loop L2_StepUpLoop
    jmp  L2_InputCheck

L2_HitHead:
    inc  playerY
    mov  velY, 0
    jmp  L2_InputCheck

L2_MovingDown:
    movzx ecx, al
L2_StepDownLoop:
    inc  playerY

    mov  al, playerX
    mov  ah, playerY
    call IsWallOrGround
    cmp  al, 1
    je   L2_Land

    mov  al, playerX
    mov  ah, playerY
    call IsPlatform
    cmp  al, 1
    je   L2_Land

    loop L2_StepDownLoop
    mov  onGround, 0
    jmp  L2_InputCheck

L2_Land:
    dec  playerY
    mov  velY, 0
    mov  onGround, 1
    jmp  L2_InputCheck

L2_InputCheck:
    call ReadKey
    jz   L2_NoKeyPressed

    ; Exit with X
    cmp  al, 'x'
    je   ExitLevel2
    cmp  al, 'X'
    je   ExitLevel2

    ; Jump: W or Up arrow
    cmp  al, 'w'
    je   L2_DoJump
    cmp  al, 'W'
    je   L2_DoJump
    cmp  ah, 48h
    je   L2_DoJump

    ; Left: A or Left arrow
    cmp  al, 'a'
    je   L2_DoLeft
    cmp  al, 'A'
    je   L2_DoLeft
    cmp  ah, 4Bh
    je   L2_DoLeft

    ; Right: D or Right arrow
    cmp  al, 'd'
    je   L2_DoRight
    cmp  al, 'D'
    je   L2_DoRight
    cmp  ah, 4Dh
    je   L2_DoRight

    jmp  L2_NoKeyPressed

L2_DoJump:
    cmp  onGround, 1
    jne  L2_NoKeyPressed
    mov  velY, JUMP_FORCE_L2
    mov  onGround, 0
    call PlayJumpSound
    jmp  L2_NoKeyPressed

L2_DoLeft:
    mov  al, playerX
    cmp  currentLevel, 2
    jne  L2_MoveLeft
    cmp  al, 1
    ja   L2_MoveLeft
    ; Level 2: page back if available
    cmp currentPage, 0
    je   L2_NoKeyPressed
    dec currentPage
    mov playerX, SCREEN_MAX_X-1
    mov pageTransition, 1
    jmp  L2_NoKeyPressed
L2_MoveLeft:
    dec  al
    mov  ah, playerY
    call IsWallOrGround
    cmp  al, 1
    je   L2_NoKeyPressed
    dec  playerX
    jmp  L2_NoKeyPressed

L2_DoRight:
    mov  al, playerX
    cmp  currentLevel, 2
    jne  L2_MoveRight
    cmp  al, SCREEN_MAX_X-1
    jb   L2_MoveRight
    ; Level 2: page forward if available
    mov   eax, currentPage
    cmp   eax, LEVEL2_MAX_PAGES-1
    jae   L2_NoKeyPressed
    inc currentPage
    mov playerX, 1
    mov pageTransition, 1
    jmp  L2_NoKeyPressed
L2_MoveRight:
    inc  al
    mov  ah, playerY
    call IsWallOrGround
    cmp  al, 1
    je   L2_NoKeyPressed
    inc  playerX
    jmp  L2_NoKeyPressed

L2_NoKeyPressed:

    ; Handle Level 2 page transition redraw
    cmp pageTransition, 1
    jne L2_NoPageTransition
    mov pageTransition, 0
    call Clrscr
    call DrawLevel2
    call DrawFirebar
    call DrawBowser
    call DrawBowserFireballs
    call DrawHUD
    call DrawPlayer
    mov al, playerX
    mov oldPlayerX, al
    mov al, playerY
    mov oldPlayerY, al
    jmp Level2Loop
L2_NoPageTransition:

    ; Death checks (lava handled inside CheckPlayerDeathConditions)
    call CheckPlayerDeathConditions
    cmp  al, 1
    je   L2_Death

    ; Update firebar and check collision
    call UpdateFirebar
    call UpdateBowser
    call UpdateBowserFireballs
    cmp al, 1
    je  L2_Death
    call CheckFirebarCollision
    cmp al, 1
    je  L2_Death

    ; Redraw player (map and HUD are static)
    call DrawBowser
    call DrawBowserFireballs
    call DrawFirebar
    call DrawPlayer
    mov  al, playerX
    mov  oldPlayerX, al
    mov  al, playerY
    mov  oldPlayerY, al

    jmp  Level2Loop

L2_Death:
    ; Custom level-2 death handling to avoid Level 1 reset
    dec  lives
    cmp  lives, 0
    jne  L2_Respawn

    ; Game over: show screen then return to menu
    mov  gameState, STATE_GAME_OVER
    call ShowGameOverScreen
    ret

L2_Respawn:
    mov  gameState, STATE_PLAYING
    mov  flagTouched, 0
    mov  velY, 0
    mov  onGround, 1

    ; Restore respawn point (already set for Level 2)
    mov  al, respawnX
    mov  playerX, al
    mov  oldPlayerX, al
    mov  al, respawnY
    mov  playerY, al
    mov  oldPlayerY, al
    mov  marioPrevY, al
    mov  eax, respawnPage
    mov  currentPage, eax
    mov  pageTransition, 0

    ; Redraw castle and HUD
    mov  eax, GP_HUD_BG
    call SetTextColor
    call Clrscr
    call InitCastleLevelMap
    call InitFirebar
    call InitBowser
    call DrawLevel2
    call DrawBowser
    call DrawBowserFireballs
    call DrawHUD
    call DrawPlayer

    jmp Level2Loop

ExitLevel2:
    call StopAllSounds
    ret
RunGameLevel2 ENDP

; ------------------------------------------------------------
; UpdateLevel2: placeholder (no-op for now)
; ------------------------------------------------------------
UpdateLevel2 PROC
    ret
UpdateLevel2 ENDP

; ------------------------------------------------------------
; InitCastleLevelMap: build static castle layout
; ------------------------------------------------------------
InitCastleLevelMap PROC USES eax ebx ecx edx esi edi
    ; Fill with empty
    mov ecx, LEVEL2_ROWS * LEVEL2_COLS
    mov esi, OFFSET CastleLevelMap
    mov al, TILE_EMPTY
FillL2:
    mov [esi], al
    inc esi
    loop FillL2

    ; Helpers: row stride = LEVEL2_COLS
    ; Set ceiling row to WALL
    mov ecx, LEVEL2_COLS
    mov esi, OFFSET CastleLevelMap
    mov al, TILE_WALL
FillTop:
    mov [esi], al
    inc esi
    loop FillTop

    ; Left/right walls every row
    mov ecx, LEVEL2_ROWS
    mov ebx, 0                        ; row index
WallsLoop:
    ; left wall at col 0
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    mov BYTE PTR [esi], TILE_WALL

    ; right wall at col = LEVEL2_COLS-1
    mov edi, ebx
    imul edi, LEVEL2_COLS
    add edi, OFFSET CastleLevelMap
    add edi, LEVEL2_COLS
    dec edi
    mov BYTE PTR [edi], TILE_WALL

    inc ebx
    loop WallsLoop

    ; Lava strip at bottom row (row = LEVEL2_ROWS-1)
    mov ebx, LEVEL2_ROWS
    dec ebx                             ; bottom row index
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    mov ecx, LEVEL2_COLS
    mov al, TILE_LAVA
FillLava:
    mov [esi], al
    inc esi
    loop FillLava

    ; Bridge row just above lava (row = LEVEL2_BRIDGE_ROW), with smaller pits
    mov ebx, LEVEL2_BRIDGE_ROW
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    mov ecx, LEVEL2_COLS
    mov al, TILE_BRIDGE
FillBridge:
    mov [esi], al
    inc esi
    loop FillBridge

    ; Carve pits (gaps) in bridge to expose lava (small gaps)
    ; Gap 1: cols 30-33
    mov esi, LEVEL2_BRIDGE_ROW
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 30
    mov ecx, 4
    mov al, TILE_EMPTY
ClearGap1:
    mov [esi], al
    inc esi
    loop ClearGap1

    ; Gap 2: cols 65-68
    mov esi, LEVEL2_BRIDGE_ROW
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 65
    mov ecx, 4
    mov al, TILE_EMPTY
ClearGap2:
    mov [esi], al
    inc esi
    loop ClearGap2

    ; Gap 3: cols 95-98
    mov esi, LEVEL2_BRIDGE_ROW
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 95
    mov ecx, 4
    mov al, TILE_EMPTY
ClearGap3:
    mov [esi], al
    inc esi
    loop ClearGap3

    ; Floating platform: small span near center on row = LEVEL2_ROWS-8
    mov ebx, LEVEL2_ROWS
    sub ebx, 8
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 56                         ; start col ~56
    mov ecx, 8                          ; 8 tiles wide
    mov al, TILE_PLATFORM
FillPlat:
    mov [esi], al
    inc esi
    loop FillPlat

    ; Extra dark gray platforms (stepping stones)
    ; Platform 2: row LEVEL2_ROWS-10, cols 20-30
    mov ebx, LEVEL2_ROWS
    sub ebx, 10
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 20
    mov ecx, 11
    mov al, TILE_PLATFORM
FillPlat2:
    mov [esi], al
    inc esi
    loop FillPlat2

    ; Platform 3: row LEVEL2_ROWS-12, cols 80-90
    mov ebx, LEVEL2_ROWS
    sub ebx, 12
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 80
    mov ecx, 11
    mov al, TILE_PLATFORM
FillPlat3:
    mov [esi], al
    inc esi
    loop FillPlat3

    ; Platforms above pits to aid crossing
    ; Above gap 1
    mov ebx, LEVEL2_BRIDGE_ROW
    sub ebx, 4
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 28
    mov ecx, 10
    mov al, TILE_PLATFORM
FillPlatGap1:
    mov [esi], al
    inc esi
    loop FillPlatGap1

    ; Above gap 2
    mov ebx, LEVEL2_BRIDGE_ROW
    sub ebx, 4
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 63
    mov ecx, 10
    mov al, TILE_PLATFORM
FillPlatGap2:
    mov [esi], al
    inc esi
    loop FillPlatGap2

    ; Above gap 3
    mov ebx, LEVEL2_BRIDGE_ROW
    sub ebx, 4
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 93
    mov ecx, 10
    mov al, TILE_PLATFORM
FillPlatGap3:
    mov [esi], al
    inc esi
    loop FillPlatGap3

    ; Platform 4: row LEVEL2_ROWS-6, cols 40-50
    mov ebx, LEVEL2_ROWS
    sub ebx, 6
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 40
    mov ecx, 11
    mov al, TILE_PLATFORM
FillPlat4:
    mov [esi], al
    inc esi
    loop FillPlat4

    ; Platform 5: row LEVEL2_ROWS-14, cols 100-112
    mov ebx, LEVEL2_ROWS
    sub ebx, 14
    mov esi, ebx
    imul esi, LEVEL2_COLS
    add esi, OFFSET CastleLevelMap
    add esi, 100
    mov ecx, 13
    mov al, TILE_PLATFORM
FillPlat5:
    mov [esi], al
    inc esi
    loop FillPlat5

    ret
InitCastleLevelMap ENDP

; ------------------------------------------------------------
; DrawLevel2: draw static castle room using CastleLevelMap
; ------------------------------------------------------------
DrawLevel2 PROC
    ; Clear to black
    mov eax, GP_CASTLE_BG
    call SetTextColor
    call Clrscr

    mov esi, 0                  ; index into map
    mov dh, 0                   ; row counter

DrawL2Row:
    cmp dh, LEVEL2_ROWS
    jge DrawL2Done
    mov dl, 0                   ; column

DrawL2Col:
    cmp dl, LEVEL2_COLS
    jge NextL2Row

    ; Tile = CastleLevelMap[esi]
    mov al, CastleLevelMap[esi]

    push eax
    push edx

    ; Position cursor for this tile
    push dx
    call Gotoxy
    pop dx

    ; Set color by tile
    cmp al, TILE_WALL
    je L2Wall
    cmp al, TILE_LAVA
    je L2Lava
    cmp al, TILE_BRIDGE
    je L2Bridge
    cmp al, TILE_PLATFORM
    je L2Plat
    jmp L2SkipDraw              ; empty

L2Wall:
    mov eax, GP_CASTLE_WALL
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp L2Drawn

L2Lava:
    mov eax, GP_CASTLE_LAVA
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp L2Drawn

L2Bridge:
    mov eax, GP_CASTLE_BRIDGE
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp L2Drawn

L2Plat:
    mov eax, GP_CASTLE_PLAT
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp L2Drawn

L2SkipDraw:
    ; Nothing for empty tiles (already cleared)
    jmp L2AfterTile

L2Drawn:
    ; cursor is already at correct spot due to WriteChar

L2AfterTile:
    pop edx
    pop eax

    ; advance cursor
    inc dl
    inc esi
    jmp DrawL2Col

NextL2Row:
    inc dh
    jmp DrawL2Row

DrawL2Done:
    ret
DrawLevel2 ENDP


; ====================================================================================
; FILE HANDLING PROCEDURES
; ====================================================================================

InputPlayerName PROC USES eax edx ecx
    call Clrscr
    mov dh, 12
    mov dl, 30
    call Gotoxy
    
    mov eax, 14 + (0 * 16) ; Yellow text
    call SetTextColor
    
    mov edx, OFFSET strEnterName
    call WriteString
    
    ; Read string input
    mov edx, OFFSET playerName
    mov ecx, 31        ; Max length
    call ReadString
    ret
InputPlayerName ENDP

SaveGameData PROC USES eax ecx edx
    ; 1. Create File
    mov edx, OFFSET saveFilename
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je SaveFail
    mov fileHandle, eax

    ; 2. Store Player Name (32 bytes)
    mov edx, OFFSET playerName
    mov ecx, 32
    mov eax, fileHandle
    call WriteToFile

    ; 3. Store High Score (4 bytes)
    mov edx, OFFSET highScore
    mov ecx, 4
    mov eax, fileHandle
    call WriteToFile

    ; 4. Store Level Progress (Score, Lives, Coins, Page)
    mov edx, OFFSET score
    mov ecx, 4
    mov eax, fileHandle
    call WriteToFile
    
    mov edx, OFFSET lives
    mov ecx, 1
    mov eax, fileHandle
    call WriteToFile
    
    mov edx, OFFSET coins
    mov ecx, 1
    mov eax, fileHandle
    call WriteToFile
    
    mov edx, OFFSET currentPage
    mov ecx, 4
    mov eax, fileHandle
    call WriteToFile

    ; 5. Close File
    mov eax, fileHandle
    call CloseFile
    
    ; Show Success
    mov dh, 13
    mov dl, 44
    call Gotoxy
    mov edx, OFFSET msgSaved
    call WriteString
    mov eax, 1000
    call Delay
    ret

SaveFail:
    mov dh, 13
    mov dl, 44
    call Gotoxy
    mov edx, OFFSET msgErr
    call WriteString
    mov eax, 1000
    call Delay
    ret
SaveGameData ENDP

LoadGameData PROC USES eax ecx edx
    ; 1. Open File
    mov edx, OFFSET saveFilename
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NoLoadFile      ; File doesn't exist yet, just return
    mov fileHandle, eax

    ; 2. Read Player Name
    mov edx, OFFSET playerName
    mov ecx, 32
    mov eax, fileHandle
    call ReadFromFile

    ; 3. Read High Score
    mov edx, OFFSET highScore
    mov ecx, 4
    mov eax, fileHandle
    call ReadFromFile

    ; 4. Read Level Progress
    mov edx, OFFSET score
    mov ecx, 4
    mov eax, fileHandle
    call ReadFromFile
    
    mov edx, OFFSET lives
    mov ecx, 1
    mov eax, fileHandle
    call ReadFromFile
    
    mov edx, OFFSET coins
    mov ecx, 1
    mov eax, fileHandle
    call ReadFromFile
    
    mov edx, OFFSET currentPage
    mov ecx, 4
    mov eax, fileHandle
    call ReadFromFile

    ; 5. Close File
    mov eax, fileHandle
    call CloseFile

NoLoadFile:
    ret
LoadGameData ENDP

END main