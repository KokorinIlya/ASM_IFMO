section .text
global _arctan_scalar

_arctan_scalar:
	; скалярные операции SSE работают по старшему биту xmm-регистра

	mov eax, [esp + 4]
	mov [BUFFER], eax
	; старшее двойное слово BUFFER = x
	movups xmm0, [BUFFER]
	; старшее двойное слово xmm0 - x
	; в старшем двойном слове xmm0 хранится текущий числитель

	mov ecx, [esp + 8]
	; ecx - количество ненулевых членов в разложении artcg(x) в степенной ряд

	mov ebx, [TWO]
	mov [BUFFER], ebx
	movups xmm1, [BUFFER]
	; инициализация xmm1, в старшем двойном слове хранится 2.0
	
	; если k <= 0, вернуть 0
	cmp ecx, 0
	jle return_zero

	mov ebx, [ONE]
	mov [BUFFER], ebx
	movups xmm2, [BUFFER]
	; инициализация xmm2 значением 1.0
	; в xmm2 хранится текущий числитель

	mov ebx, [MINUS_ONE]
	mov [BUFFER], ebx
	movups xmm7, [BUFFER]
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

		movups [BUFFER], xmm4
		fld dword [BUFFER]
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
	; Буфер для переноса в mmx-регистр из памяти или регистров общего назначени
	BUFFER : resd 4
