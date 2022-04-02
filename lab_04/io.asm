; Этот модуль предназначен для ввода и ввода строк
; Строка должна заканчиватся символом $

PUBLIC input_str_from_stdin
PUBLIC print_str_to_stdout

EXTRN string:BYTE

CODESEG SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:CODESEG

input_str_from_stdin:
    mov ah, 10		
    lea dx, string	; как мув в офсетом 
    int 21h            ; вызываем прерывание для считывания строки в string

    ret                ; возвращаем управление вызывающей стороне
	
print_str_to_stdout:   ; Вывод строки на экран
	mov string + 1, 0ah  ; первые два байта - выводить все равно не надо, поэтому можно записать туда переход на новую строку
	
	mov dl, 10
	mov ah, 2
	int 21h
	mov bl, string + 5
	sub bl, 32
	mov dl, bl
    int 21h            ; вызываем прерывание для вывода строки
	
	ret
	
CODESEG ENDS
END
