# Author:  Lyall Jonathan Di Trapani
# Assembly program with a while loop
# -------|---------|---------|---------|---------|---------|---------|--

# Run a complete program
# Uses storage I/O
#   - input/read $E400
#   - output/write $E800
# Input: n followed by a list of n integers
# Output: -2 * sum(list of n integers)

.set input R0
.set output R1
.set n R2
.set start_addr R3
.set end_addr R4
.set sum R5

# R0 gets address of beginning of input from storage space
WRD storage-in input        # $E400

# R1 gets address of begining of output to storage space
WRD storage-out output      # $E800

# R2 gets n, the count of how many input values to sum
LOD input n                 # First Input (count n) -> R2

# R3 and R4 have start and end of while loop respectively
LBY loop_start start_addr   # addr start of while loop -> R3
LBY loop_end end_addr       # addr to end while loop -> R4

(loop_start)
# Start of while loop
BRN n Z end_addr            # if R2 is zero ($.... -> PC)
INC input                   # increment input address
LOD input R6                # Next Input -> R6
ADD sum R6 sum              # R5 + R6 (running sum) -> R5
DEC n                       # R2 - 1 -> R2
JMP start_addr              # $.... -> PC (unconditional)

(loop_end)
# End of while loop
SHF sum left 1 R6           # Double sum

# Negate double of sum
SUB R7 R6 R7                # 0 - R6 -> R7

# Output result
STR output R7               # Output value of R7
END

.move storage-in
.word 101
.array [
  10  11  12  13  14  15  16  17  18  19
  20  21  22  23  24  25  26  27  28  29
  30  31  32  33  34  35  36  37  38  39
  40  41  42  43  44  45  46  47  48  49
  50  51  52  53  54  55  56  57  58  59
  60  61  62  63  64  65  66  67  68  69
  70  71  72  73  74  75  76  77  78  79
  80  81  82  83  84  85  86  87  88  89
  90  91  92  93  94  95  96  97  98  99
 100 101 102 103 104 105 106 107 108 109
 110
]

# length = 101
# M[$E400..($E400 + length)] = [length].concat [10..110]
# n = length(10..110) = 101
# sum(10..110) = 6060
# -2 * 6060 = -12120
# 16-bit hex(+12120) = $2F58
# 16-bit hex(-12120) = $D0A8
# M[$E400] = 101, '1st input is 101'
# M[$E401] = 10, '2nd input is 10'
# M[$E400 + 101] = 110, "Last input is 110"
# M[$E800] = $D0A8, "Outputs #{$D0A8}"
# PC is 16
