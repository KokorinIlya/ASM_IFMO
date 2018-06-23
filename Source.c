#include <stdio.h>

int f()
{
	printf("%s", "hello");
	return 0;
}

void main_print();

float __cdecl arctan(float x, int k);

short* __cdecl ternary(short* cont, short* f, short* s);

float __cdecl arctan_scalar(float x, int k);

void __cdecl print(char *out_buf, const char *format, const char *hex_number);

short __cdecl max_short(const short* ptr, int len);

unsigned short __cdecl max_ushort(const unsigned short* ptr, int len);

void __cdecl vector_mul(int* result, const short* a, const short* b);

int main()
{
	short a[] = { 10000, 15000, 20000, 25000 };
	short b[] = { 10000, 15000, 20000, 25000 };
	int res[4];

	vector_mul(res, a, b);
	for (int i = 0; i < 4; i++)
	{
		printf("%i ", res[i]);
	}
	return 0;
}
