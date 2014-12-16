# Author:  Lyall Jonathan Di Trapani
# Assembly program that adds 2 number together
# -------|---------|---------|---------|---------|---------|---------|--

# RA (register 10) is used for all addresses
# A is stored in M[000D]
# B is stored in M[000E]
# Add A and B and store in M[000F]
# Put A in R1
# Put B in R2
# Add A + B and put in R3
# Store R3 into M[000F]

HBY $00 RA
LBY $0D RA
LOD RA R1
LBY $0E RA
LOD RA R2
ADD R1 R2 R3
LBY $0F RA
STR RA R3
END
.move $000D
.word 27        # $00D
.word 73        # $00E

# M[$000D] = 27
# M[$000E] = 73
# M[$000F] = 100  # 27 + 73 = 100
# PC = 8
