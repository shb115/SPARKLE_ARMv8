
.text

///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

// register sptr holds the start address of array 'state'
// x0
// register step holds the number of steps (parameter 'steps')
// x1
// registers c0w to c7w hold round constants from array 'rcon'
c0w .req w4
c1w .req w5
c2w .req w6
c3w .req w7
c4w .req w8
c5w .req w9
c6w .req w10
c7w .req w11
// registers tmpx, tmpy, tmp hold temporary values
tmp  .req v13

///////////////////////////////////////////////////////////////////////////////
/////////////////// SPARKLE384 PERMUTATION (FULLY UNROLLED) ///////////////////
///////////////////////////////////////////////////////////////////////////////

// Function prototype:
// -------------------
// void sparkle384_neon(uint32_t *state, int steps)
//
// Parameters:
// -----------
// state: pointer to an uint32_t-array containing the 12 state words
// steps: number of steps (must be either 7 or 11)
//
// Return value:
// -------------
// None

.type sparkle384_neon, %function
.global sparkle384_neon
sparkle384_neon:
// codes start
    ld2     {v0.s, v1.s}[0], [x0], #8
    ld2     {v0.s, v1.s}[1], [x0], #8
    ld2     {v0.s, v1.s}[2], [x0], #8
    ld2     {v2.s, v3.s}[0], [x0], #8
    ld2     {v2.s, v3.s}[1], [x0], #8
    ld2     {v2.s, v3.s}[2], [x0], #8
    add     x0, x0, #-48

// round constant
    ldr     w4, =0xB7E15162
    ldr     w5, =0xBF715880
    ldr     w6, =0x38B4DA56
    ldr     w7, =0x324E7738
    ldr     w8, =0xBB1185EB
    ldr     w9, =0x4F7C7B57
    ldr     w10, =0xCFBFA1C8
    ldr     w11, =0xC2B3293D
    mov     w12, #0

    mov     v4.s[0], w4
    mov     v4.s[1], w5
    mov     v4.s[2], w6
    mov     v5.s[0], w7
    mov     v5.s[1], w8
    mov     v5.s[2], w9
    dup     v7.4s, w12
    
// step 0
    
    mov     v7.s[0], c0w
    eor     v1.16b, v1.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b 

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b   
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v0.s[0]
    umov    w13, v0.s[1]
    umov    w14, v0.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v3.16b, v3.16b, v6.16b
    eor     v3.16b, v3.16b, v1.16b       
    
    // LL_TMPY
    umov    w12, v1.s[0]
    umov    w13, v1.s[1]
    umov    w14, v1.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v2.16b, v2.16b, v6.16b
    eor     v2.16b, v2.16b, v0.16b
 
// Swap
    ext     v8.16b, v2.16b, v2.16b, #12
    ext     v2.16b, v8.16b, v2.16b, #8
    ext     v8.16b, v3.16b, v3.16b, #12
    ext     v3.16b, v8.16b, v3.16b, #8
    

// step 1
    mov     v7.s[0], c1w
    mov     w15, #1
    mov     v7.s[1], w15
    eor     v3.16b, v3.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b 

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b   
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v2.s[0]
    umov    w13, v2.s[1]
    umov    w14, v2.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v1.16b, v1.16b, v6.16b
    eor     v1.16b, v1.16b, v3.16b       
    
    // LL_TMPY
    umov    w12, v3.s[0]
    umov    w13, v3.s[1]
    umov    w14, v3.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v0.16b, v0.16b, v6.16b
    eor     v0.16b, v0.16b, v2.16b

// Swap
    ext     v8.16b, v0.16b, v0.16b, #12
    ext     v0.16b, v8.16b, v0.16b, #8
    ext     v8.16b, v1.16b, v1.16b, #12
    ext     v1.16b, v8.16b, v1.16b, #8

// step 2
    mov     v7.s[0], c2w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v1.16b, v1.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b 
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v0.s[0]
    umov    w13, v0.s[1]
    umov    w14, v0.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v3.16b, v3.16b, v6.16b
    eor     v3.16b, v3.16b, v1.16b       
    
    // LL_TMPY
    umov    w12, v1.s[0]
    umov    w13, v1.s[1]
    umov    w14, v1.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v2.16b, v2.16b, v6.16b
    eor     v2.16b, v2.16b, v0.16b

// Swap
    ext     v8.16b, v2.16b, v2.16b, #12
    ext     v2.16b, v8.16b, v2.16b, #8
    ext     v8.16b, v3.16b, v3.16b, #12
    ext     v3.16b, v8.16b, v3.16b, #8
 
