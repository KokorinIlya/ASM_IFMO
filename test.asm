extern _printf
section .text
global _main
_main2:
push string
push format
call _printf
add esp, 8
ret
section .rdata
format : db "%s", 0xA, 0
string : db "Hello, world!", 0