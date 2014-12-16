# Convert an ASCII hex file to true binary .exe
xxd -c 2 -p -r ${1}.hex > ${1}.exe
xxd -c 2 -p -u ${1}.exe > x
diff x ${1}.hex
rm -f x
