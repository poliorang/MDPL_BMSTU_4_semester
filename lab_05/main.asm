; Модуль содержит в себе основную часть программы


EXTRN input_digit_from_stdin:far

EXTRN print_str_to_stdout:far
EXTRN print_digit_to_stdout:far
EXTRN print_char_to_stdout:far

STACKSEG SEGMENT PARA STACK 'STACK'
	DB 300h dup('$')
STACKSEG ENDS

DATASEG SEGMENT 'messages'
    mess_input_count_rows DB 10, 'Input count rows: ', '$'
	mess_input_count_cols DB 10, 'Input count columns: ', '$'
	mess_input_matrix DB 10, 'Input matrix:', 13, 10, '$'
	mess_find_min_elem DB 10, 'Find min elem: ', '$'
	mess_col_min_elem DB 10, 'Row with min elem: ', '$'
	mess_result DB 10, 10, 'Result:', 13, 10, '$'
	mess_empty_res DB 10, 'Empty result', 10, '$'
	mess_error_input_rows DB 10, 10, 'ERROR: invalid input count rows [int > 0 & < 10]', 10, '$'
	mess_error_input_cols DB 10, 10, 'ERROR: invalid input count columns [int > 0 & < 10]', 10, '$'
DATASEG ENDS

DATASEG SEGMENT 'data'
    count_rows DB ?     ; неинициализированное значение
	count_columns DB ?
	matrix DB 9 * 9 dup (?)
DATASEG ENDS

DATASEG SEGMENT 'auxiliary_variables'
    min_elem DB ?
	ind_row DB ?
DATASEG ENDS

CODESEG SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:CODESEG, DS:DATASEG

error_input_count_rows:
	lea bx, mess_error_input_rows        
	call print_str_to_stdout

	mov ah, 4Ch
	int 21h  

error_input_count_cols:
	lea bx, mess_error_input_cols        
	call print_str_to_stdout

	mov ah, 4Ch
	int 21h    

empty_res:
    lea bx, mess_empty_res        
	call print_str_to_stdout

	mov ah, 4Ch
	int 21h 

main:
	mov ax, DATASEG
    mov ds, ax 
	
	; ВВОД КОЛИЧЕСТВА СТРОК
	lea bx, mess_input_count_rows         
	call print_str_to_stdout              ; вывод приглашения для ввода количества строк
	
	call input_digit_from_stdin           ; вызов подпрограммы считывающей символ с клавиатуры
	mov count_rows, al                    ; сохранили считанное значение

	cmp count_rows, 0                     ; проверка на валидность
	je error_input_count_rows
	
	; ВВОД КОЛИЧЕСТВА СТОЛБЦОВ
	lea bx, mess_input_count_cols        
	call print_str_to_stdout              ; вывод приглашения для ввода количества столбцов
	
	call input_digit_from_stdin           ; вызов подпрограммы считывающей символ с клавиатуры
	mov count_columns, al                 ; сохранили считанное значение

	cmp count_columns, 0                  ; проверка на валидность
	je error_input_count_cols

	; ВВОД МАТРИЦЫ
	lea bx, mess_input_matrix            
	call print_str_to_stdout              ; вывод приглашения для ввода количества столбцов

	mov ch, 0                             ; ch - счетчик по строкам
	mov si, 0                             ; si - счетчик по строкам (в формате ind + 9 * ch)
	input_row: 
		mov bx, 0                         ; bx - счетчик по столбцам
		mov cl, 0                         ; cl - счетчик по столбцам
		input_col:
			mov ah, 1                     ; считали
			int 21h

			mov matrix[si][bx], al        ; поместили в матрицу
			inc bx

			mov ah, 2                     ; напечатали пробел
			mov dl, ' '
			int 21h

			inc cl
			cmp cl, count_columns
			jne input_col

		mov ah, 2                         ; напечатали /n
		mov dl, 10
		int 21h

		add si, 9

		inc ch
		cmp ch, count_rows
		jne input_row

	cmp count_rows, 1                  ; обработка пустого результата
	je empty_res
	
	; ПОИСК МИНИМАЛЬНОГО ЭЛЕМЕНТА
	mov si, 0                             ; si - индекс строки в исходной матрице
	mov bx, 0
	mov al, matrix[si][bx]
	mov min_elem, al

	mov ch, 0

	find_min_elem_row:
		mov cl, 0
		find_min_elem_col:
			mov al, matrix[si][bx]
			cmp min_elem, al
			jle next

			mov al, matrix[si][bx]
            mov min_elem, al
      		mov ind_row, ch

            next:
                inc bx
                inc cl
                cmp cl, count_columns
                jne find_min_elem_col

		mov bx, 0
		add si, 9

		inc ch
		cmp ch, count_rows
		jne find_min_elem_row

	; ВЫВОД ПОЯСНЯЮЩИХ СООБЩЕНИЙ ДЛЯ НАЙДЕННЫХ ЗНАЧЕНИЙ
	lea bx, mess_find_min_elem
	call print_str_to_stdout

	mov bl, min_elem
	call print_char_to_stdout

	lea bx, mess_col_min_elem
	call print_str_to_stdout

	mov bl, ind_row
	call print_digit_to_stdout

	;УДАЛЯЕМ СТОЛБЕЦ
	mov ch, 0           ; ch - счетчик по строкам
	mov bx, 0           ; bx - счетчик по столбцам
	mov si, 0           ; si - индекс строки в исходной матрице
    mov di, 0           ; di - индекс строки в новой матрице
    ; di и si ведутся разные, потому что одна строка будет удалена, в какой-то они момент разойдутся

	del_row:
    	cmp ind_row, ch
        je next_row

		mov cl, 0
		mov bx, 0

		del_col:
			mov al, matrix[si][bx]          ; взять значение из старой матрицы
			mov matrix[di][bx], al      ; записать значение в новую матрицу

			inc bx
            inc cl

            cmp cl, count_columns
            jne del_col

        add di, 9
		next_row:
		    add si, 9

            inc ch
			cmp ch, count_rows
			jne del_row

	; ВЫВОД МАТРИЦЫ
	lea bx, mess_result          
	call print_str_to_stdout

	mov ch, 0                    ; ch - счетчик по строкам
	mov si, 0                    ; si - индекс  строки
	inc ch
	print_row: 
		mov bx, 0                 ; bx - индекс столбца
		mov cl, 0                 ; сl - счетчик по столбцам
		print_col:
			mov ah, 2
			mov dl, matrix[si][bx]
			int 21h

			mov dl, ' '
			int 21h

			inc bx

			inc cl
			cmp cl, count_columns
			jne print_col

		add si, 9

		mov ah, 2
		mov dl, 10
		int 21h

		inc ch
		cmp ch, count_rows
		jne print_row

	mov ah, 4Ch
	int 21h            ; завершаем программу
	
CODESEG ENDS
END main