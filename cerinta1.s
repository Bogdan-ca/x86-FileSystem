.data 
    nrOperatii: .space 4 #declararea numarului de operatii
    vector: .space 4096, 0 #declararea vectorului si initializarea cu 0
    formatScanf: .asciz "%d"
    lungimeVector: .long 0 #declararea lungimii vectorului
    operatie: .long 0 #citirea operatiei
    copiecontor: .long 0 #declararea copiei contorului

    #variabile pentru operatia de add
    nrfisiere: .long 0
    descriptor: .long 0 
    lungime: .long 0
    variabila: .long 0
    formatPrintfadd: .asciz "%d: (%d, %d)\n"

    #variabile pentru operatia de get
    nrdescriptor: .long 0
    formatPrintfget: .asciz "(%d, %d)\n"

    #variabile pentru operatia de delete
    descriptordelete: .long 0

.text
.global main
main:
    push $nrOperatii #citirea numarului de operatii
    push $formatScanf
    call scanf
    pop %ebx
    pop %ebx
    mov $0, %ecx         #initializeaza contorului cu 0 
    mov $vector, %edi   #initializeaza vectorul cu adresa de inceput
prelucrare_operatii:
    cmp %ecx, nrOperatii    #compara contorul cu numarul de operatii
    je exit                
    push %ecx              #salvare contor
    push $operatie       #citirea operatiei
    push $formatScanf
    call scanf
    pop %ebx
    pop %ebx
    pop %ecx
    mov operatie, %eax
    cmp $1, %eax    #face operatia de add
    je pregatire_add
    cmp $2, %eax    
    je pregatire_get          #face operatia de get 
    cmp $3, %eax    
    je pregatire_delete        #face operatia de delete
    cmp $4, %eax  
    je pregatire_defrag        #face operatia de defrag

pregatire_add:

    mov %ecx, copiecontor #salvam contorul pentru numarul de fisiere in copiecontor
    push $nrfisiere #citirea numarului de fisiere
    push $formatScanf
    call scanf
    pop %ebx
    pop %ebx
    xor %ebp, %ebp

    et_add_citire:
        cmp %ebp, nrfisiere #folosim ebp pentru a numara cate fisiere am citit
        je et_restabilire_contor #daca am citit toate fisierele trecem la urmatoarea operatie
        #citire descriptor
        push $descriptor 
        push $formatScanf
        call scanf
        pop %ebx
        pop %ebx

        #citire lungime descriptor
        push $lungime
        push $formatScanf
        call scanf
        pop %ebx
        pop %ebx
        
        #determinarea spatiilor ocupate de descriptor
        xor %edx, %edx
        mov lungime, %eax
        mov $8, %ebx
        div %ebx
        mov %eax, %ebx #mutam in ebx cati octeti sunt ocupati de descriptor

        inc %ebp #incrementam contorul de fisiere
        xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului
        xor %esi, %esi #initializam contorul pentru numararea elementelor cu zero succesive


        #prelucrarea cazului cand restul impartirii este diferit de 0
        cmp $0, %edx #daca restul impartirii este 0 sarim peste impartire_rest 
        je parcurgere_vector    #deoarece descriptorul ocupa un numar fix de spatii

    impartire_rest:
        inc %ebx #incrementam numarul de octeti ocupate de descriptor

    parcurgere_vector:
        cmp lungimeVector, %ecx #verificam daca exista elemente cu zero in vector
        je modificare_lungime_vector #daca nu exista elemente cu zero in vector sarim la adaugarea descriptorului
        mov (%edi, %ecx, 4), %edx

        cmp $0, %edx
        je spatii_zero_finale #daca elementul este 0 incrementam contorul pentru elementele cu zero consecutive

        inc %ecx
        jmp parcurgere_vector

    spatii_zero_finale:
        mov %ecx, %eax #salvam lungimea vectorului fara elementele cu zero consecutive de la final

    spatii_zero:
        inc %esi
        cmp %ebx, %esi #daca numarul de octeti ocupati de descriptor este egal cu numarul de elemente cu zero consecutive
        je et_add_in_vector_0 #adaugam descriptorul in vector
        inc %ecx

        cmp lungimeVector, %ecx #daca am ajuns la finalul vectorului si constatam ca elementele cu zero consecutive
        je modificare_lungime_final0 #se afla la finalul vectorului modificam lungimea vectorului

        mov (%edi, %ecx, 4), %edx #parcurgem vectorul pana gasim un zero
        cmp $0, %edx
        je spatii_zero #daca elementul este 0 verificam daca urmatorul element e zero

        
        

        xor %esi, %esi #daca elementul este diferit de 0 resetam contorul pentru elementele cu zero consecutive
        jmp parcurgere_vector #daca elementul este diferit de 0 continuam parcurgerea vectorului
        
    et_add_in_vector:
        mov %ecx, %eax #salvam in eax pozitia finala a elementului
        inc %eax

        sub %ebx, %ecx #scadem lungimea descriptorului pentru a adauga elementele in vector
        inc %ecx #salvam in ecx pozitia initiala a elementului

        jmp et_add_afisare

    et_add_in_vector_0:
        mov %eax, %ecx #salvam in ecx pozitia initiala a elementului
        add %ebx, %eax #adunam descriptorul la pozitia initiala a elementului
        jmp et_add_afisare #modificam lungimea vectorului pentru a sterge elementele de zero de la final

    modificare_lungime_final0:
        mov %eax, lungimeVector #modificarea lungimii vectorului pentru a sterge zero-urile finale

    modificare_lungime_vector:
        #modificarea lungimii vectorului
        mov lungimeVector, %eax
        mov %eax, %ecx #mutam in ecx lungimea vectorului inainte de adaugarea lungimii descriptorului
        add %ebx, %eax #adunam la lungimea vectorului numarul de octeti ocupati de descriptor
        mov %eax , lungimeVector #mutam in lungimea vectorului lungimea acestuia dupa adaugarea lungimii descriptorului

        cmp $1024, %eax #daca lungimea vectorului depaseste 1024 afisam descriptorul si (0, 0)
        jg et_afisare_0

    et_add_afisare:
        dec %eax #scadem 1 pentru a arata pozitia initiala a descriptorului
        push %eax #pozitia finala a descriptorului
        push %ecx #prima pozitie a descriptorului
        push descriptor #afisam descriptorul impreuna cu intervalul sau

        push $formatPrintfadd
        call printf

        push $0
        call fflush

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ecx
        pop %eax

        inc %eax #incrementam contorul la loc pentru a parcurge vectorul si a adauga elementele

    et_add:
        cmp %ecx, %eax #porneste de la lungimea vectorului inainte de adaugarea descriptorului
        je et_add_citire # si se opreste cand ajunge la lungimea vectorului dupa adaugarea descriptorului

        mov descriptor, %ebx #adauga descriptorul in vector
        mov %ebx, (%edi, %ecx, 4)

        inc %ecx
        jmp et_add

    et_afisare_0:
        mov lungimeVector, %eax #mutam lungimea vectorului in eax care depaseste 1024
        sub %ebx, %eax
        mov %eax, lungimeVector #nu modificam lungimea vectorului deoarece aceasta ar depasi 1024
        
        push $0 #pozitia finala a descriptorului
        push $0 #prima pozitie a descriptorului
        push descriptor #afisam descriptorul impreuna cu intervalul sau
        push $formatPrintfadd
        call printf

        push $0
        call fflush

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_add_citire

    et_restabilire_contor:
        mov copiecontor, %ecx #restabilim contorul pentru numarul de fisiere
        inc %ecx
        jmp prelucrare_operatii

