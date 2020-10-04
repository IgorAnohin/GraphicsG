.model small
.data
xOffset dw 0
bitmask db 8
x dw 100
y1 dw 200
y2 dw 300
color db 12
len dw 640

.code
drawpixelv proc near uses ax bx dx cx
    ; Координаты преващаем в смещение

    mov ax, y1        ; select y
    mov dx, 80          ; 640 / 80 = 8 -> смещение в битах
    mul dx        ; ax = y * 80 -> смещение в байтах от y

    mov bx, xOffset   ; заранее посчитанный х
    add bx, ax        ; x + y => смещение

    ;---маскируем биты
    mov dx, 3CEh        ;указываем на адресный регистр
    mov al, 8            ;номер регистра
    out dx, al            ;посылаем его
    inc dx                ;указываем на регистр данных
    mov al, bitmask            ;маска
    out dx, al            ;посылаем данные

    ; Чистая магия. Без этого точки, а не линиии
    mov al, es:[bx]        ;читаем содержимое в задвижку

    ;---установка регистра маски карты для цвета
    mov dx, 3C4h          ;указываем на адресный регистр
    mov al, 2              ;индекс регистра маски карты
    out dx, al             ;установка адреса
    inc dx                ;указываем на регистр данных
    mov al, color        ;код цвета
    out dx, al            ;посылаем код цвета

    ;---рисуем точку
    mov al, 0FFh        ;любое значение с установленным 7 битом
    mov es:[bx], al        ;выводим точку

    ret
    drawpixelv endp

start:
; Init Adapter

mov ax, @data        ; настройка сегмента данных
mov ds, ax        ; через регистр ах
mov ax, 12h        ; VGA 640x480x256
int 10h                 ; Прерывание BIOS

; Init offset

mov ax, 0A000h    ; адрес видеопамяти
mov es, ax        ; устанавливаем сегментный регистр

mov bx, x
mov cl, bl
shr bx, 1               ; x // 8
shr bx, 1
shr bx, 1

mov xOffset, bx  ; запомнили смещение х

; Макска для них

and cl, 07h        ; bitmask mask
xor cl, 07h
mov ah, 01h
shl ah, cl
mov bitmask, ah

drawline: call drawpixelv
    inc y1
    mov bx, y1
    cmp bx, y2
    jle drawline

; Завершение

xor ax, ax        ;ожидание нажатия клавиши
int 16h

mov ax, 4C00h     ;выход из графики с возвратом
int 21h           ;в предыдущий режим
end start
