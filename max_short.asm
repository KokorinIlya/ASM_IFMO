section .text

global _max_short

; ������� �������� �������� �� 4 ���������� �� �����
; ��� ����� ���� short
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

; ������� ������������ "�����" ������� (�� 0 �� 3 ���������)
; ���������:
; process_tail(short cur_res, short* ptr_to_tail, int tail_size)
_process_tail
	push ebx
	; �� ����� ����� ebx, �� ���� ������� �� ����� ������������ 4

	; � ax ������ ��������
	mov ax, [esp + 8]
	xor ecx, ecx
	mov edx, [esp + 10]
	; edx - ��������� �� ������ ������
	
	loop_tail:
		cmp ecx, [esp + 14]
		jge ret_tail
		mov bx, [edx + ecx * 2]
		; bx - ������� �����
		; ������ �� ����� - short, ��� ��� ����� �� ������ � ����� 2

		cmp ax, bx
		jge finish_cur_tail_update
		mov ax, bx

		finish_cur_tail_update:
		inc ecx
		jmp loop_tail

	ret_tail:
	pop ebx
	ret

; ������� �������� �������� �� ������� ����� ���� short
; len > 0
_max_short:
	mov eax, [esp + 4]
	mov [ARRAY], eax
	mov eax, [esp + 8]
	mov [LEN], eax

	cmp dword [LEN], 4
	jge not_only_tail
	
		; ���������� �� 1 �� 3 ���������
		push dword [LEN]
		push dword [ARRAY]
		mov edx, [ARRAY]
		push word [edx]
		; �������� �� ���� ������ �������
		call _process_tail
		add esp, 10
		; ����� �� ����� ��������� �������
		ret
		; � ax �����

	not_only_tail
	
		; �������������� ���������� ������ � ������ ������
		xor edx, edx
		mov eax, [LEN]
		mov ecx, 4
		div ecx
		mov [BLOCKS], eax
		mov [REM], edx
		
		; eax - ��������� �� ������ �������
		; mm0 - ������� 4 ������������ �������� (�������� �����)
		; ecx - ������� ������ ��� ��������
		mov eax, [ARRAY]
		movq mm0, [eax]
		mov ecx, 1

		; ���� ��������� �������� �����
		process_block:
			cmp ecx, [BLOCKS]
			jge blocks_processed
			
			; ����� �� 8, ��� ��� 4 ����� * 2 �����
			; mm1 - ������� 4 �������� (������� �����)
			movq mm1, [eax + ecx * 8]

			movq mm2, mm0
			pcmpgtw mm2, mm1
			; ������ mm2[i] = 0xFFFF, ���� mm0[i] > mm1[i], 
			; mm2[i] = 0x0000, ���� mm0[i] <= mm1[i]

			pand mm0, mm2
			; ��������� ������� �������� � �������� ������� (� �������� ������)

			pandn mm2, mm1
			; ���������� ��� �������� ������, ������ � mm2 �������� ������ ��������
			; �� �������� ������

			por mm0, mm2
			; ���������� ������
			
			inc ecx
			jmp process_block

		blocks_processed:
		; ���������� ��� ����� �� 4 ��������
		; ������� �������� �� 4 ����� ��������� ������

		; ���������� �� ����� ����� ��� 4 short'�� (4 * 2)
		sub esp, 16

		; �������� �� ���� 4 ����� �� ��������� ������
		; ��� ��������� � [esp] �� [esp + 16] ���, 
		; ��� [esp ... esp + 2) - ������ �����
		; [esp + 2 ... esp + 4) - ������ � ��
		movq [esp], mm0
		call _max_from_4
		add esp, 16
		; ������ �������� �� 4 ���������� (�� � ax)
		; ������ ���������� �����

		; edx - ��������� �� ������ �������,
		; �������� � ���� ����� ������������ ����
		mov edx, [ARRAY] 
		; edx - ��������� �� ������ ������
		lea edx, [edx + ecx * 8]

		push dword [REM]
		push edx
		push ax
		call _process_tail
		add esp, 10
		; ��������� �������� � ������, ����� �������� � ax
		; ��� � ���� ����� ��� ����� �������

		; �������� ��� mm-�������� ��� ��������� (��� ���������� ��������� ������)
		emms

		ret

section .data

	; ��������� �� ������ ������� short
	ARRAY : dd 0

	; ����� �������
	LEN : dd 0

	; ���������� "������" �� 4 �����
	BLOCKS : dd 0

	; ������� - ������ "������"
	REM : dd 0