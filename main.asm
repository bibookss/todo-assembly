section .text
    global _start

_start:
    ; create file
    ; call create_file
    ; close_file

    ; print title
    mov eax, 4
    mov ebx, 1
    mov ecx, title
    mov edx, title_len
    int 0x80

    ; print prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; call todo 5 times
    call add_todo
    call add_todo
    call add_todo
    call add_todo
    call add_todo

    ; print to dos
    mov eax, 4
    mov ebx, 1
    mov ecx, list_prompt
    mov edx, list_prompt_len
    int 0x80

    call get_todos

    ; quit
    mov eax, 1
    xor ebx, ebx
    int 0x80
    

add_todo:
    call get_input
    call open_file_write
    call write_file
    call close_file

    ret

get_todos:
    call open_file_read
    call print_file
    call close_file

    ret

open_file_write:
    mov eax, 5
    mov ebx, file_name
    mov ecx, 0o20102
    mov edx, 0777
    int 0x80

    mov [fd], eax

    ret

open_file_read:
    mov eax, 5
    mov ebx, file_name
    mov ecx, 0x0 
    mov edx, 0644 
    int 0x80
    mov [fd], eax 
    
    ret

print_file:
    mov eax, 3
    mov ebx, [fd]
    mov ecx, items
    mov edx, 1024
    int 0x80

    mov eax, 4
    mov ebx, 1  
    mov ecx, items
    int 0x80


strlen:
    mov eax, 0 
    
    .loop:
        cmp byte [ecx], 0  ; check if current byte is null terminator
        je .done           ; if yes, terminate loop
        
        inc eax            ; increment length
        inc ecx            ; advance pointer to next byte
        jmp .loop          ; repeat until null terminator is found
        
    .done:
        ret


close_file:
    mov eax, 6
    mov ebx, [fd]
    int 0x80

    ret

write_file:
    ; move file pointer to end of file
    mov eax, 19          ; system call for lseek
    mov ebx, [fd]        ; file descriptor
    mov ecx, 0           ; offset from end of file (0 bytes)
    mov edx, 2           ; seek from end of file
    int 0x80             ; call system

    ; write item to file
    mov eax, 4
    mov ebx, [fd]
    mov ecx, item
    mov edx, [item_len]
    int 0x80

    ret

get_input:
    ; clear item buffer
    mov edi, item
    mov eax, 0
    mov ecx, 100
    rep stosb

    ; get input
    mov eax, 3
    mov ebx, 0
    mov ecx, item
    mov edx, 100
    int 0x80

    ; get length of input
    mov ecx, item
    call strlen
    mov [item_len], eax

    ret

print_item:
    ; print item
    mov eax, 4
    mov ebx, 1
    mov ecx, item
    mov edx, 100
    int 0x80

    ret


create_file:
    mov eax, 8
    mov ebx, file_name
    mov ecx, 0777 ; set file permission
    int 0x80      
    mov [fd], eax ; save file descriptor
    
    ret

print_prompt:
    ; print title
    mov eax, 4
    mov ebx, 1
    mov ecx, title
    mov edx, title_len 
    int 0x80

    ; print prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ret

section .data
    title db "TODO", 0xa
    title_len equ $-title
    
    prompt db "Enter 5 todos: ", 0xa
    prompt_len equ $-prompt
    
    list_prompt db "Your todos: ", 0xa
    list_prompt_len equ $-list_prompt

    file_name db "test.txt", 0
    file_name_len equ $-file_name

    item times 100 db 0
    item_len dd 0

    items times 1024 db 0

    counter db 1

section .bss
    fd resb 1