pregatire_get:
    mov %ecx, copiecontor #salvam contorul pentru numarul de fisiere in copiecontor

    push $nrdescriptor #citirea descriptorului
    push $formatScanf
    call scanf

    pop %ebx
    pop %ebx
    xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului

    parcurgere_vector_get:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul vectorului
        je et_nu_exista_element_get #daca am ajuns la finalul vectorului inseamna ca nu exista elementul

        mov (%edi, %ecx, 4), %eax
        cmp %eax, nrdescriptor #comparam elementelul cu descriptorul
        je et_interval_element #daca sunt egale parcurgem intervalul elementului si aflam pozitia finala

        inc %ecx
        jmp parcurgere_vector_get
    
    et_interval_element:
        mov %ecx, %ebp  #salvam pozitia initiala a elementului
        inc %ecx #pentru a trece la urmatorul element

    et_parcurgere_interval:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul vectorului
        je et_afisare_interval #daca am ajuns la finalul vectorului afisam intervalul elementului

        mov (%edi, %ecx, 4), %ebx
        cmp nrdescriptor, %ebx #comparam elementul cu descriptorul
        jne et_afisare_interval #daca sunt diferite am gasit intervalul elementului

        inc %ecx
        jmp et_parcurgere_interval

    et_afisare_interval:
        dec %ecx #scadem 1 pentru a arata pozitia finala a elementului
        push %ecx #pozitia finala a elementului
        push %ebp #pozitia initiala a elementului

        push $formatPrintfget #afisam intervalul gasit
        call printf

        push $0
        call fflush

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_restabilire_contor

    et_nu_exista_element_get:
        push $0 # elementul nu a fost gasit
        push $0 
        push $formatPrintfget #afisam (0, 0)
        call printf

        push $0
        call fflush

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_restabilire_contor

