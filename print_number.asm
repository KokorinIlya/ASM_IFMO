; ��������� �������� �� ����� �����, �������� � �������� eax

extern _printf
section .text
global _main_print

; ��������� ��������� buffer ������� ������ �������������� �����
; eax - ����� ������������� �����
_unsigned_number_to_string

	; ebx - ��������
	mov ebx, 10
	xor ecx, ecx

	; ���� ����� ����� �� ����� � ����� �� �� ���� � �������� �������
	; ecx - ���������� ���� � �����
	_digit_to_stack:
		xor edx, edx ; edx = 0
		div ebx ; edx | eax : ebx
		; eax = eax / 10
		; edx = eax % 10
		; � edx ������ ����� ��� ������� �� '0' �� '9'
		add edx, '0'
		; ����� ������� �� ����, ����� ����� ���� ����������� � �������� �������
		push edx
		inc ecx
		test eax, eax
	jnz _digit_to_stack

	xor ebx, ebx

	; ���� ������ ����� �� �����, �������������� �������� ������� 
	; � ���������� �� � buffer
	; ebx - ���������� ��� ���������� ����
	; edi - �������� � 1 ��� � 0 (��� �� ������� ����� ��� ���)
	_get_digit_from_stack:
		pop edx
		; ����� ����� �� '0' �� '9' �� ����� � �������� � ������ ��� ������� 8 ���
		mov [buffer + edi + ebx], dl
		inc ebx
		dec ecx
	jne _get_digit_from_stack

	; ��������� 0-���������� �� ��������� ������
	mov byte [buffer + edi + ebx], 0
	jmp _print
; ����� ���������

; ����� ����� � ���������
_main_print:
	; ����� �����
	mov eax, -2147483648

	; � �������� edi ������� �����, � �������� ���� ������ � buffer, ���������� 0
	xor edi, edi
	cmp eax, 0
	; ���� ����� �������������, ������� � ���������
	jge _start_processing
	; ���� ������������� - �������� � buffer '-' � ���������� edi = 1
	mov byte [buffer], '-'
	inc edi

	; �������� � eax ������ ����������� ��� �����
	mov edx, eax
	sar edx, 31
	xor eax, edx
	sub eax, edx
	; eax = |eax|

	_start_processing:
	jmp _unsigned_number_to_string

	; � ���� ������ � buffer �������� ��������� ����� �����
	; ��������������� printf ��� ������
	_print:
	push buffer
	push format
	call _printf
	add esp, 8
	ret

section .rdata
format : db "%s", 0xA, 0

section .data
; �������� �����, ����� ���������, ��� 0-���������� �������� 
; �� ������ ������� � ������ # �� ���������
;buffer : db "#####################"

section .bss
buffer : resb 20