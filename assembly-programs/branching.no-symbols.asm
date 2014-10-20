# Author:  Lyall Jonathan Di Trapani
# Branching assembly program
# -------|---------|---------|---------|---------|---------|---------|--


# RA (register 10) is used for all value addresses
# RB has address of 2nd branch
# RC has address of final, common, end of program
# A is stored in M[$0100]
# B is stored in M[$0101]
# If A - B < 3, store 255 in M[$0102], else store 1 in M[$0102]
# Put A in R1
# Put B in R2
# Sub A - B and put in R3
# Load const 3 into R4
# Sub R3 - R4 => R5
# If R5 is negative, 255 => R6, else 1 => R6
# Store R6 into M[$0102]

# Load 2nd branch address into RB
HBY $00 RB
LBY $10 RB

# Load end of program address int RC
ADI RB 2 RC

# Load A value into R1
HBY $01 RA
LBY $00 RA
LOD RA R1

# Load B value into R2
LBY $01 RA
LOD RA R2

SUB R1 R2 R3

# Load constant 3 to R4
HBY $00 R4
LBY $03 R4

SUB R3 R4 R5

# Branch to RB if A - B >= 3
BRN R5 ZP RB

# Load constant 255 into R6
HBY $00 R6
LBY $FF R6
BRN R0 NZP RC   # (Jump to end)

# Load constant 0x01 into R6
HBY $00 R6
LBY $01 R6

# Store final value into M[0102]
LBY $02 RA
STR RA R6
END

.move $0100
.word 101
.word 99

# M[$0100] = 101
# M[$0101] = 99
# M[$0102] = 255  #  "101 - 99 < 3 => 255"
# PC = 20
