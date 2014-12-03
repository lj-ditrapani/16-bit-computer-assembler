.array 	 [	1  # First line
2 3
# comment inside array
%0000_0100      # Binary number

$0005]          # Hex number
NOP
.long-string keep-newlines


.end-long-string
NOP
.long-string strip-newlines
# a	

b #	c
.end-long-string
# end program

