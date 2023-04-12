
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
// registers x0w to y5w hold 12 words from array 'state'
x0w  .req w3
y0w  .req w4
x1w  .req w5
y1w  .req w6
x2w  .req w7
y2w  .req w8
x3w  .req w9
y3w  .req w10
x4w  .req w11
y4w  .req w12
x5w  .req w13
y5w  .req w14

///////////////////////////////////////////////////////////////////////////////
//////////////////////////// MACROS FOR SPARKLE384 ////////////////////////////
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

.macro LL_TMPX xi:req, xj:req, xk:req
    eor     tmpx, \xi, \xj
    eor     tmpx, tmpx, \xk
    eor     tmpx, tmpx, tmpx, lsl #16
.endm
    
.macro LL_TMPY yi:req, yj:req, yk:req
    eor     tmpy, \yi, \yj
    eor     tmpy, tmpy, \yk
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
//// MACRO FOR PERMUTATION-STEP 0 OF SPARKLE384 (USING ROUND-CONSTANT RC0) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_00_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC0
    eor     \y0, \y0, c0w    
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w 
    ARX_BOX \x5, \y5, c5w        
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2       
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 1 OF SPARKLE384 (USING ROUND-CONSTANT RC1) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_01_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC1
    eor     \y1, \y1, #1
    eor     \y0, \y0, c1w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 2 OF SPARKLE384 (USING ROUND-CONSTANT RC2) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_02_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC2
    eor     \y1, \y1, #2
    eor     \y0, \y0, c2w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 3 OF SPARKLE384 (USING ROUND-CONSTANT RC3) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_03_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC3
    eor     \y1, \y1, #3
    eor     \y0, \y0, c3w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 4 OF SPARKLE384 (USING ROUND-CONSTANT RC4) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_04_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC4
    eor     \y1, \y1, #4    
    eor     \y0, \y0, c4w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w 
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 5 OF SPARKLE384 (USING ROUND-CONSTANT RC5) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_05_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC5
    eor     \y1, \y1, #4
    eor     \y1, \y1, #1
    //eor     \y1, \y1, #5
    eor     \y0, \y0, c5w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 6 OF SPARKLE384 (USING ROUND-CONSTANT RC6) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_06_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC6
    eor     \y1, \y1, #6
    eor     \y0, \y0, c6w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 7 OF SPARKLE384 (USING ROUND-CONSTANT RC7) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_07_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC7
    eor     \y1, \y1, #7
    eor     \y0, \y0, c7w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w  
    ARX_BOX \x1, \y1, c1w 
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 8 OF SPARKLE384 (USING ROUND-CONSTANT RC0) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_08_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC8
    eor     \y1, \y1, #8
    eor     \y0, \y0, c0w
    // ARXBOX Layer
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w 
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 9 OF SPARKLE384 (USING ROUND-CONSTANT RC1) ////
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_09_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC9
    eor     \y1, \y1, #8
    eor     \y1, \y1, #1
    //eor     \y1, \y1, #9
    eor     \y0, \y0, c1w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm


///////////////////////////////////////////////////////////////////////////////
//// MACRO FOR PERMUTATION-STEP 10 OF SPARKLE384 (USING ROUND-CONSTANT RC2) ///
///////////////////////////////////////////////////////////////////////////////

.macro PERM_STEP_10_384 x0:req, y0:req, x1:req, y1:req, x2:req, y2:req, \
                        x3:req, y3:req, x4:req, y4:req, x5:req, y5:req
    // Addition RC10
    eor     \y1, \y1, #8
    eor     \y1, \y1, #2
    //eor     \y0, \y0, #10
    eor     \y0, \y0, c2w
    // ARXBOX Layer    
    ARX_BOX \x0, \y0, c0w
    ARX_BOX \x1, \y1, c1w
    ARX_BOX \x2, \y2, c2w
    ARX_BOX \x3, \y3, c3w
    ARX_BOX \x4, \y4, c4w 
    ARX_BOX \x5, \y5, c5w
    // Linear Layer
    LL_TMPX \x0, \x1, \x2
    LL_ADDY \y3, \y0
    LL_ADDY \y4, \y1
    LL_ADDY \y5, \y2
    LL_TMPY \y0, \y1, \y2
    LL_ADDX \x3, \x0
    LL_ADDX \x4, \x1
    LL_ADDX \x5, \x2
