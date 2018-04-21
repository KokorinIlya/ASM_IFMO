section .text
global _arctan_scalar

_arctan_scalar:
	; скалярные операции SSE работают по старшему биту xmm-регистра

	mov eax, [esp + 4]
	mov [CUR_NUM_ARR], eax
	; старшее двойное слово CUR_NUM_ARR = x
	movups xmm0, [CUR_NUM_ARR]
	; старшее двойное слово xmm0 - x
	; в старшем двойном слове xmm0 хранится текущий числитель

	mov ecx, [esp + 8]
	; ecx - количество ненулевых членов в разложении artcg(x) в степенной ряд

	mov ebx, [TWO]
	mov [TWO_ARR], ebx
	movups xmm1, [TWO_ARR]
	; инициализация xmm1, в старшем двойном слове хранится 2.0
	
	; если k <= 0, вернуть 0
	cmp ecx, 0
	jle return_zero

	mov ebx, [ONE]
	mov [CUR_DEN_ARR], ebx
	movups xmm2, [CUR_DEN_ARR]
	; инициализация xmm2 значением 1.0
	; в xmm2 хранится текущий числитель

	mov ebx, [MINUS_ONE]
	mov [MUL_NUM_ARR], ebx
	movups xmm7, [MUL_NUM_ARR]
	; в старшем двойном слове xmm7 хранится -1
	
	movups xmm3, xmm0
	mulss xmm3, xmm3
	mulss xmm3, xmm7
	; в старшем двойном слове xmm3 хранится x * x * (-1) = -x^2

	movups xmm4, xmm0
	; в старшем двойном слове xmm4 хранится сумма k первых членов arctg(x)

	dec ecx
	; результат уже равен x, так что уменьшим k на 1
	test ecx, ecx
	jz return

	main_loop:
		mulss xmm0, xmm3
		; в xmm0 хранится корректный текущий числитель

		addss xmm2, xmm1
		; в xmm2 хранится корректный текущий числитель

		movups xmm7, xmm0
		divss xmm7, xmm2
		; в xmm7 хранится текущий_числитель / текущий_знаменатель

		addss xmm4, xmm7
		; в xmm4 хранится текущая сумма

		dec ecx
		test ecx, ecx
		jnz main_loop

	return:
		; инициализируем FPU чтобы вернуть на его вершине значение
		finit

		movups [CUR_DEN_ARR], xmm4
		fld dword [CUR_DEN_ARR]
		ret

	return_zero:
		finit
		fldz
		ret
	
section .rdata
	TWO : dd 2.0
	ONE : dd 1.0
	MINUS_ONE : dd -1.0

section .bss
	; в старшем двойном слове хранится текущий числитель (x, -x^3, x^5, -x^7, ...)
	CUR_NUM_ARR : resd 4

	; в старшем двойном слове хранится константа 2.0, которая на каждом шаге прибавляется к 
	; знаменателю
	TWO_ARR : resd 4

	; в старшем двойном слове хранится текущий знаменатель (1, 3, 5, 7, ...)
	CUR_DEN_ARR : resd 4

	; в старшем двойном слове хранится -x^2 - то, на что будет умножаться числитель на каждом шаге
	MUL_NUM_ARR : resd 4
