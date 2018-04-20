#include <stdio.h>

int f()
{
	printf("%s", "hello");
	return 0;
}

void main_print();

float __cdecl arctan(float x, int k);

short* __cdecl ternary(short* cont, short* f, short* s);

int main()
{
	printf("%f\n", 4 * arctan(1, 400));

	short f[] = { 1, 2, 3, 4 };
	short s[] = { 5, 6, 7, 8};
	short c[] = { 0, 1, 0, 1};
	short* ans = ternary(c, f, s);
	for (int i = 0; i < 4; i++)
	{
		printf("%hu ", *(ans + i));
	}
	printf("\n");
	return 0;
}
