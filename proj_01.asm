TITLE Plinio Zanchetta de Souza Fernandes Filho - 22023003
.MODEL SMALL
.DATA

operacao db 10,"Selecione a operacao: + - / *:$"
num1 db 10,"Primeiro numero da operacao:$"
num2 db 10,"Segundo numero da operacao:$"
resultado db 10,"Resultado:$"
error db 10,"Algo deu errado, tente novamente.$"

.CODE
    MAIN PROC
        MOV AX,@DATA        
        MOV DS,AX             
;=================================== Inicializando DATA
    start: 
        mov ah,09h
        lea dx,operacao
        int 21h
;=================================== Frase pedindo o operador
        mov ah,01h
        int 21h
        mov ch,al
;=================================== Movendo o char da operação para CH
        cmp ch,"+"
        jz cont
        cmp ch,"-"
        jz cont       
        cmp ch,"/"
        jz cont
        cmp ch,"*"
        jz cont
        mov ah,09h
        lea dx,error
        int 21h
        jmp start
;=================================== Verifica  o input da operação, caso seja inválido, print da mensagem de erro e pede a operação novamente, isso se repete até a operação ser válida
        cont:
        mov ah,09h
        lea dx,num1 
        int 21h
;=================================== Frase pedindo o primeiro número
        mov ah,01h
        int 21h
        cmp al,'-'
        jz prox
        cmp al,30h
        jb cont   
        cmp al,39h
        ja cont
prox: 
        cmp al,'-'
        jnz positivo
        int 21h
        cmp al,30h
        jb cont   
        cmp al,39h
        ja cont
        and al,0fh 
        neg al
        mov bh,al
        jmp next 
        positivo:
        mov bh,al 
        and bh,0fh 
next:
;=================================== Recebendo o primeiro input, controlando a entrada, apenas para números válidos,transformando em número e movendo para BH, caso seja negativo, nego e movo pra BH
        cont2:
        mov ah,09h
        lea dx,num2 
        int 21h
;=================================== Frase pedindo o segundo número
        mov ah,01h
        int 21h
        cmp al,'-'
        jz prox2 
        cmp al,30h 
        jb cont2 
        cmp al,39h
        ja cont2
prox2:
        cmp al,'-'
        jnz positivo2
        int 21h 
        cmp al,30h 
        jb cont2 
        cmp al,39h
        ja cont2 
        and al,0fh
        neg al
        mov bl,al  
        jmp next2
        positivo2: 
        mov bl,al 
        and bl,0fh 
next2:
;=================================== Recebendo o segundo input, controlando a entrada, apenas para números válidos, transformando em número e movendo para BL, caso seja negativo, nego e movo pra BL
        cmp ch,"+" 
        jnz not_soma
;=================================== Comparando para ver se a operação escolhida foi a soma, caso seja, executo a soma, caso contrário, pulo para verificar as outras
        add bh,bl
        mov cl,bh 
        js soma_neg_print
        mov bl,"+" 
        jmp print 
soma_neg_print: 
        neg cl 
        mov bl,"-" 
        jmp print   
        not_soma:
;=================================== Somo BH com BL, movo o resultado para CL, caso o sinal de CL seja negativo, movo o sinal de '-' para BL e jumpo para o print, caso o sinal de CL seja positivo, movo o sinal de '+' para BL e jumpo para o print
        cmp ch,"-"  
        jnz not_menos
;=================================== Comparando para ver se a operação escolhida foi a subtração, caso seja, executo a subtração, caso contrário, pulo para verificar as outras
        sub bh,bl
        mov cl,bh
        js sub_neg_print
        mov bl,"+"
        jmp print
sub_neg_print: 
        neg cl 
        mov bl,"-" 
        jmp print 
        not_menos:
;=================================== Subtraio BL de BH, movo o resultado para CL, caso o sinal de CL seja negativo, movo o sinal de '-' para BL e jumpo para o print, caso o sinal de CL seja positivo, movo o sinal de '+' para BL e jumpo para o print
        cmp ch,"*" 
        jnz not_mult
