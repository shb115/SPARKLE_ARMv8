
.arch armv8-a

.text

///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

// register sptr holds the start address of array 'state'
// x0
// register step holds the number of steps (parameter 'steps')
// x1
// registers c0w to c7w hold round constants from array 'rcon'
c0w  .req w19
c1w  .req w20
c2w  .req w21
c3w  .req w22
c4w  .req w23
c5w  .req w24
c6w  .req w25
c7w  .req w26
// registers tmpx, tmpy, tmp hold temporary values
tmpx .req w1
tmpy .req w2
tmp  .req w1
// registers x0w to y3w hold 8 words from array 'state'
x0w  .req w3
y0w  .req w4
x1w  .req w5
y1w  .req w6
x2w  .req w7
y2w  .req w8
x3w  .req w9
y3w  .req w10

///////////////////////////////////////////////////////////////////////////////
//////////////////////////// MACROS FOR SPARKLE256 ////////////////////////////
///////////////////////////////////////////////////////////////////////////////

.macro ARX_BOX xi:req, yi:req, ci:req     
    ror     tmp, \yi, #31
    add     \xi, \xi, tmp 
    eor     \yi, \yi, \xi, ror #24    
    eor     \xi, \xi, \ci    
    ror     tmp, \yi, #17
    add     \xi, \xi, tmp    
    eor     \yi, \yi, \xi, ror #17
    eor     \xi, \xi, \ci
    add     \xi, \xi, \yi
    eor     \yi, \yi, \xi, ror #31
    eor     \xi, \xi, \ci
    ror     tmp, \yi, #24
    add     \xi, \xi, tmp
    eor     \yi, \yi, \xi, ror #16
    eor     \xi, \xi, \ci     
.endm

.macro LL_TMPX xi:req, xj:req
    eor     tmpx, \xi, \xj
    eor     tmpx, tmpx, tmpx, lsl #16
.endm
    
.macro LL_TMPY yi:req, yj:req
    eor     tmpy, \yi, \yj
    eor     tmpy, tmpy, tmpy, lsl #16
.endm
    
.macro LL_ADDX xi:req, xj:req
    eor     \xi, \xi, tmpy, ror #16
    eor     \xi, \xi, \xj
.endm
    
.macro LL_ADDY yi:req, yj:req
    eor     \yi, \yi, tmpx, ror #16
    eor     \yi, \yi, \yj
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 0 OF SPARKLE256 (USING ROUND-CONSTANT RC0) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_00_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC0
    eor     \y0, \y0, c0w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w     
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1 
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 1 OF SPARKLE256 (USING ROUND-CONSTANT RC1) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_01_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC1
    eor    \y1, \y1, #1
    eor    \y0, \y0, c1w
    
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w    
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 2 OF SPARKLE256 (USING ROUND-CONSTANT RC2) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_02_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC2
    eor    \y1, \y1, #2
    eor    \y0, \y0, c2w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 3 OF SPARKLE256 (USING ROUND-CONSTANT RC3) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_03_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC3
    eor    \y1, \y1, #3
    eor    \y0, \y0, c3w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 4 OF SPARKLE256 (USING ROUND-CONSTANT RC4) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_04_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC4
    eor    \y1, \y1, #4
    eor    \y0, \y0, c4w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 5 OF SPARKLE256 (USING ROUND-CONSTANT RC5) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_05_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC5
    eor     \y1, \y1, #4
    eor     \y1, \y1, #1
    eor     \y0, \y0, c5w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 6 OF SPARKLE256 (USING ROUND-CONSTANT RC6) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_06_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC6
    eor     \y1, \y1, #6
    eor     \y0, \y0, c6w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 7 OF SPARKLE256 (USING ROUND-CONSTANT RC7) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_07_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC7
    eor     \y1, \y1, #7
    eor     \y0, \y0, c7w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 8 OF SPARKLE256 (USING ROUND-CONSTANT RC0) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_08_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC0
    eor     \y1, \y1, #8
    eor     \y0, \y0, c0w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 9 OF SPARKLE256 (USING ROUND-CONSTANT RC1) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_09_256 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req
    // Addition RC1
    eor     \y1, \y1, #8
    eor     \y1, \y1, #1
    eor     \y0, \y0, c1w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    // Linear Layer
    LL_TMPX \x0, \x1
    LL_ADDY \y2, \y0
    LL_ADDY \y3, \y1
    LL_TMPY \y0, \y1
    LL_ADDX \x2, \x0
    LL_ADDX \x3, \x1
.endm


///////////////////////////////////////////////////////////////////////////////
/////////////////// SPARKLE256 PERMUTATION (FULLY UNROLLED) ///////////////////
///////////////////////////////////////////////////////////////////////////////

// Function prototype:
// -------------------
// void sparkle256_a64(uint32_t *state, int steps)
//
// Parameters:
// -----------
// state: pointer to an uint32_t-array containing the 8 state words
// steps: number of steps (must be either 7 or 10)
//
// Return value:
// -------------
// None

.type sparkle256_a64, %function
.global sparkle256_a64
sparkle256_a64:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

// codes start    
    ldp     w3,  w4, [x0], #8            //loading state     
    ldp     w5,  w6, [x0], #8
    ldp     w7,  w8, [x0], #8
    ldp     w9, w10, [x0]
    add     x0,  x0, #-24
   
// round constant    
    ldr     w19, =0xB7E15162
    ldr     w20, =0xBF715880
    ldr     w21, =0x38B4DA56
    ldr     w22, =0x324E7738
    ldr     w23, =0xBB1185EB     
    ldr     w24, =0x4F7C7B57    
    ldr     w25, =0xCFBFA1C8
    ldr     w26, =0xC2B3293D

    PERM_STEP_00_256 x0w, y0w, x1w, y1w, x2w, y2w, x3w, y3w
    PERM_STEP_01_256 x3w, y3w, x2w, y2w, x0w, y0w, x1w, y1w
    PERM_STEP_02_256 x1w, y1w, x0w, y0w, x3w, y3w, x2w, y2w
    PERM_STEP_03_256 x2w, y2w, x3w, y3w, x1w, y1w, x0w, y0w
    PERM_STEP_04_256 x0w, y0w, x1w, y1w, x2w, y2w, x3w, y3w
    PERM_STEP_05_256 x3w, y3w, x2w, y2w, x0w, y0w, x1w, y1w
    PERM_STEP_06_256 x1w, y1w, x0w, y0w, x3w, y3w, x2w, y2w

// return when the number of steps is slim
    cmp     x1, #7
    bgt     .Lbig_384
    stp     x1w, y1w, [x0], #8
    stp     x0w, y0w, [x0], #8
    stp     x3w, y3w, [x0], #8
    stp     x2w, y2w, [x0]

.Lbig_384:
    PERM_STEP_07_256 x2w, y2w, x3w, y3w, x1w, y1w, x0w, y0w
    PERM_STEP_08_256 x0w, y0w, x1w, y1w, x2w, y2w, x3w, y3w
    PERM_STEP_09_256 x3w, y3w, x2w, y2w, x0w, y0w, x1w, y1w
    
    stp     x1w, y1w, [x0], #8
    stp     x0w, y0w, [x0], #8
    stp     x3w, y3w, [x0], #8
    stp     x2w, y2w, [x0]

// codes end

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16

    ret
    .size sparkle256_a64, (. - sparkle256_a64)
