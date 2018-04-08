; программа печатает на экран число, заданное в регистре eax

extern _printf
section .text
global _main_print

; процедура заполняет buffer цифрами целого положительного числа
; eax - целое положительное число
_unsigned_number_to_string

	; ebx - делитель
	mov ebx, 10
	xor ecx, ecx

	; цикл делит число на цифры и кладёт их на стек в обратном порядке
	; ecx - количество цифр в числе
	_digit_to_stack:
		xor edx, edx ; edx = 0
		div ebx ; edx | eax : ebx
		; eax = eax / 10
		; edx = eax % 10
		; в edx Теперь лежит код символа от '0' до '9'
		add edx, '0'
		; цифра кладётся на стек, чтобы потом быть извлечённой в обратном порядке
		push edx
		inc ecx
		test eax, eax
	jnz _digit_to_stack

	xor ebx, ebx

	; цикл достаёт цифры со стека, восстанавливая исходный порядок 
	; и записывает их в buffer
	; ebx - количество уже записанных цифр
	; edi - начинать с 1 или с 0 (был ли записан минус или нет)
	_get_digit_from_stack:
		pop edx
		; взять число от '0' до '9' со стека и записать в буффер его младшие 8 бит
		mov [buffer + edi + ebx], dl
		inc ebx
		dec ecx
	jne _get_digit_from_stack

	; поставить 0-терминатор на последний символ
	mov byte [buffer + edi + ebx], 0
	jmp _print
; конец процедуры

; точка входа в программу
_main_print:
	; целое число
	mov eax, -2147483648

	; в регистре edi записан адрес, с которого надо писать в buffer, изначально 0
	xor edi, edi
	cmp eax, 0
	; если число положительное, перейти к обработке
	jge _start_processing
	; если отрицательное - записать в buffer '-' и установить edi = 1
	mov byte [buffer], '-'
	inc edi

	; записать в eax модуль хранящегося там числа
	mov edx, eax
	sar edx, 31
	xor eax, edx
	sub eax, edx
	; eax = |eax|

	_start_processing:
	jmp _unsigned_number_to_string

	; в этот момент в buffer записано строковая форма числа
	; воспользоваться printf для вывода
	_print:
	push buffer
	push format
	call _printf
	add esp, 8
	ret

section .rdata
format : db "%s", 0xA, 0

section .data
; тестовый буфер, чтобы проверить, что 0-терминатор ставится 
; на нужную позицию и лишние # не выводятся
;buffer : db "#####################"

section .bss
buffer : resb 20