// step 3
    mov     v7.s[0], c3w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v3.16b, v3.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b  
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v2.s[0]
    umov    w13, v2.s[1]
    umov    w14, v2.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v1.16b, v1.16b, v6.16b
    eor     v1.16b, v1.16b, v3.16b       
    
    // LL_TMPY
    umov    w12, v3.s[0]
    umov    w13, v3.s[1]
    umov    w14, v3.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v0.16b, v0.16b, v6.16b
    eor     v0.16b, v0.16b, v2.16b

// Swap
    ext     v8.16b, v0.16b, v0.16b, #12
    ext     v0.16b, v8.16b, v0.16b, #8
    ext     v8.16b, v1.16b, v1.16b, #12
    ext     v1.16b, v8.16b, v1.16b, #8

// step 4
    mov     v7.s[0], c4w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v1.16b, v1.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v0.s[0]
    umov    w13, v0.s[1]
    umov    w14, v0.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v3.16b, v3.16b, v6.16b
    eor     v3.16b, v3.16b, v1.16b       
    
    // LL_TMPY
    umov    w12, v1.s[0]
    umov    w13, v1.s[1]
    umov    w14, v1.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v2.16b, v2.16b, v6.16b
    eor     v2.16b, v2.16b, v0.16b

// Swap
    ext     v8.16b, v2.16b, v2.16b, #12
    ext     v2.16b, v8.16b, v2.16b, #8
    ext     v8.16b, v3.16b, v3.16b, #12
    ext     v3.16b, v8.16b, v3.16b, #8

// step 5
    mov     v7.s[0], c5w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v3.16b, v3.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b 
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v2.s[0]
    umov    w13, v2.s[1]
    umov    w14, v2.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v1.16b, v1.16b, v6.16b
    eor     v1.16b, v1.16b, v3.16b       
    
    // LL_TMPY
    umov    w12, v3.s[0]
    umov    w13, v3.s[1]
    umov    w14, v3.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v0.16b, v0.16b, v6.16b
    eor     v0.16b, v0.16b, v2.16b

// Swap
    ext     v8.16b, v0.16b, v0.16b, #12
    ext     v0.16b, v8.16b, v0.16b, #8
    ext     v8.16b, v1.16b, v1.16b, #12
    ext     v1.16b, v8.16b, v1.16b, #8

// step 6
    mov     v7.s[0], c6w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v1.16b, v1.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v0.s[0]
    umov    w13, v0.s[1]
    umov    w14, v0.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v3.16b, v3.16b, v6.16b
    eor     v3.16b, v3.16b, v1.16b       
    
    // LL_TMPY
    umov    w12, v1.s[0]
    umov    w13, v1.s[1]
    umov    w14, v1.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v2.16b, v2.16b, v6.16b
    eor     v2.16b, v2.16b, v0.16b

// Swap
    ext     v8.16b, v2.16b, v2.16b, #12
    ext     v2.16b, v8.16b, v2.16b, #8
    ext     v8.16b, v3.16b, v3.16b, #12
    ext     v3.16b, v8.16b, v3.16b, #8

// return when the number of steps is slim
    cmp     x1, #7
    bgt     .Lbig_384
    st2     {v2.s, v3.s}[1], [x0], #8
    st2     {v2.s, v3.s}[2], [x0], #8
    st2     {v2.s, v3.s}[0], [x0], #8
    st2     {v0.s, v1.s}[0], [x0], #8
    st2     {v0.s, v1.s}[1], [x0], #8
    st2     {v0.s, v1.s}[2], [x0], #8

.Lbig_384:    
// step 7
    mov     v7.s[0], c7w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v3.16b, v3.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v2.s[0]
    umov    w13, v2.s[1]
    umov    w14, v2.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v1.16b, v1.16b, v6.16b
    eor     v1.16b, v1.16b, v3.16b       
    
    // LL_TMPY
    umov    w12, v3.s[0]
    umov    w13, v3.s[1]
    umov    w14, v3.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v0.16b, v0.16b, v6.16b
    eor     v0.16b, v0.16b, v2.16b

// Swap
    ext     v8.16b, v0.16b, v0.16b, #12
    ext     v0.16b, v8.16b, v0.16b, #8
    ext     v8.16b, v1.16b, v1.16b, #12
    ext     v1.16b, v8.16b, v1.16b, #8

