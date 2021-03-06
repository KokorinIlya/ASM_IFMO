section .text
global _ternary

_ternary:

	; eax - ����� ������� ������� ���� (����������� ������������������), ������ �� �����
	; edx - ������� (������ ��������)
	; ecx - �������� (������ ��������)
	mov eax, [esp + 4]
	mov edx, [esp + 8]
	mov ecx, [esp + 12]

	; mm1 - ����������� ������������������ (cseq)
	; mm2 - ������ ������������������ ���� (f)
	; mm3 - ������ ������������������ ���� (s)
	; res[i] = (cseq[i] != 0x00) ? f[i] : s[i]
	movq mm1, [eax]
	movq mm2, [edx]
	movq mm3, [ecx]

	pcmpeqw mm1, [ZERO]
	; mm1[i] = 0xFF, ���� cseq[i] = 0x00
	; mm1[i] = 0x00, �����
	
	pand mm3, mm1
	; 1) ���� cseq[i] = 0x00, �� mm1[i] = 0xFF
	; ����� mm3[i] = mm3[i] & mm1[i] = mm3[i] & 0xFF = mm3[i] 
	; (�� ���� mm3[i] ������� ����������, ���� cseq[i] = 0x00).
	; 2) ���� cseq != 0x00, �� mm1[i] = 0x00, �����
	; mm3[i] = mm3[i] & mm1[i] = mm3[i] & 0x00 = 0
	; (�� ���� mm3[i] ����������, ���� cseq[i] != 0x00)

	; mm3 ������ ���������� ������ ������� ������ ������������������

	pandn mm1, mm2
	; 1) ���� cseq[i] = 0x00, �� mm1[i] = 0xFF, ����� ~mm1[i] = 0x00
	; ����� mm1[i] = mm2[i] & 0x00 = 0

	; 2) ���� cseq[i] != 0x00, �� mm1[i] = 0x00, ����� ~mm1[i] = 0xFF
	; ����� mm1[i] = mm2[i] & 0xFF = mm2[i]

	; �� ���� mm1 ������ ���������� ����������� ������� ������ ������������������ ����

	por mm1, mm3
	; ���������� ����������. mm1 = result

	; ���������� � ������ ������������ ����������
	movq [answer], mm1

	; ���������� ����� ������, ���� ������� ���������
	mov eax, answer

	; �������� ��� mm-�������� ��� ��������� (��� ���������� ��������� ������)
	emms

	ret

section .bss
	answer : resw 4

section .rdata
	ZERO : dw 0, 0, 0, 0