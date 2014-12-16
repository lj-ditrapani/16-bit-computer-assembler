Create binary exe file from ASCII hex file

    xxd -c 2 -p -r file.hex > file.exe$

Validate binary exe file is correct

    xxd -c 2 -p -u file.exe > x
    diff x file.hex
    rm x
