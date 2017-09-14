org 0x7c00 
jmp 0x0000:start

start:	
	xor ax, ax
	mov ds, ax
	
	resetDisk:
		mov ah, 0x00 ;reset
		int 0x13

		jc resetDisk

	readDisk:
		mov bx, 0x0050
		mov es, bx 	; segment
		mov bx, 0x0000  ; offset

		mov ah, 0x02 ; read
		mov al, 0x01 ; setors count
		mov ch, 0x00 ; track
		mov cl, 0x02 ; sector id
		mov dh, 0x00 ; head
		mov dl, 0x00 ; drive
		int 0x13

		jc readDisk

		jmp 0x0050:0x0000

times 510-($-$$) db 0		
dw 0xaa55


