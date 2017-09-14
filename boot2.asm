org 0x0500
jmp 0x0000:start

str_a db "Loading structures for the kernel...", 13, 10, 0
str_b db "Setting up protected mode...", 13, 10, 0
str_c db "Loading kernel in memory...", 13, 10, 0
str_d db "Running kernel...", 13, 10, 0

start:

	xor ax, ax
	mov ds, ax

	mov si, str_a
	mov cl, 0

	print_str_a:
		lodsb
		cmp cl, al
		je end_print_str_a

		mov ah, 0xe
		mov bl, 0xf
		int 10h

		jmp print_str_a

	end_print_str_a:

	mov si, str_b

	print_str_b:
		lodsb
		cmp cl, al
		je end_print_str_b

		mov ah, 0xe
		mov bl, 0xf
		int 10h

		jmp print_str_b

	end_print_str_b:

	mov si, str_c

	print_str_c:
		lodsb
		cmp cl, al
		je end_print_str_c

		mov ah, 0xe
		mov bl, 0xf
		int 10h

		jmp print_str_c

	end_print_str_c:

	; load kernel in memory

	resetDisk:
		mov ah, 0h
		int 13h
		jc resetDisk

	readDisk:
		mov bx, 0x7e0
		mov es, bx
		mov bx, 0h

		mov ah, 2h ; read
		mov al, 6h ; setors count
		mov ch, 0h ; track
		mov cl, 3h ; sector id
		mov dh, 0h ; head
		mov dl, 0h ; drive
		int 13h
		jc readDisk
	
	; end load kernel in memory

	mov si, str_d
	mov cl, 0

	print_str_d:
		lodsb
		cmp cl, al
		je end_print_str_d

		mov ah, 0xe
		mov bl, 0xf
		int 10h

		jmp print_str_d

	end_print_str_d:

	; run kernel

	jmp 0x7e0:0x0

	; end run kernel

times 512-($-$$) db 0