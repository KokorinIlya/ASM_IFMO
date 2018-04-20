section .text
global _arctan

_arctan:
	; arctg(x) = x - (x ^ 3) / 3 + (x ^ 5) / 5 - (x ^ 7) / 7 + ...

	finit
	mov ecx, [esp + 8] ; в ecx хранится количество ненулевых членов в разложении в ряд Тейлора
	fld dword [esp + 4] ; стек: x

	cmp ecx, 0
	jle return_zero

	cmp ecx, 1
	je return_x

	fld st0 ; стек: x, x
	fmul st1 ; стек: x^2, x
	fchs ; стек: -x^2, x
	fstp dword [NUMERATOR_MUL] ; стек: x
	fld1 ; стек: 1.0, x
	fld st1 ; стек: x, 1.0, x
			; инвариант цикла:
			; st0 - текущая сумма ряда
			; st1 - текущий знаменатель дроби
			; st2 - текущий числитель
	dec ecx ; пусть один шаг цикла уже выполнен (текущая сумма - x)
	
	one_step_more:
		fld st1
		fadd dword [TWO] ; теперь на вершине стека хранится корректный знаменатель для данного шага
					; стек: cur_denom, sum, old_denom, old_num

		fld st3
		fmul dword [NUMERATOR_MUL] ; теперь на вершине стека хранится корректный числитель для данного шага
							; стек: cur_num, cur_denom, sum, old_denom, old_num

		fst st4 ; стек: cur_num, cur_denom, sum, old_denom, cur_num

		fdiv st1 ; стек: cur_num / cur_denom, cur_denom, sum, old_denom, cur_num
		faddp st2, st0 ; стек: cur_denom, sum + cur_num / cur_denom, old_denom, cur_num

		fstp st2 ; стек: cur_sum, cur_denom, cur_num
		; инвариант цикла восстановлен
		dec ecx
		test ecx, ecx
		jnz one_step_more


	ffree st1
	ffree st2

	ret

return_zero:
	finit
	fldz
	ret

return_x:
	ret

section .rdata
	TWO: dd 2.0 ; то, что нужно на каждом шаге прибалять к знаменателю дроби

section .bss
	NUMERATOR_MUL: dd 0 ; то, на что нужно на каждом шаге умножать числитель дроби
						; тут будет лежать -x^2

	TRASH: dd 0 ; сюда со стека будут скидываться ненужные числа 