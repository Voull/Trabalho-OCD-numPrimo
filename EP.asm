.text
.globl main
main:
        #Recebe entrada do usuário
        li $v0, 5
        syscall
        
        #Armazena o número recebido no registrador de entrada da função isPrime ($a0)
        move $a0, $v0
        
        #Chama a função primeSum
        jal sumPrime
        
        #Armazena o retorno da função primeSum no registrador ($a0)
        move $a0, $v0
        
        #Realiza o syscall para a impressão da resposta
        li $v0, 1
        syscall
        
        #Encerra o programa
        li $v0, 10
        syscall
        
#Verifica se o número no registrador de entrada ($a0) é primo. Será chamado de N.
#Recebe a sua entrada no registrador ($a0) e retorna no registrador ($v0).
#É necessário armazenar o endereço de retono no registrador ($a1).
isPrime:
	move $t0, $a0 #Salva o número N a ser testado.
	move $t1, $a1 #Salva o endereço de retorno.
	
	ble $t0, 1, false #Verifica se N é menor ou igual a 1, retornando 0 se verdadeiro.
	ble $t0, 3, true #Verifica se N é menor ou igual a 3, retornando 1 se verdadeiro.
	rem $t2, $t0, 2 #Verifica se N é divisível por 2, por meio do resto da divisão de N por 2, retornando 0 caso afirmativo
	beqz $t2, false
	rem $t2, $t0, 3 #Verifica se N é divisível por 3, por meio do resto da divisão de N por 3, retornando 0 caso afirmativo
	beqz $t2, false
	#Se nenhum dos brenches anteriores for satisfeito, a função buscará números M para testar a divisibilidade de N em M.
	li $t3, 5 #O registrador temporário armazenará os números M que seguirão o formato (6k +- 1)
	j loop

#Executa se N for primo, retornando 1
true:
	li $v0, 1
	jr $t1
	
#Executa se N não for primo, retornando 0
false:
	li $v0, 0
	jr $t1

#O laço loop testará a divisibilidade de N para todo M^2 <= N
loop:
	mul $t2, $t3, $t3 
	bgt $t2, $t0, true #Se M^2 > N, o laço é encerrado, retornando 1.
	rem $t2, $t0, $t3 #Se não, é verificado se M (6k - 1) divide N.
	beqz $t2, false #Se sim, N não é primo, retornando 0.
	move $t4, $t3 #Se não, será testado se M+2 (6k + 1) divide N.
	addi $t4, $t4, 2 #M+2 é armazenado em ($t4)
	rem $t2, $t0, $t4 
	beqz $t2, false #A mesma lógica do branch anterior se aplica
	addi $t3, $t3, 6 #Se N não é divisível por ambos M e M+2, M é incrementado por 6 (k ++)
	j loop #Finalmente o loop se reinicia.

#Entrada ($a0) será chamada de N e seu Retorno ($v0) será chamado de SUM
sumPrime:
	move $s0, $a0 #Salva o argumento
	#Os próximos dois branches verificam casos triviais.
	beq $s0, 1, is_1
	beq $s0, 2, is_2
	#Se N é maior do que 2, a função buscará os próximos N-2 números primos no formato (2k + 5)
	li $s1, 5 #Define SUM inicialmente com a soma dos dois primeiros números primos (2 e 3)
	addi $s0, $s0, -2 #Decrementa em 2 o valor de N (Ele será usado para definir quantos números primos restam ser encontrados)
	li $s2, 5 #O registrador ($s2) (Será chamado de AUX) armazenará o próximo número "candidato" a ser primo. 
		  #Inicialmente definido com o número 5 (k = 0)
	la $s3, isPrime #Salva o endereço da função isPrime para uso futuro
	
	#Para cada ciclo de while:
		#Verifica se N chegou a 0, significando que todos os primos necessários foram encontrados.
		#Chama a funcao isPrime para verificar se AUX é primo.
		#Testa o retorno de isPrime e aplica suas alterações de acordo com o mesmo.
	while:
		beqz $s0, return #Verifica se todos os primos foram encontrados, finalizando a função.
		move $a0, $s2 #Move AUX para o registrador de entrada da funcao isPrime ($a0)
		jalr $a1, $s3 #Chama a função isPrime, armazenando o endereço de retorno no registrador ($a1)
		bnez $v0, prime #Verifica o retorno de isPrime. Se 1, chama prime.
				#Se for igual a 1, AUX é primo e chama a laber prime.
		addi $s2, $s2, 2 #Caso contrário, apenas incrementa AUX para o próximo "candidato" a primo.
		j while #Finalmente, reinicia o loop.
		
		
	 is_1: 
	 	li $v0, 2 #Valor de retorno é definido como 2 (O primeiro primo)
	 	jr $ra #Retorna para o main.
	 
	 is_2:
	 	li $v0, 5 #Valor de retorno é definido como 5 (A soma dos dois primeiros numeros primos, 2 e 3)
	 	jr $ra  #Retorna para o main.
	
	return:
		move $v0, $s1 
		jr $ra  #Retorna para o main.
	
	#Se AUX for primo, os seguintes eventos ocorrerão:
		#AUX seja somado a SUM
		#N será decrementador em 1
		#AUX será incrementado em 2 (k++)
	prime:
		add $s1, $s1, $s2 #Adiciona AUX à SUM
		addi $s0, $s0, -1 #Decrementa N
		addi $s2, $s2, 2 #Incrementa AUX em 2 (k++)
		j while #Reinicia o ciclo while


