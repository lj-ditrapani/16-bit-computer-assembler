# This program includes an assembly file that includes another file
WRD storage-out RA
WRD $1234 R0
WRD $4321 R1
ADD R0 R1 R2                    # R2 should have $5555
# Will include another file
.include assembly-programs/include-and-copy.asm
STR RA R2                       # Store the output
