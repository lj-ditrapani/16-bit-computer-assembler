# .end-long-string on line 4 comes before .long-string directive
.set a 5
SPC R1
(important-string)
.end-long-string
This is my
long string
.long-string keep-newlines
ADDI R3 a R4
