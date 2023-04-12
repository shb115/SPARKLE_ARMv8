# SPARKLE_ARMv8
## Target Device : Rasberry Pi 4B
## Reference Code
### C-code with -O3 option   
SPARKLE256 : 399.692ns   
SPARKLE384 : 609.941ns   
SPARKLE512 : 849.483ns   
## Optimized Code
### ASM using ARM A64 with -O3 option   
SPARKLE256 : 232.688ns   
SPARKLE384 : 336.197ns   
SPARKLE512 : 503.476ns   
### ASM using NEON ASIMD with -O3 option   
SPARKLE256 : 608.751ns   
SPARKLE384 : 662.404ns   
SPARKLE512 : 730.499ns