pregatire_delete:
    mov %ecx, copiecontor #salvam contorul pentru numarul de fisiere in copiecontor

    push $descriptordelete #citirea descriptorului
    push $formatScanf
    call scanf

    pop %ebx
    pop %ebx
    xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului

    parcurgere_vector_delete:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul vectorului
        je pregatire_afisare_vector_delete #daca am ajuns la finalul vectorului inseamna ca nu exista elementul

        mov (%edi, %ecx, 4), %eax
        cmp descriptordelete, %eax #comparam elementelul cu descriptorul
        je et_interval_element_delete #daca sunt egale parcurgem intervalul elementului si inlocuim fiecare element cu 0

        inc %ecx
        jmp parcurgere_vector_delete

    et_interval_element_delete:
        mov $0, %edx
        mov %edx, (%edi, %ecx, 4) #inlocuim fiecare element cu 0
        inc %ecx

        mov (%edi, %ecx, 4), %eax
        cmp descriptordelete, %eax #verificam daca am ajuns la finalul intervalului elementului
        je et_interval_element_delete

        jmp pregatire_afisare_vector_delete
    
    pregatire_afisare_vector_delete:
        xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului
        xor %esi, %esi #initializam contorul pentru determinarea elementului initial al vectorului
        cmp lungimeVector, %ecx #verificam daca vectorul este gol
        je et_restabilire_contor #daca vectorul este gol trecem la urmatoarea operatie
    afisare_vector_delete:
        mov (%edi, %ecx, 4), %eax #citim urmatorul element din vector
        inc %ecx

    afisare_finala_delete:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul vectorului
        je afisare_finala_element #daca am ajuns la finalul vectorului afisam ultimul element
        
        mov (%edi, %ecx, 4), %edx #citim urmatorul element din vector
        cmp %edx, %eax #parcurgem vectorul pana gasim un element diferit de eax
        jne afisare_element_delete #si afisam intervalul elementului eax

        inc %ecx #incrementam contorul pentru a trece la urmatorul element
        jmp afisare_finala_delete 

    afisare_element_delete:
        cmp $0, %eax #daca elementul este 0 nu il afisam
        je nu_afiseaza


        sub $1, %ecx #scadem 1 pentru a afisa pozitia finala elementului anterior
        push %edx #salvam elementul urmator
        push %ecx #salavam contorul
        push %esi #pozitia initiala a elementului
        push %eax

        push $formatPrintfadd #afisam elementul impreuna cu pozitia initiala si finala a sa
        call printf

        push $0
        call fflush

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ecx #restabilim contorul
        pop %edx #restabilim elementul urmator

        mov %edx, %eax #punem urmatorul element in eax
        inc %ecx
        mov %ecx, %esi #salvam pozitia initiala a elementului urmator
        inc %ecx #incrementam contorul pentru a trece la urmatorul element
        jmp afisare_finala_delete

    nu_afiseaza:

        mov %ecx, %esi #salvam pozitia initiala a elementului urmator
        inc %ecx #incrementam contorul pentru a trece la urmatorul element
        mov %edx, %eax #punem urmatorul element in eax
        jmp afisare_finala_delete

    afisare_finala_element:

        cmp $0, %eax #daca ultimul element este 0 nu il afisam
        je et_restabilire_contor

        sub $1, %ecx #scadem 1 pentru a afisa pozitia finala a ultimului element
        push %ecx
        push %esi #pozitia initiala a elementului
        push %eax

        push $formatPrintfadd #afiseaza ultimul element impreuna cu pozitia initiala si finala a sa
        call printf

        push $0
        call fflush

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_restabilire_contor
    
pregatire_defrag:
    mov %ecx, copiecontor #salvam contorul pentru numarul de fisiere in copiecontor
    xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului
    
    et_defrag:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul vectorului
        jge pregatire_afisare_vector_delete #daca am ajuns la finalul vectorului afisam vectorul

        mov (%edi, %ecx, 4), %eax
        cmp $0, %eax #comparam elementul cu 0
        je et_defrag_element #daca elementul este 0 il stergem din vector

        inc %ecx
        jmp et_defrag
    
    et_defrag_element:
        mov %ecx, %ebp #salvam pozitia initiala a elementului
        decl lungimeVector #scadem lungimea vectorului
        mov lungimeVector, %ebx #salvam lungimea vectorului in ebx

    shiftare_stanga_vector:
        mov %ecx, %edx #salvam pozitia elementului anterior
        inc %ecx #trecem la urmatorul element

        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul vectorului
        jge et_final_defrag #daca am ajuns la finalul vectorului am terminat defragmentarea

        mov (%edi, %ecx, 4), %eax #mutam elementul cu o pozitie spre stanga
        mov %eax, (%edi, %edx, 4) 

        jmp shiftare_stanga_vector
    
    et_final_defrag:
        mov %ebp, %ecx #restabilim pozitia initiala a elementului
        jmp et_defrag #continuam defragmentarea

    exit:
        mov $1, %eax
        mov $0, %ebx
        int $0x80     
