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

.set a $000D            # Address of A
.set b_low_byte $0E     # Low byte address of B
.set c_low_byte $0F     # Low byte address of C
.set address_reg RA     # Address register
.set a_reg R1           # Register that holds the value of A
.set b_reg R2           # Register that holds the value of B
.set c_reg R3           # Register that holds the value of C
WRD a address_reg
LOD address_reg a_reg
LBY b_low_byte address_reg
LOD address_reg b_reg
ADD a_reg b_reg c_reg
LBY c_low_byte address_reg
STR address_reg c_reg
END
.move a
.word 27        # $00D
.word 73        # $00E

# M[$000D] = 27
# M[$000E] = 73
# M[$000F] = 100  # 27 + 73 = 100
# PC = 8
