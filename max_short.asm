section .text

global _max_short

; функция выбирает максимум из 4 переданных ей чисел
; все числа типа short
_max_from_4:	
	mov ax, [esp + 4]

	cmp ax, [esp + 6]
	jge check_3
	mov ax, [esp + 6]

	check_3:
	cmp ax, [esp + 8]
	jge check_4
	mov ax, [esp + 8]

	check_4:
	cmp ax, [esp + 10]
	jge finish_check
	mov ax, [esp + 10]
	
	finish_check:
	ret

; функция обрабатывает "хвост" массива (от 0 до 3 элементов)
; сигнатура:
; process_tail(short cur_res, short* ptr_to_tail, int tail_size)
_process_tail
	push ebx
	; на стеке лежит ebx, ко всем адресам на стеке прибавляется 4

	; в ax храним максимум
	mov ax, [esp + 8]
	xor ecx, ecx
	mov edx, [esp + 10]
	; edx - указатель на начало хвоста
	
	loop_tail:
		cmp ecx, [esp + 14]
		jge ret_tail
		mov bx, [edx + ecx * 2]
		; bx - текущее число
		; каждое из чисел - short, так что ходим по памяти с шагом 2

		cmp ax, bx
		jge finish_cur_tail_update
		mov ax, bx

		finish_cur_tail_update:
		inc ecx
		jmp loop_tail

	ret_tail:
	pop ebx
	ret

; функция выбирает максимум из массива чисел типа short
; len > 0
_max_short:
	mov eax, [esp + 4]
	mov [ARRAY], eax
	mov eax, [esp + 8]
	mov [LEN], eax

	cmp dword [LEN], 4
	jge not_only_tail
	
		; обработать от 1 до 3 элементов
		push dword [LEN]
		push dword [ARRAY]
		mov edx, [ARRAY]
		push word [edx]
		; положить на стек первый элемент
		call _process_tail
		add esp, 10
		; снять со стека аргументы функции
		ret
		; в ax ответ

	not_only_tail
	
		; инициализируем количество блоков и размер хвоста
		xor edx, edx
		mov eax, [LEN]
		mov ecx, 4
		div ecx
		mov [BLOCKS], eax
		mov [REM], edx
		
		; eax - указатель на начало массива
		; mm0 - текущие 4 максимальные элемента (основной набор)
		; ecx - сколько блоков уже пройдено
		mov eax, [ARRAY]
		movq mm0, [eax]
		mov ecx, 1

		; цикл обработки текущего блока
		process_block:
			cmp ecx, [BLOCKS]
			jge blocks_processed
			
			; ходим по 8, так как 4 числа * 2 байта
			; mm1 - текущие 4 элемента (текущий набор)
			movq mm1, [eax + ecx * 8]

			movq mm2, mm0
			pcmpgtw mm2, mm1
			; теперь mm2[i] = 0xFFFF, если mm0[i] > mm1[i], 
			; mm2[i] = 0x0000, если mm0[i] <= mm1[i]

			pand mm0, mm2
			; сохраняем большие элементы и зануляем меньшие (в основном наборе)

			pandn mm2, mm1
			; аналогично для текущего набора, теперь в mm2 хранятся нужные элементы
			; из текущего набора

			por mm0, mm2
			; объединяем наборы
			
			inc ecx
			jmp process_block

		blocks_processed:
		; обработаны все блоки по 4 элемента
		; выберем максимум из 4 чисел основного набора

		; освободить на стеке место для 4 short'ов (4 * 2)
		sub esp, 16

		; записать на стек 4 числа из основного набора
		; они запишутся с [esp] по [esp + 16] так, 
		; что [esp ... esp + 2) - первое число
		; [esp + 2 ... esp + 4) - второе и тд
		movq [esp], mm0
		call _max_from_4
		add esp, 16
		; выбран максимум из 4 кандидатов (он в ax)
		; теперь рассмотрим хвост

		; edx - указатель на начало массива,
		; прибавим к нему число обработанных байт
		mov edx, [ARRAY] 
		; edx - указатель на начало хвоста
		lea edx, [edx + ecx * 8]

		push dword [REM]
		push edx
		push ax
		call _process_tail
		add esp, 10
		; посчитали максимум с хвоста, ответ хранится в ax
		; это и есть ответ для всего массива

		; пометить все mm-регистры как свободные (для соблюдения конвенции вызова)
		emms

		ret

section .data

	; указатель на начало массива short
	ARRAY : dd 0

	; длина массива
	LEN : dd 0

	; количество "блоков" по 4 числа
	BLOCKS : dd 0

	; остаток - размер "хвоста"
	REM : dd 0