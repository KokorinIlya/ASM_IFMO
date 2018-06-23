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

int main()
{
	unsigned short arr[] = 
		{ 37, 13, 14, 100, 1, 101, 3, 4, 1, 2, 3, 21, 65532, 25, 3, 1, 2, 65533 };
	unsigned short res = max_ushort(arr, 18);
	printf("%hu\n", res);
	return 0;
}
