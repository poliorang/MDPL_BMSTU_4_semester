extrn input_number: near
extrn num: word

extrn convert_ubin: near
extrn convert_shex: near


STK SEGMENT PARA STACK 'STACK'
    db 150 dup (?)
STK ENDS


DATASEG SEGMENT PARA PUBLIC 'DATA'
    menu_msg db "Menu", 10, 10, 13
             db "1. Input number - unsigned octal", 10, 13
             db "2. Convert to unsigned binary and print", 10, 13
             db "3. Convert to signed hexidemical and print", 10, 13
             db "4. Exit", 10, 10, 13
             db "Input action: $"
    ; каждая переменная по 2 байта (тк dw - word - 2 байта)
    menu_ptr dw input_number, convert_ubin, convert_shex, exit
    mess_incorrect_res DB 10, 'Incorrect result', 10, '$'
DATASEG ENDS


CODESEG SEGMENT PARA PUBLIC 'CODE'
    assume CS:CODESEG, DS:DATASEG, SS:STK

new_str:
    mov ah, 2
    mov dl, 13
    
    int 21h
    mov dl, 10
    int 21h

    ret

input_action:
    mov ah, 1
    int 21h

    sub al, "1"
    
    mov dl, 2
    mul dl

    ret


exit proc near      ; proc - начало процедуры (логично)
    mov ax, 4c00h
    int 21h
exit endp           ; endp - окончание процедуры


main:
    mov ax, DATASEG
    mov ds, ax

    call_menu:
        mov ah, 9
        mov dx, OFFSET menu_msg
        int 21h

        call input_action

        mov bx, ax

        call new_str
        call new_str

        add bx, "1"     ; обратно в код


        ; не больше ли 7, потому что 4 переменных в menu_ptr по 2 байта
        ; bx может принимать значения 0, 2, 4, 6
        cmp bx, "7"     ; не больше ли 4ки
        jg call_menu    ; если больше, скипаем, опять меню

        sub bx, "1"     ; обратно в цифру

        call menu_ptr[bx]

        call new_str
        call new_str

    jmp call_menu

CODESEG ENDS
END main
