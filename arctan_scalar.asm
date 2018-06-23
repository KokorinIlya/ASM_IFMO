section .text
global _arctan_scalar

_arctan_scalar:

	; скал€рные операции SSE работают по младшему слову xmm-регистра (у нас little endian)

	mov eax, [esp + 4]
	mov [BUFFER], eax
	; младшее двойное слово BUFFER = x
	movups xmm0, [BUFFER]
	; младшее двойное слово xmm0 - x
	; в младшем двойном слове xmm0 хранитс€ текущий числитель

	mov ecx, [esp + 8]
	; ecx - количество ненулевых членов в разложении artcg(x) в степенной р€д

	mov edx, [TWO]
	mov [BUFFER], edx
	movups xmm1, [BUFFER]
	; инициализаци€ xmm1, в младшем двойном слове хранитс€ 2.0
	
	; если k <= 0, вернуть 0
	cmp ecx, 0
	jle return_zero

	mov edx, [ONE]
	mov [BUFFER], edx
	movups xmm2, [BUFFER]
	; инициализаци€ xmm2 значением 1.0
	; в xmm2 хранитс€ текущий числитель

	mov edx, [MINUS_ONE]
	mov [BUFFER], edx
	movups xmm7, [BUFFER]
	; в младшем двойном слове xmm7 хранитс€ -1
	
	movups xmm3, xmm0
	mulss xmm3, xmm3
	mulss xmm3, xmm7
	; в младшем двойном слове xmm3 хранитс€ x * x * (-1) = -x^2

	movups xmm4, xmm0
	; в младшем двойном слове xmm4 хранитс€ сумма k первых членов arctg(x)

	dec ecx
	; результат уже равен x, так что уменьшим k на 1
	test ecx, ecx
	jz return

	main_loop:
		mulss xmm0, xmm3
		; в xmm0 хранитс€ корректный текущий числитель

		addss xmm2, xmm1
		; в xmm2 хранитс€ корректный текущий числитель

		movups xmm7, xmm0
		divss xmm7, xmm2
		; в xmm7 хранитс€ текущий_числитель / текущий_знаменатель

		addss xmm4, xmm7
		; в xmm4 хранитс€ текуща€ сумма

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
	; Ѕуфер дл€ переноса в mmx-регистр из пам€ти или регистров общего назначени
	BUFFER : resd 4