;=================================== Comparando para ver se a operação escolhida foi a multiplicação, caso seja, executo a multiplicação, caso contrário, pulo para verificar as outras
        xor cx,cx ;Resetando CX
        xor si,si ;Resetando SI para servir como contador
        shr bl,1  ;Desloco BL para a direita uma vez 
        jc primeiramul ;Checo se o desloquei um '1', olhando para o Carry     
        inc si ; Caso não tenha sido um '1', apenas incremento SI e jumpo para continuar a multiplicação
        jmp contmul 
primeiramul: 
        mov cl,bh  ; Caso tenha sido deslocado um '1', movo o conteúdo de BH para CL
        inc si  ; Incremento meu contador
contmul: 
        cmp si,8 ; Comparo se meu contador já é igual a 8, ou seja, já efetuei todos os deslocamentos necessários
        jz exitmul ;Se já efetuei os 8 deslocamentos, finalizo minha multiplicação                      
        shr bl,1 ;Caso não tenho efetuado as 8 vezes, desloco bl 1 casa para a direita 
        jc ummul ;ChecO se o bit deslocado foi um '1'
        shl bh,1 ;Caso não tenha sido, desloco BH uma casa para a esquerda
        inc si  ; E incremento o contador
        jmp contmul ;Volto para mais uma interação
ummul: ;Caso tenha sido deslocado um '1'
        shl bh,1 ;Desloco Bh uma casa para a esquerda
        add cl,bh ;Somo em CL o bh 
        inc si ; Incremento o contador
        jmp contmul ;Volto para mais uma interação                                                                            
exitMul: 
        test cl,cl ;Test apenas para checar os flags
        js mul_neg_print ;Caso CL contenha um número negativo jumpo 
        mov bl,"+" ;Caso CL contenha um número positivo, Movo o sinal de mais para BL, para depois printar
        jmp print ;Jumpo para printar meu resultado
mul_neg_print: ; Caso CL contenha um número negativo, executo
        neg cx ;Nego o conteúdo de CX, para transformar em um número positivo           
        mov bl,"-" ;Movo o sinal de menos para BL para printar
        jmp print ;Jumpo para printar o resultado
        not_mult: 
;=================================== Multiplicação de BH por BL, resultado em CL, caso CL seja negativo, movo o sinal de '-' para BL e dou um neg em CL e jumpo para o print, caso o sinal de CL seja positivo, movo o sinal de '+' para BL e jumpo para o print
        cmp ch,"/"
        jnz not_divi
;=================================== Comparando para ver se a operação escolhida foi a divisão, caso seja, executo a divisão   
        
        not_divi:
;===================================
    print:
        xor ch,ch ; Resetamos ch, pois nosso número está contido apenas em CL
        mov ax,cx ; Movemos CX para AX para podermos dividir por 10, pegando o resto e o quociente
        mov ch,10 ; Movemos 10 para ch, pois embaixo faremos AX ser dividido por CH ou seja, por 10
        div ch  ; Dividimos por 10, quociente está em AL, resto está em AH
        mov cl,al   ; Movemos o quociente de AL para CL, para printarmos
        mov ch,ah   ; Movemos o resto de AH para CH, para printarmos
        mov ah,09h  ; Função de printar string, para printar "Resultado: " na tela
        lea dx,resultado 
        int 21h
        mov ah,02h ; Movemos a função de printar um char, para printar o sinal que está em BL
        mov dl,bl ; Movemos o sinal de bl para dl para printarmos
        int 21h
        mov ah,02h 
        or cl,30h ;Transformamos o quociente em Char, ou seja, o número após o sinal. Exemplo: -87, Sinal = - ; Quociente = 8 ; Resto = 7
        mov dl,cl ;Movemos o quociente para dl, para printarmos 
        int 21h ; Printamos o quociente
        mov ah,02h 
        or ch,30h ;Transformamos o resto em Char
        mov dl,ch ;Movemos o resto para dl, para printarmos
        int 21h  ; Printamos o resto
;===================================  Print do resultado
        mov ah,4ch 
        int 21h
    MAIN ENDP
    END MAIN
;===================================  Finalizando o código
