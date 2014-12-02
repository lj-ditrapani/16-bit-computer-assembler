NOP
.str abc
.long-string keep-newlines
a
b
c
.end-long-string
.copy expected-executables/copied.exe
.fill-array 4 keyboard
NOP
