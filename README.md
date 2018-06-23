# ASM_IFMO

# Домашние задания и лабораторные по курсу "Ассемблер" в университете ИТМО

## Домашнее задание № 1
Вывести на экран "Hello, world", воспользовавшись функцией printf из стандартной библиотеки языка C

[Решение](test.asm)

## Домашнее задание № 2
Вывести на экран 32-х битное знаковое число, воспользовавшись функцией printf из стандартной библиотеки языка C

[Решение](print_number.asm)

## Домашнее задание № 3
Посчитать сумму k первых членов разложения функции arctg(x) в ряд Тейлора с помощью математического сопроцессора (FPU)

[Решение](arctan.asm)

## Домашнее задание № 4
Реализовать с помощью mmx тернатный оператор:

res[i] = (cseq[i] != 0x00) ? f[i] : s[i],

где s и f - последовательности слов, cseq[i] - управляющая последовательность слов

[Решение](mmx_ternary.asm)

## Домашнее задание № 5
Посчитать сумму k первых членов разложения функции arctg(x) в ряд Тейлора с помощью скалярных операций с SSE

[Решение](arctan_scalar.asm)

## Домашнее задание № 6
Найти максимум в массиве из чисел типа short. Для поиска максимума использовать SIMD-расширение MMX.

[Решение](max_short.asm)
