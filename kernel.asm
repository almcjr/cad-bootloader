org 0x7e00
jmp 0x0000:start

str_a db "Welcome to CAD! This is your startup screen to help you with the commands.", 13, 10, 0

str_b db  13, 10,"Movements:", 13, 10, 10, "- Down 'x'", 13, 10, "- Up 'w'", 13, 10, "- Right 'd'", 13, 10, "- Left 'a'",  13, 10, "- Down right 'c'", 13, 10, "- Down left 'z'", 13, 10, "- Up right 'r'", 13, 10, "- Up left 'q'", 13, 10, 10, "To paint the pixel at the current position press 's', and to hold the painting while moving, keep 'shift' pressed or active the 'Caps Lock' key. ", 13, 10, 10, "Brush:", 13, 10, 10, "- Incrase speed (pixel per click) '+'", 13, 10, "- Decrease speed (pixel per click) '-'", 13, 10, "- Alternate brush aparence 'p'", 13, 10, 10, "Others: ", 13, 10, 10, "- Reset board '<'", 13, 10, "- Quit 'Esc'", 13, 10, 10, "Press any key to continue...", 13, 10, 0

str_c db "Colors: ", 13, 10, 10, "- Black '1'", 13, 10, "- Blue '2'", 13, 10, "- Green '3'", 13, 10, "- Cyan '4'", 13, 10, "- Red '5'", 13, 10, "- Magenta '6'", 13, 10, "- Brown '7'", 13, 10, "- Light Gray '8'", 13, 10, "- Dark Gray '9'", 13, 10, "- Light Blue '0'", 13, 10, "- Light Green ''''", 13, 10, "- Light Cyan '!'", 13, 10, "- Light Red '@'", 13, 10, "- Light Magenta '#'", 13, 10, "- Yellow '$'", 13, 10, "- White '%'", 13, 10, 10, "Developers:", 13, 10, 10, "Almir Menezes da Cunha Junior - amcj2@cin.ufpe.br", 13, 10, "Daniel Henrique Amorim Correia - dhac@cin.ufpe.br", 13, 10, 10, "Press any key to start...", 13, 10, 0

current_color db "Current color: ", 0
current_speed db "Current speed: ", 0

speed dw 1 ; movement's speed
color db 0x0; color parameter to paint
user_color db 0xf ; user paint color
under_color db 0x0 ; color under the brush
brush_color db 0xf ; brush color
up dw 20 ; max up movement
down dw 479 ; max down movement
right dw 639 ; max right movement
left dw 1 ; max left movement

i dw 0 ; loop's variable 
j dw 0 ; loop's variable
temp1 dw 0
temp2 dw 0