.endm

///////////////////////////////////////////////////////////////////////////////
/////////////////// SPARKLE384 PERMUTATION (FULLY UNROLLED) ///////////////////
///////////////////////////////////////////////////////////////////////////////

// Function prototype:
// -------------------
// void sparkle384_a64(uint32_t *state, int steps)
//
// Parameters:
// -----------
// state: pointer to an uint32_t-array containing the 12 state words
// steps: number of steps (must be either 7 or 11)
//
// Return value:
// -------------
// None

.type sparkle384_a64, %function
.global sparkle384_a64
sparkle384_a64:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!

// codes start    
    ldp      w3,  w4, [x0], #8            //loading state     
    ldp      w5,  w6, [x0], #8
    ldp      w7,  w8, [x0], #8
    ldp      w9, w10, [x0], #8
    ldp     w11, w12, [x0], #8
    ldp     w13, w14, [x0]
    add      x0,  x0, #-40
   
// round constant    
    ldr     w19, =0xB7E15162
    ldr     w20, =0xBF715880
    ldr     w21, =0x38B4DA56
    ldr     w22, =0x324E7738
    ldr     w23, =0xBB1185EB     
    ldr     w24, =0x4F7C7B57    
    ldr     w25, =0xCFBFA1C8
    ldr     w26, =0xC2B3293D
    
    PERM_STEP_00_384 x0w, y0w, x1w, y1w, x2w, y2w, x3w, y3w, x4w, y4w, x5w, y5w              
    PERM_STEP_01_384 x4w, y4w, x5w, y5w, x3w, y3w, x0w, y0w, x1w, y1w, x2w, y2w     
    PERM_STEP_02_384 x1w, y1w, x2w, y2w, x0w, y0w, x4w, y4w, x5w, y5w, x3w, y3w               
    PERM_STEP_03_384 x5w, y5w, x3w, y3w, x4w, y4w, x1w, y1w, x2w, y2w, x0w, y0w    
    PERM_STEP_04_384 x2w, y2w, x0w, y0w, x1w, y1w, x5w, y5w, x3w, y3w, x4w, y4w    
    PERM_STEP_05_384 x3w, y3w, x4w, y4w, x5w, y5w, x2w, y2w, x0w, y0w, x1w, y1w    
    PERM_STEP_06_384 x0w, y0w, x1w, y1w, x2w, y2w, x3w, y3w, x4w, y4w, x5w, y5w
    
// return when the number of steps is slim
    cmp     x1, #7
    bgt     .Lbig_384
    stp     x4w, y4w, [x0], #8
    stp     x5w, y5w, [x0], #8
    stp     x3w, y3w, [x0], #8
    stp     x0w, y0w, [x0], #8
    stp     x1w, y1w, [x0], #8
    stp     x2w, y2w, [x0]
    
.Lbig_384:  
    PERM_STEP_07_384 x4w, y4w, x5w, y5w, x3w, y3w, x0w, y0w, x1w, y1w, x2w, y2w    
    PERM_STEP_08_384 x1w, y1w, x2w, y2w, x0w, y0w, x4w, y4w, x5w, y5w, x3w, y3w    
    PERM_STEP_09_384 x5w, y5w, x3w, y3w, x4w, y4w, x1w, y1w, x2w, y2w, x0w, y0w
    PERM_STEP_10_384 x2w, y2w, x0w, y0w, x1w, y1w, x5w, y5w, x3w, y3w, x4w, y4w    
    
    stp     x3w, y3w, [x0], #8
    stp     x4w, y4w, [x0], #8
    stp     x5w, y5w, [x0], #8
    stp     x2w, y2w, [x0], #8
    stp     x0w, y0w, [x0], #8
    stp     x1w, y1w, [x0]

// codes end

    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16

    ret
    .size sparkle384_a64, (. - sparkle384_a64)


