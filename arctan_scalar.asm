section .text
global _arctan_scalar

_arctan_scalar:

	; ��������� �������� SSE �������� �� �������� ����� xmm-�������� (� ��� little endian)

	mov eax, [esp + 4]
	mov [BUFFER], eax
	; ������� ������� ����� BUFFER = x
	movups xmm0, [BUFFER]
	; ������� ������� ����� xmm0 - x
	; � ������� ������� ����� xmm0 �������� ������� ���������

	mov ecx, [esp + 8]
	; ecx - ���������� ��������� ������ � ���������� artcg(x) � ��������� ���

	mov edx, [TWO]
	mov [BUFFER], edx
	movups xmm1, [BUFFER]
	; ������������� xmm1, � ������� ������� ����� �������� 2.0
	
	; ���� k <= 0, ������� 0
	cmp ecx, 0
	jle return_zero

	mov edx, [ONE]
	mov [BUFFER], edx
	movups xmm2, [BUFFER]
	; ������������� xmm2 ��������� 1.0
	; � xmm2 �������� ������� ���������

	mov edx, [MINUS_ONE]
	mov [BUFFER], edx
	movups xmm7, [BUFFER]
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
	; ����� ��� �������� � mmx-������� �� ������ ��� ��������� ������ ���������
	BUFFER : resd 4