// step 8
    mov     v7.s[0], c0w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v1.16b, v1.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v0.s[0]
    umov    w13, v0.s[1]
    umov    w14, v0.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v3.16b, v3.16b, v6.16b
    eor     v3.16b, v3.16b, v1.16b       
    
    // LL_TMPY
    umov    w12, v1.s[0]
    umov    w13, v1.s[1]
    umov    w14, v1.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v2.16b, v2.16b, v6.16b
    eor     v2.16b, v2.16b, v0.16b

// Swap
    ext     v8.16b, v2.16b, v2.16b, #12
    ext     v2.16b, v8.16b, v2.16b, #8
    ext     v8.16b, v3.16b, v3.16b, #12
    ext     v3.16b, v8.16b, v3.16b, #8

// step 9
    mov     v7.s[0], c1w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v3.16b, v3.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v2.16b, v2.16b, v4.16b
    eor     v0.16b, v0.16b, v5.16b
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v2.s[0]
    umov    w13, v2.s[1]
    umov    w14, v2.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v1.16b, v1.16b, v6.16b
    eor     v1.16b, v1.16b, v3.16b       
    
    // LL_TMPY
    umov    w12, v3.s[0]
    umov    w13, v3.s[1]
    umov    w14, v3.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v0.16b, v0.16b, v6.16b
    eor     v0.16b, v0.16b, v2.16b

// Swap
    ext     v8.16b, v0.16b, v0.16b, #12
    ext     v0.16b, v8.16b, v0.16b, #8
    ext     v8.16b, v1.16b, v1.16b, #12
    ext     v1.16b, v8.16b, v1.16b, #8

// step 10
    mov     v7.s[0], c2w
    add     w15, w15, #1
    mov     v7.s[1], w15
    eor     v1.16b, v1.16b, v7.16b
     
    // ARX_BOX
    shl     tmp.4s, v1.4s, #1
    sri     tmp.4s, v1.4s, #31
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #1
    sri     tmp.4s, v3.4s, #31
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #8
    sri     tmp.4s, v0.4s, #24
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #8
    sri     tmp.4s, v2.4s, #24
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #15
    sri     tmp.4s, v1.4s, #17
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #15
    sri     tmp.4s, v3.4s, #17
    add     v2.4s, v2.4s, tmp.4s
    shl     tmp.4s, v0.4s, #15
    sri     tmp.4s, v0.4s, #17
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #15
    sri     tmp.4s, v2.4s, #17
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    add     v0.4s, v0.4s, v1.4s
    add     v2.4s, v2.4s, v3.4s
    shl     tmp.4s, v0.4s, #1
    sri     tmp.4s, v0.4s, #31
    eor     v1.16b, v1.16b, tmp.16b
    shl     tmp.4s, v2.4s, #1
    sri     tmp.4s, v2.4s, #31
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b

    shl     tmp.4s, v1.4s, #8
    sri     tmp.4s, v1.4s, #24
    add     v0.4s, v0.4s, tmp.4s
    shl     tmp.4s, v3.4s, #8
    sri     tmp.4s, v3.4s, #24
    add     v2.4s, v2.4s, tmp.4s
    rev32   tmp.8h, v0.8h
    eor     v1.16b, v1.16b, tmp.16b
    rev32   tmp.8h, v2.8h
    eor     v3.16b, v3.16b, tmp.16b
    eor     v0.16b, v0.16b, v4.16b
    eor     v2.16b, v2.16b, v5.16b
        
    // Linear Layer
    // LL_TMPX
    umov    w12, v0.s[0]
    umov    w13, v0.s[1]
    umov    w14, v0.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12    

    // LL_ADDY
    eor     v3.16b, v3.16b, v6.16b
    eor     v3.16b, v3.16b, v1.16b       
    
    // LL_TMPY
    umov    w12, v1.s[0]
    umov    w13, v1.s[1]
    umov    w14, v1.s[2]
    eor     w12, w12, w13
    eor     w12, w12, w14
    eor     w12, w12, w12, lsl #16
    ror     w12, w12, #16
    dup     v6.4s, w12

    // LL_ADDX
    eor     v2.16b, v2.16b, v6.16b
    eor     v2.16b, v2.16b, v0.16b

// Store
    st2     {v2.s, v3.s}[1], [x0], #8
    st2     {v2.s, v3.s}[2], [x0], #8
    st2     {v2.s, v3.s}[0], [x0], #8
    st2     {v0.s, v1.s}[0], [x0], #8
    st2     {v0.s, v1.s}[1], [x0], #8
    st2     {v0.s, v1.s}[2], [x0], #8

    ret
    .size sparkle384_neon, (. - sparkle384_neon)

