# .long-string directive has invalid argument (should be strip-newlines)
.set a 5
(important-string)
.long-string drop-newlines
This is my
long string
.end-long-string
ADDI R3 a R4
