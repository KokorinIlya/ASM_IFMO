section .text
global _arctan_scalar

_arctan_scalar:
	; ��������� �������� SSE �������� �� �������� ���� xmm-��������

	mov eax, [esp + 4]
	mov [CUR_NUM_ARR], eax
	; ������� ������� ����� CUR_NUM_ARR = x
	movups xmm0, [CUR_NUM_ARR]
	; ������� ������� ����� xmm0 - x
	; � ������� ������� ����� xmm0 �������� ������� ���������

	mov ecx, [esp + 8]
	; ecx - ���������� ��������� ������ � ���������� artcg(x) � ��������� ���

	mov ebx, [TWO]
	mov [TWO_ARR], ebx
	movups xmm1, [TWO_ARR]
	; ������������� xmm1, � ������� ������� ����� �������� 2.0
	
	; ���� k <= 0, ������� 0
	cmp ecx, 0
	jle return_zero

	mov ebx, [ONE]
	mov [CUR_DEN_ARR], ebx
	movups xmm2, [CUR_DEN_ARR]
	; ������������� xmm2 ��������� 1.0
	; � xmm2 �������� ������� ���������

	mov ebx, [MINUS_ONE]
	mov [MUL_NUM_ARR], ebx
	movups xmm7, [MUL_NUM_ARR]
	; � ������� ������� ����� xmm7 �������� -1
	
	movups xmm3, xmm0
	mulss xmm3, xmm3
	mulss xmm3, xmm7
	; � ������� ������� ����� xmm3 �������� x * x * (-1) = -x^2

	movups xmm4, xmm0
	; � ������� ������� ����� xmm4 �������� ����� k ������ ������ arctg(x)

	dec ecx
	; ��������� ��� ����� x, ��� ��� �������� k �� 1
	test ecx, ecx
	jz return

	main_loop:
		mulss xmm0, xmm3
		; � xmm0 �������� ���������� ������� ���������

		addss xmm2, xmm1
		; � xmm2 �������� ���������� ������� ���������

		movups xmm7, xmm0
		divss xmm7, xmm2
		; � xmm7 �������� �������_��������� / �������_�����������

		addss xmm4, xmm7
		; � xmm4 �������� ������� �����

		dec ecx
		test ecx, ecx
		jnz main_loop

	return:
		; �������������� FPU ����� ������� �� ��� ������� ��������
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
	; � ������� ������� ����� �������� ������� ��������� (x, -x^3, x^5, -x^7, ...)
	CUR_NUM_ARR : resd 4

	; � ������� ������� ����� �������� ��������� 2.0, ������� �� ������ ���� ������������ � 
	; �����������
	TWO_ARR : resd 4

	; � ������� ������� ����� �������� ������� ����������� (1, 3, 5, 7, ...)
	CUR_DEN_ARR : resd 4

	; � ������� ������� ����� �������� -x^2 - ��, �� ��� ����� ���������� ��������� �� ������ ����
	MUL_NUM_ARR : resd 4
