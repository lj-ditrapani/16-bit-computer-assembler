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

.set address_a $0100
.set three $0003

# Load 2nd branch address into RB
WRD branch_b RB

# Load end of program address int RC
ADI RB 2 RC

# Load value A into R1
WRD address_a RA
LOD RA R1

# Load B value into R2
LBY $01 RA
LOD RA R2

SUB R1 R2 R3

# Load constant 3 to R4
WRD three R4

SUB R3 R4 R5

# Branch to RB if A - B >= 3
BRN R5 ZP RB

(branch_a)
# Load constant 255 into R6
WRD $00FF R6
BRN R0 NZP RC   # (Jump to end)

(branch_b)
# Load constant $01 into R6
WRD $0001 R6

(end_branch)
# Store final value into M[0102]
LBY $02 RA
STR RA R6
END

.move address_a
.word 101
.word 99

# M[$0100] = 101
# M[$0101] = 99
# M[$0102] = 255  #  "101 - 99 < 3 => 255"
# PC = 20
