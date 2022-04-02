public convert_ubin

extrn num: word


DATASEG SEGMENT PARA PUBLIC 'DATA'
    out_msg db 'Converted number: $'
    binnum db 16 dup('0'), '$'

    mask2 dw 1
DATASEG ENDS


CODESEG SEGMENT PARA PUBLIC 'CODE'
    assume CS:CODESEG, DS:DATASEG

to_ubin:
    mov ax, num
    mov bx, 15          ; цикл по битам числа

    c_ubin:
        mov dx, ax

        and dx, mask2   ; побитовое И
        add dl, '0'     ; переводим в число

        mov binnum[bx], dl

        sar ax, 1       ; побитовый сдвиг вправо

        dec bx
        cmp bx, -1
        jne c_ubin

    ret


print_ubin:

    mov cx, 16
    mov bx, 0

    loop_out: 
        mov ah, 2
        mov dl, binnum[bx]

        inc bx
        int 21h
        
        loop loop_out
    ret


convert_ubin proc near
    mov dx, OFFSET out_msg
    mov ah, 9
    int 21h

    call to_ubin

    call print_ubin

    ret

convert_ubin endp

CODESEG ENDS
END