section .text
global _arctan

_arctan:
	; arctg(x) = x - (x ^ 3) / 3 + (x ^ 5) / 5 - (x ^ 7) / 7 + ...

	finit
	mov ecx, [esp + 8] ; � ecx �������� ���������� ��������� ������ � ���������� � ��� �������
	fld dword [esp + 4] ; ����: x

	cmp ecx, 0
	jle return_zero

	cmp ecx, 1
	je return_x

	fld st0 ; ����: x, x
	fmul st0, st1 ; ����: x^2, x
	fchs ; ����: -x^2, x
	fstp dword [NUMERATOR_MUL] ; ����: x
	fld1 ; ����: 1.0, x
	fld st1 ; ����: x, 1.0, x
			; ��������� �����:
			; st0 - ������� ����� ����
			; st1 - ������� ����������� �����
			; st2 - ������� ���������
	dec ecx ; ����� ���� ��� ����� ��� �������� (������� ����� - x)
	
	one_step_more:
		fld st1
		fadd dword [TWO] ; ������ �� ������� ����� �������� ���������� ����������� ��� ������� ����
					; ����: cur_denom, sum, old_denom, old_num

		fld st3
		fmul dword [NUMERATOR_MUL] ; ������ �� ������� ����� �������� ���������� ��������� ��� ������� ����
							; ����: cur_num, cur_denom, sum, old_denom, old_num

		fst st4 ; ����: cur_num, cur_denom, sum, old_denom, cur_num

		fdiv st1 ; ����: cur_num / cur_denom, cur_denom, sum, old_denom, cur_num
		faddp st2, st0 ; ����: cur_denom, sum + cur_num / cur_denom, old_denom, cur_num

		fstp st2 ; ����: cur_sum, cur_denom, cur_num
		; ��������� ����� ������������
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
	TWO: dd 2.0 ; ��, ��� ����� �� ������ ���� ��������� � ����������� �����

section .bss
	NUMERATOR_MUL: dd 0 ; ��, �� ��� ����� �� ������ ���� �������� ��������� �����
						; ��� ����� ������ -x^2

	TRASH: dd 0 ; ���� �� ����� ����� ����������� �������� ����� 