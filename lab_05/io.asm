; Этот модуль предназначен для ввода и ввода строк
; Строка должна заканчиватся символом $
; Для ввода и вывода адрес строки должен при вызове находится в регистре bx

PUBLIC input_digit_from_stdin

PUBLIC print_str_to_stdout
PUBLIC print_char_to_stdout
PUBLIC print_digit_to_stdout


CODESEG SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:CODESEG


print_str_to_stdout:   ; вывод строки на экран
	mov ah, 9
    mov dx, bx
    int 21h            ; вызываем прерывание для вывода строки
	
	ret
	
print_char_to_stdout:
	mov ah, 2
	mov dl, bl
	int 21h
	
	ret
	
input_digit_from_stdin: 
	mov ah, 1
	int 21h
	sub al, 30h        ; изменяем представление чисела с ascii-кода на реальное число
	
	ret                ; считанная цифра будет лежать в al
	
print_digit_to_stdout:
	mov ah, 2
	add bl, 30h        ; возвращаемся из представления чисел в представлние ascii-кода
	mov dl, bl
	int 21h
	
	ret
	
CODESEG ENDS
END
