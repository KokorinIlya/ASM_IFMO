extern _printf
section .text
global _main_test
_main_test:
push string
push format
call _printf
add esp, 8
ret
section .rdata
format : db "%s", 0xA, 0
string : db "Hello, world!", 0