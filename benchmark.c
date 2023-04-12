#include <time.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "sparkle_opt.h"

#define SPARKLE256_branch       4
#define SPARKLE384_branch       6
#define SPARKLE512_branch       8
#define SPARKLE256_big_step     10
#define SPARKLE384_big_step     11
#define SPARKLE512_big_step     12
#define SPARKLE256_small_step   7
#define SPARKLE384_small_step   7
#define SPARKLE512_small_step   8

void sparkle256_a64(uint32_t *state, int step);
void sparkle384_a64(uint32_t *state, int step);
void sparkle512_a64(uint32_t *state, int step);
void sparkle256_neon(uint32_t *state, int step);
void sparkle384_neon(uint32_t *state, int step);
void sparkle512_neon(uint32_t *state, int step);

uint32_t rand_uint32(void)
{
    uint32_t r = 0;
    for (int i = 0; i < 32; i++)
    {
        r = r * 2 + rand() % 2;
    }
    return r;
}

int main(void)
{
    struct timespec startTime, endTime;
    const long long NANOS = 1000000000LL;
    double retDiff = 0;
    int times = 10000000;
    uint32_t state256[2 * SPARKLE256_branch], state384[2 * SPARKLE384_branch], state512[2 * SPARKLE512_branch];
    uint32_t state256_1[2 * SPARKLE256_branch], state256_2[2 * SPARKLE256_branch], state384_1[2 * SPARKLE384_branch], state384_2[2 * SPARKLE384_branch], state512_1[2 * SPARKLE512_branch], state512_2[2 * SPARKLE512_branch];
    int i;
    uint32_t t;
    uint32_t t256[2 * SPARKLE256_branch], t384[2 * SPARKLE384_branch], t512[2 * SPARKLE512_branch];

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        t256[i] = rand_uint32();
    }

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        t384[i] = rand_uint32();
    }

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        t512[i] = rand_uint32();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////// Performance Check for SPARKLE256 using C ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("###############SPARKLE256 using C###############\n");

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        state256[i] = t256[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {
        sparkle_opt(state256, SPARKLE256_branch, SPARKLE256_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////// Performance Check for SPARKLE384 using C ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("###############SPARKLE384 using C###############\n");

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        state384[i] = t384[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {
        sparkle_opt(state384, SPARKLE384_branch, SPARKLE384_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////// Performance Check for SPARKLE512 using C ////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("###############SPARKLE512 using C###############\n");

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        state512[i] = t512[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {
        sparkle_opt(state512, SPARKLE512_branch, SPARKLE512_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////// Validation and Performance Check for SPARKLE256 using ARM A64 /////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("############SPARKLE256 using ARM A64############\n");

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        t = rand_uint32();
        state256_1[i] = t;
        state256_2[i] = t;
    }
    
    sparkle256_a64(state256_1, SPARKLE256_big_step);
    sparkle_opt(state256_2, SPARKLE256_branch, SPARKLE256_big_step);

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        if (state256_1[i] != state256_2[i])
        {
            printf("Validation check fail!!!!!!!!!!\n");
            return 0;
        }
    }

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        state256[i] = t256[i];
    }

    printf("Validation check Pass\n");

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {        
        sparkle256_a64(state256, SPARKLE256_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////// Performance Check for SPARKLE384 using ARM A64 ////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("############SPARKLE384 using ARM A64############\n");

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        t = rand_uint32();
        state384_1[i] = t;
        state384_2[i] = t;
    }

    sparkle384_a64(state384_1, SPARKLE384_big_step);
    sparkle_opt(state384_2, SPARKLE384_branch, SPARKLE384_big_step);

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        if (state384_1[i] != state384_2[i])
        {
            printf("Validation check fail!!!!!!!!!!\n");
            return 0;
        }
    }

    printf("Validation check Pass\n");

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        state384[i] = t384[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {
        sparkle384_a64(state384, SPARKLE384_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////// Performance Check for SPARKLE512 using ARM A64 ////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("############SPARKLE512 using ARM A64############\n");

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        t = rand_uint32();
        state512_1[i] = t;
        state512_2[i] = t;
    }

    sparkle512_a64(state512_1, SPARKLE512_big_step);
    sparkle_opt(state512_2, SPARKLE512_branch, SPARKLE512_big_step);

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        if (state512_1[i] != state512_2[i])
        {
            printf("Validation check fail!!!!!!!!!!\n");
            return 0;
        }
    }

    printf("Validation check Pass\n");

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        state512[i] = t512[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(int i = 0; i < times; i++)
    {
        sparkle512_a64(state512, SPARKLE512_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////// Validation and Performance Check for SPARKLE256 using NEON ASIMD ///////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("###########SPARKLE256 using NEON ASIMD##########\n");

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        t = rand_uint32();
        state256_1[i] = t;
        state256_2[i] = t;
    }
    
    sparkle256_neon(state256_1, SPARKLE256_big_step);
    sparkle_opt(state256_2, SPARKLE256_branch, SPARKLE256_big_step);

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        if (state256_1[i] != state256_2[i])
        {
            printf("Validation check fail!!!!!!!!!!\n");
            return 0;
        }
    }

    printf("Validation check Pass\n");

    for (i = 0; i < 2 * SPARKLE256_branch; i++)
    {
        state256[i] = t256[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {        
        sparkle256_neon(state256, SPARKLE256_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////// Validation and Performance Check for SPARKLE384 using NEON ASIMD ///////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("###########SPARKLE384 using NEON ASIMD##########\n");

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        t = rand_uint32();
        state384_1[i] = t;
        state384_2[i] = t;
    }

    sparkle384_neon(state384_1, SPARKLE384_big_step);
    sparkle_opt(state384_2, SPARKLE384_branch, SPARKLE384_big_step);

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        if (state384_1[i] != state384_2[i])
        {
            printf("Validation check fail!!!!!!!!!!\n");
            return 0;
        }
    }

    printf("Validation check Pass\n");

    for (i = 0; i < 2 * SPARKLE384_branch; i++)
    {
        state384[i] = t384[i];
    }

    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {
        sparkle384_neon(state384, SPARKLE384_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);

    ////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////// Validation and Performance Check for SPARKLE512 using NEON ASIMD ///////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    printf("###########SPARKLE512 using NEON ASIMD##########\n");

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        t = rand_uint32();
        state512_1[i] = t;
        state512_2[i] = t;
    }
    sparkle512_neon(state512_1, SPARKLE512_big_step);
    sparkle_opt(state512_2, SPARKLE512_branch, SPARKLE512_big_step);

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        if (state512_1[i] != state512_2[i])
        {
            printf("Validation check fail!!!!!!!!!!\n");
            return 0;
        }
    }

    printf("Validation check Pass\n");

    for (i = 0; i < 2 * SPARKLE512_branch; i++)
    {
        state512[i] = t512[i];
    }
    
    clock_gettime(CLOCK_MONOTONIC, &startTime);

    for(i = 0; i < times; i++)
    {
        sparkle512_neon(state512, SPARKLE512_big_step);
    }

    clock_gettime(CLOCK_MONOTONIC, &endTime);    

    retDiff = NANOS * (endTime.tv_sec - startTime.tv_sec) + (endTime.tv_nsec - startTime.tv_nsec);
    
    printf("time : %lf\n", retDiff/times);
}
