# SPARKLE_ARMv8
## Target Device : Rasberry Pi 4B
## Reference Code
### C-code with -O3 option   
SPARKLE256 : 399.692ns   
SPARKLE384 : 609.941ns   
SPARKLE512 : 849.483ns   
## Optimized Code
### S-code using ARM A64 with -O3 option   
SPARKLE256 : 232.688   
SPARKLE384 : 336.197   
SPARKLE512 : 503.476   
### S-code using NEON ASIMD with -O3 option   
SPARKLE256 : 608.751   
SPARKLE384 : 662.404   
SPARKLE512 : 730.499