start:

	xor ax, ax
	mov ds, ax

	mov ah, 0 
    mov al, 12h
    int 10h

    mov cl, 0

    mov si, str_a
    call print_str ; print string a

    mov si, str_b
    call print_str ; print string b

    mov ah, 0
    int 16h 

    mov ah, 0 ; other page
    mov al, 12h
    int 10h

    mov si, str_c
    call print_str ; print string c

    mov ah, 0
    int 16h

    mov ah, 0
    mov al, 12h
    int 10h

    mov cl, 0
    mov si, current_color
    call print_str

    mov ah, 2 ; cursor positioning
    mov bh, 0
    mov dh, 0
    mov dl, 20
    int 10h

    mov si, current_speed
    call print_str

    mov dx, 240 ; cursor to middle of screen
    mov cx, 320 

    call color_screen

    call speed_screen

    jmp control ; start control

    speed_screen:
        mov word [temp1], dx
        mov word [temp2], cx

        mov al, byte [speed]

        cmp al, 10
        jge converter

        add al, 48

        mov ah, 2
        mov bh, 0
        mov dh, 0
        mov dl, 35
        int 10h

        mov ah, 0xe 
        mov bl, 0xf
        int 10h

        xor al, al

        mov ah, 0xe 
        mov bl, 0xf
        int 10h

        jmp end_speed_screen

        converter:
            xor ah, ah

            mov bh, 10
            div bh

            add al, 48 
            mov cl, ah
            add cl, 48

            mov ah, 2
            mov bh, 0
            mov dh, 0
            mov dl, 35
            int 10h

            mov ah, 0xe
            mov bl, 0xf
            int 10h

            mov al, cl

            mov ah, 0xe
            mov bl, 0xf
            int 10h

    end_speed_screen:
        mov dx, word [temp1]
        mov cx, word [temp2]

        pop ax
        jmp ax

    print_str:
        lodsb
        cmp cl, al
        je end_print_str

        mov ah, 0xe
        mov bl, 0xf
        int 10h

        jmp print_str

    end_print_str:
        pop ax
        jmp ax

    color_screen:
        mov word [temp1], dx
        mov word [temp2], cx

        mov cx, 115
        mov dx, 2
        
        mov bx, 10
        mov word [j], bx 

        cc_col:
            cmp word [j], 0
            je cc_col_end

            mov bx, 10
            mov word [i], bx
            mov cx, 115

            cc_row:
                cmp word [i], 0
                je cc_row_end

                mov bl, byte [user_color]
                mov byte [color], bl

                call paint

                inc cx

                mov bx, word [i]
                dec bx
                mov word [i], bx

                jmp cc_row

            cc_row_end:

            inc dx

            mov bx, word [j]
            dec bx
            mov word [j], bx

            jmp cc_col

        cc_col_end:

        mov dx, word [temp1]
        mov cx, word [temp2]

        pop ax
        jmp ax

    control:
	    mov ah, 0
	    int 16h

	    mov bx, word [speed]
	    mov word [i], bx ; the paint loop's index variable receives the speed to paint a sequece of pixels through some vector defined by user's input controller 

	    ; paint controllers (to control the cursor while painting); 

        cmp al, 73h ; "s"
        je paint_dot

	    cmp al, 58h ; 'X'
	    je paint_down

	    cmp al, 57h ; 'W'
	    je paint_up

	    cmp al, 44h ; 'D'
	    je paint_right

	    cmp al, 41h ; 'A'
	    je paint_left

	    cmp al, 43h ; 'C'
	    je paint_down_right

	    cmp al, 0x5a ; 'Z'
	    je paint_down_left

	    cmp al, 45h ; 'E'
	    je paint_up_right

	    cmp al, 51h ; 'Q'
	    je paint_up_left

	    ; end paint controllers ;


        ; color ;

        cmp al, 31h ; '1' Cor = Black
        je colorBlack
        
        cmp al, 32h;  '2' Cor = Blue
        je colorBlue
        
        cmp al, 33h;  '3'Cor = Green
        je colorGreen

        cmp al, 34h;  '4'Cor = Cyan
        je colorLGreen

        cmp al, 35h;  '5' Cor = Red 
        je colorCyan

        cmp al, 36h;  '6'Cor = Magenta
        je colorMagenta

        cmp al, 37h;  '7'Cor = BRown
        je colorBrown

        cmp al, 38h;  '8'Cor = Light Gray
        je colorLGray

        cmp al, 39h;  '9'Cor = Dark Gray
        je colorDGray

        cmp al, 30h;  '0'Cor = Light Blue
        je colorLBlue

        cmp al, 22h;  '"'Cor = Light Green
        je colorLGreen

        cmp al, 21h;  '!'Cor = Light Cyan
        je colorLCyan

        cmp al, 40h;  '@'Cor = Light REd
        je colorRed

        cmp al, 23h;  '#'Cor = Light MAgenta
        je colorLMagenta

        cmp al, 24h;  '$'Cor = Yellow
        je colorYellow

        cmp al, 25h;  '%'Cor = white
        je colorWhite

        ; end color ;


	    ; movement cursor (to control the cursor without painting);

        cmp al, 78h ; 'x'
        je move_down

        cmp al, 77h ; 'w'
        je move_up

        cmp al, 64h ; 'd'
        je move_right

        cmp al, 61h ; 'a'
        je move_left

        cmp al, 63h ; 'c'
        je move_down_right

        cmp al, 0x7a ; 'z'
        je move_down_left

        cmp al, 65h ; 'e'
        je move_up_right

        cmp al, 71h ; 'q'
        je move_up_left

	    ; end moviment cursor ;


        ; brush color alternate ;

        cmp al, 70h ; 'p'
        je brush_color_change

        ; end brush color alternate ;


        ; change speed ;

        cmp al, 0x2b ; '+'
        je more_vel

        cmp al, 0x2d ; '-'
        je less_vel

        ; end change speed ;


	    ; reset board (to erase all on the board);

        cmp al, 0x3c ; '<'
        je reset_board

	    ; end reset board ;


	    ; save (to save the project on hda (will be loaded by the kernel on startup));

	    ; end save ;


        ; help ;

        ; end help ;


	    ; quit (to quit);

        cmp al, 0x1b
        je quit

	    ; end quit ;

	    jmp control ; no key recognized


	; paint actions ; 

    paint_dot:
        mov bl, byte [user_color]
        mov byte [under_color], bl

        mov bl, byte [brush_color]
        mov byte [color], bl
        call paint

        jmp control

    paint_down:
    	cmp dx, word [down] ; vertical down limit to paint
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	inc dx ; movement 

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint ; paint pixel and back

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_down_end ; if loop's reched the max speed, then, end loop

    	dec bx 
    	mov word [i], bx ; else, decrement the loop's index variable

    	jmp paint_down

    	paint_down_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_up:
    	cmp dx, word [up] 
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	dec dx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_up_end

    	dec bx
    	mov word [i], bx

    	jmp paint_up

    	paint_up_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_right:
    	cmp cx, word [right] 
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	inc cx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_right_end

    	dec bx
    	mov word [i], bx

    	jmp paint_right

    	paint_right_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_left:
    	cmp cx, word [left] 
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	dec cx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_left_end

    	dec bx
    	mov word [i], bx

    	jmp paint_left

    	paint_left_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_down_right:
    	cmp dx, word [down]
    	je control

    	cmp cx, word [right]
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	inc dx
    	inc cx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_down_right_end

    	dec bx
    	mov word [i], bx

    	jmp paint_down_right

    	paint_down_right_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_down_left:
    	cmp dx, word [down]
    	je control

    	cmp cx, word [left]
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	inc dx
    	dec cx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_down_left_end

    	dec bx
    	mov word [i], bx

    	jmp paint_down_left

    	paint_down_left_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_up_right:
    	cmp dx, word [up]
    	je control

    	cmp cx, word [right]
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	dec dx
    	inc cx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_up_right_end

    	dec bx
    	mov word [i], bx

    	jmp paint_up_right

    	paint_up_right_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint_up_left:
    	cmp dx, word [up]
    	je control

    	cmp cx, word [left]
    	je control

        mov bl, byte [under_color]
        mov byte [color], bl ; paint dot with original color (under_color)

        call paint

    	dec dx
    	dec cx

        mov bl, byte [user_color]
        mov byte [color], bl

    	call paint

        mov bl, byte [user_color]
        mov byte [under_color], bl

    	mov bx, word [i]
    	cmp bx, 1
    	je paint_up_left_end

    	dec bx
    	mov word [i], bx

    	jmp paint_up_left

    	paint_up_left_end:
            mov bl, byte [brush_color]
            mov byte [color], bl

            call paint

    		jmp control

    paint:
    	mov ah, 0xc
	    mov bh, 0
	    mov al, byte [color]
	    int 10h

	    pop ax
	    jmp ax

	; end paint actions ;


    ; color actions ;

    colorBlack:
    mov byte[user_color], 0
    call color_screen
    jmp control

    colorBlue:
    mov byte[user_color], 1
    call color_screen
    jmp control
    
    colorGreen:
    mov byte[user_color], 2
    call color_screen
    jmp control

    colorCyan:
    mov byte[user_color], 3
    call color_screen
    jmp control
    
    colorRed:
    mov byte[user_color], 4
    call color_screen
    jmp control

    colorMagenta:
    mov byte[user_color], 5
    call color_screen
    jmp control
    
    colorBrown:
    mov byte[user_color], 6
    call color_screen
    jmp control

    colorLGray:
    mov byte[user_color], 7
    call color_screen
    jmp control

    colorDGray:
    mov byte[user_color], 8
    call color_screen
    jmp control

    colorLBlue:
    mov byte[user_color], 9
    call color_screen
    jmp control 

    colorLGreen:
    mov byte[user_color] , 10
    call color_screen
    jmp control
    
    colorLCyan:
    mov byte[user_color], 11
    call color_screen
    jmp control

    colorLRed:
    mov byte[user_color], 12
    call color_screen
    jmp control

    colorLMagenta:
    mov byte[user_color], 13
    call color_screen
    jmp control

    colorYellow:
    mov byte[user_color], 14
    call color_screen
    jmp control

    colorWhite:
    mov byte[user_color], 15
    call color_screen
    jmp control

    ; end color actions ;


    ; movement cursor actions ;

    move_down:
        cmp dx, word [down]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl

        call paint

        inc dx ; move

        mov ah, 0x0d
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_down_end

        dec bx
        mov word [i], bx

        jmp move_down

        move_down_end:
            jmp control

    move_up:
        cmp dx, word [up]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl

        call paint

        dec dx ; move

        mov ah, 0x0d 
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_up_end

        dec bx
        mov word [i], bx

        jmp move_up

        move_up_end:
            jmp control

    move_right:
        cmp cx, word [right]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl

        call paint

        inc cx ; move

        mov ah, 0x0d ; get new under_color
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_right_end

        dec bx
        mov word [i], bx

        jmp move_right

        move_right_end:
            jmp control

    move_left:
        cmp cx, word [left] 
        je control

        mov bl, byte [under_color]
        mov byte [color], bl 

        call paint

        dec cx ; move

        mov ah, 0x0d 
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_left_end

        dec bx
        mov word [i], bx

        jmp move_left

        move_left_end:
            jmp control

    move_down_right:
        cmp dx, word [down]
        je control

        cmp cx, word [right]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl 

        call paint

        inc cx
        inc dx

        mov ah, 0x0d ; get new under_color
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_down_right_end

        dec bx
        mov word [i], bx

        jmp move_down_right

        move_down_right_end:
            jmp control

    move_down_left:
        cmp dx, word [down]
        je control

        cmp cx, word [left]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl 

        call paint

        dec cx
        inc dx

        mov ah, 0x0d ; get new under_color
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_down_left_end

        dec bx
        mov word [i], bx

        jmp move_down_left

        move_down_left_end:
            jmp control

    move_up_right:
        cmp dx, word [up]
        je control

        cmp cx, word [right]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl 

        call paint

        inc cx
        dec dx

        mov ah, 0x0d ; get new under_color
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_up_right_end

        dec bx
        mov word [i], bx

        jmp move_up_right

        move_up_right_end:
            jmp control

    move_up_left:
        cmp dx, word [up]
        je control

        cmp cx, word [left]
        je control

        mov bl, byte [under_color]
        mov byte [color], bl 

        call paint

        dec cx
        dec dx

        mov ah, 0x0d ; get new under_color
        mov bh, 0
        int 10h 

        mov byte [under_color], al

        mov bl, byte [brush_color]
        mov byte [color], bl

        call paint

        mov bx, word [i]
        cmp bx, 1
        je move_up_left_end

        dec bx
        mov word [i], bx

        jmp move_up_left

        move_up_left_end:
            jmp control  

    ; end movement cursor actions ;


    ; change velocity actions ;

    more_vel:
        cmp word [speed], 99
        je control

        mov bx, word [speed]
        inc bx      
        mov word [speed], bx

        call speed_screen

        jmp control

    less_vel:
        cmp word [speed], 1
        je control

        mov bx, word [speed]
        dec bx
        mov word [speed], bx

        call speed_screen

        jmp control

    ; end change velocity actions ;


    ; brush color alternate actions;

    brush_color_change:
        cmp byte [brush_color], 0xf
        je brush_green

        mov byte [brush_color], 0xf
        mov byte [color], 0xf
        call paint
        jmp control

        brush_green:
            mov byte [brush_color], 1
            mov byte [color], 1
            call paint
            jmp control

    ; end brush color alternate actions ;


    ; reset board actions ;

    reset_board:
        mov ah, 0
        mov al, 12h
        int 10h

        mov cl, 0
        mov si, current_color
        call print_str

        mov ah, 2 ; cursor positioning
        mov bh, 0
        mov dh, 0
        mov dl, 20
        int 10h

        mov cl, 0
        mov si, current_speed
        call print_str

        mov dx, 240 
        mov cx, 320 

        call color_screen 
        call speed_screen

        mov byte [under_color], 0x0

        jmp control

    ; end reset board actions ;


    ; quit actions ;

    quit:
        mov ax, 5307h
        mov cx, 3
        mov bx, 1
        int 15h

    ; end quit actions ;

jmp $
times 3072-($-$$) db 0 
