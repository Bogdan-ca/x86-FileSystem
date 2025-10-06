.data  
    nrOperatii: .long 0 #declararea numarului de operatii
    matrice: .space 4096 * 1024 * 4, 0 #declararea matricei
    formatScanf: .asciz "%d"
    operatie: .long 0 #citirea operatiei
    contor_operatii: .long 0 #declararea copiei contorului
    lungimelinii: .space 4096, 0 #declararea vectorului pentru lungimiile liniilor
    lungimeVector: .long 0
    #variabile pentru operatia de add
    nrfisiere: .long 0 
    descriptor: .long 0 
    lungime: .long 0
    formatPrintfadd: .asciz "%d: ((%d, %d), (%d, %d))\n"
    contorlinii: .long 0
    pozitie_initiala: .long 0
    pozitie_finala: .long 0
    inmultire1024: .long 0

    #variabile pentru operatia get
    nrdescriptor: .long 0
    formatPrintfget: .asciz "((%d, %d), (%d, %d))\n"

    #variabile pentru operatia delete
    descriptordelete: .long 0
    #variabile pentru operatia defrag
    descriptordefrag: .long 0
    lungime_interval: .long 0
    adresadefrag: .long 0
    contor_linii: .long 0
    adresa_element_defrag: .long 0
    pozitie_finala_element_defrag: .long 0  
.text
.global main
main:
    push $nrOperatii #citirea numarului de operatii
    push $formatScanf
    call scanf
    pop %ebx
    pop %ebx
    mov $0, %ecx         #initializeaza contorului cu 0 
    mov $matrice, %edi   #initializeaza vectorul cu adresa de inceput
    mov $lungimelinii, %esi #initializeaza vectorul pentru lungimile liniilor
    
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
    je pregatire_add_matrice
    cmp $2, %eax    #face operatia de get
    je pregatire_get
    cmp $3, %eax    #face operatia de delete
    je pregatire_delete
    cmp $4, %eax    #face operatia de defrag
    je pregatire_defrag

pregatire_add_matrice:

    mov %ecx, contor_operatii #salvam contorul pentru numarul de operatii

    push $nrfisiere #citirea numarului de fisiere
    push $formatScanf

    call scanf

    pop %ebx
    pop %ebx
    xor %ebp, %ebp
    push %esi #salvam adresa vectorului pentru lungimile liniilor

    et_add_citire:
        cmp nrfisiere, %ebp
        je et_restabilire_contor_add

        push $descriptor #citirea descriptorului
        push $formatScanf 
        call scanf
        pop %ebx
        pop %ebx

        push $lungime #citirea lungimii
        push $formatScanf
        call scanf
        pop %ebx
        pop %ebx

        #determinarea spatiilor ocupate de descriptor
        xor %edx, %edx
        xor %edx, %edx
        mov lungime, %eax
        mov $8, %ebx
        div %ebx
        mov %eax, %ebx #mutam in ebx cati octeti sunt ocupati de descriptor

        inc %ebp #incrementam contorul de fisiere
        xor %ecx, %ecx

        cmp $1024, %ebx #daca descriptorul depaseste 1024 de octeti afisam descriptorul si (0, 0)
        jg et_nu_afiseaza_descriptor

        #prelucrarea cazului cand restul impartirii este diferit de 0
        cmp $0, %edx #daca restul impartirii este 0 sarim peste impartire_rest 
        je parcurgere_matrice_linii    #deoarece descriptorul ocupa un numar fix de spatii

    impartire_rest:
        inc %ebx #incrementam numarul de octeti ocupate de descriptor
        cmp $1024, %ebx #daca descriptorul depaseste 1024 de octeti afisam descriptorul si (0, 0)
        jg et_nu_afiseaza_descriptor
    parcurgere_matrice_linii:
        pop %esi #scoatem adresa vectorului pentru lungimile liniilor
        cmp $1024, %ecx
        je et_nu_afiseaza_descriptor

        mov (%esi, %ecx, 4), %eax
        mov %eax, lungimeVector
        push %esi #salvam adresa vectorului pentru lungimile liniilor

        mov $1024, %eax
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        mov $4, %esi
        mul %esi #salvam in eax inmultirea cu 4 pentru a accesa corect linia urmatoare
        mov %eax, inmultire1024 #pentru a accesa liniile urmatoare

        mov %ecx, contorlinii #salvam contorul pentru numarul de linii
        xor %ecx, %ecx #initializam contorul pentru parcurgerea matricei pe linii
    parcurgere_vector:
        cmp lungimeVector, %ecx #verificam daca exista elemente cu zero in vector
        je modificare_lungime_vector #daca nu exista elemente cu zero in vector sarim la adaugarea descriptorului
        
        push %ebx #salvam lungimea descriptorului

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        pop %ebx #restabilim lungimea descriptorului
        mov (%edi, %eax), %edx #citim elementul de pe pozitia curenta
        
        cmp $0, %edx
        je spatii_zero_finale #daca elementul este 0 incrementam contorul pentru elementele cu zero consecutive

        inc %ecx
        jmp parcurgere_vector

    et_add_debug:
        cmp $0, %edx
        je spatii_zero_finale #daca elementul este 0 incrementam contorul pentru elementele cu zero consecutive

        inc %ecx
        jmp parcurgere_vector
    spatii_zero_finale:
        mov %ecx, %eax #salvam lungimea vectorului fara elementele cu zero consecutive de la final
        xor %esi, %esi #resetam contorul pentru elementele cu zero consecutive
    spatii_zero:
        inc %esi
        cmp %ebx, %esi #daca numarul de octeti ocupati de descriptor este egal cu numarul de elemente cu zero consecutive
        je et_add_in_vector_0 #adaugam descriptorul in vector
        inc %ecx

        cmp lungimeVector, %ecx #daca am ajuns la finalul vectorului si constatam ca elementele cu zero consecutive
        je modificare_lungime_final0 #se afla la finalul vectorului modificam lungimea vectorului
        
        push %ebx #salvam lungimea descriptorului
        push %eax #salvam pozitia initiala a elementului

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul


        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent
        
        mov (%edi, %eax), %edx #citim elementul de pe pozitia curenta

        pop %eax #restabilim pozitia initiala a elementului
        pop %ebx #restabilim lungimea descriptorului

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
        push contorlinii #pozitia finala a descriptorului

        push %ecx #prima pozitie a descriptorului
        push contorlinii #prima pozitie a descriptorului

        push descriptor #afisam descriptorul impreuna cu intervalul sau

        push $formatPrintfadd
        call printf

        pop %ebx
        pop %ebx
        pop %ebx
        
        pop %ecx #restabilim pozitia initiala a descriptorului
        pop %ebx
        pop %eax #restabilim pozitia finala a descriptorului

        inc %eax #incrementam contorul la loc pentru a parcurge vectorul si a adauga elementele

    et_add:
        cmp %ecx, %eax #porneste de la lungimea vectorului inainte de adaugarea descriptorului
        je et_restabilire_contor_caz_afisare # si se opreste cand ajunge la lungimea vectorului dupa adaugarea descriptorului

        push %eax #salvam eax

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent
        
        mov descriptor, %ebx #adauga descriptorul in vectors
        mov %ebx, (%edi,%eax)

        pop %eax #restabilim eax

        inc %ecx
        jmp et_add

    et_afisare_0:
        mov lungimeVector, %eax #mutam lungimea vectorului in eax care depaseste 1024
        sub %ebx, %eax
        mov %eax, lungimeVector #nu modificam lungimea vectorului deoarece aceasta ar depasi 1024
        
        jmp et_restabilire_contor_caz_fara_spatiu

    et_restabilire_contor_caz_fara_spatiu:
        mov contorlinii, %ecx #restabilim contorul pentru numarul de linii

        pop %esi #scoatem adresa vectorului pentru lungimile liniilor
        mov lungimeVector, %eax #mutam lungimea vectorului in eax
        mov %eax, (%esi, %ecx, 4) #salvam lungimea vectorului in vectorul pentru lungimile liniilor
        push %esi #salvam adresa vectorului pentru lungimile liniilor

        inc %ecx
        jmp parcurgere_matrice_linii

    et_restabilire_contor_caz_afisare:
        mov contorlinii, %ecx #restabilim contorul pentru numarul de linii

        pop %esi #scoatem adresa vectorului pentru lungimile liniilor
        mov lungimeVector, %eax #mutam lungimea vectorului in eax
        mov %eax, (%esi, %ecx, 4) #salvam lungimea vectorului in vectorul pentru lungimile liniilor
        push %esi #salvam adresa vectorului pentru lungimile liniilor

        inc %ecx
        jmp et_add_citire

    et_nu_afiseaza_descriptor:
        push $0 #afisam pozitia finala (0,0)
        push $0

        push $0 #afisam pozitia initiala (0,0)
        push $0

        push descriptor #afisam descriptorul impreuna cu intervalul sau
        push $formatPrintfadd
        call printf

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        mov contorlinii, %ecx #restabilim contorul pentru numarul de linii
        inc %ecx
        jmp et_add_citire

    et_restabilire_contor_add:
        mov contor_operatii, %ecx #restabilim contorul pentru numarul de fisiere
        inc %ecx
        pop %esi #scoatem adresa vectorului pentru lungimile liniilor
        jmp prelucrare_operatii


pregatire_get:
    mov %ecx, contor_operatii #salvam contorul pentru numarul de fisiere in copiecontor

    push $nrdescriptor #citirea descriptorului
    push $formatScanf
    call scanf

    pop %ebx
    pop %ebx
    xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului

    parcurgere_matrice_linii_get:
        cmp $1024, %ecx #daca am ajuns la finalul vectorului de lungimi de linii
        je et_nu_exista_element_get #nu exista elementul in matrice

        mov (%esi, %ecx, 4), %eax #citim lungimea liniei
        mov %eax, lungimeVector #salvam lungimea liniei

        mov $1024, %eax #salvam in eax 1024
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        mov $4, %edx
        mul %edx #salvam in eax inmultirea cu 4 pentru a accesa corect linia urmatoare
        mov %eax, inmultire1024

        mov %ecx, contorlinii #salvam contorul pentru numarul de linii
        xor %ecx, %ecx #initializam contorul pentru parcurgerea matricei pe linii
    parcurgere_vector_get:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je et_restabilire_contor_linii_get #daca am ajuns la finalul liniei trecem la urmatoarea linie

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov (%edi, %eax), %eax #citim elementul de pe pozitia curenta
        cmp nrdescriptor, %eax #comparam elementul citit cu descriptorul
        je et_interval_element

        inc %ecx
        jmp parcurgere_vector_get

    et_interval_element:
        mov %ecx, %ebp #salvam pozitia initiala a elementului
        inc %ecx
    et_parcurgere_interval:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je et_afisare_interval #daca am ajuns la finalul liniei afisam intervalul


        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov (%edi, %eax), %ebx #citim elementul de pe pozitia curenta
        cmp nrdescriptor, %ebx #comparam elementul citit cu descriptorul
        jne et_afisare_interval #daca elementul citit este diferit am gasit intervalul

        inc  %ecx #incrementam contorul pentru a parcurge intervalul
        jmp et_parcurgere_interval
    
    et_afisare_interval:
        dec %ecx #scadem 1 pentru a arata pozitia initiala a intervalului

        push %ecx #pozitia finala a intervalului
        push contorlinii #pozitia finala a intervalului

        push %ebp #pozitia initiala a intervalului
        push contorlinii #pozitia initiala a intervalului

        push $formatPrintfget
        call printf

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_restabilire_contor_get

    et_nu_exista_element_get:
        push $0 #afisam pozitia finala (0,0)
        push $0

        push $0 #afisam pozitia initiala (0,0)
        push $0

        push $formatPrintfget
        call printf

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_restabilire_contor_get
    
    et_restabilire_contor_linii_get:
        mov contorlinii, %ecx #restabilim contorul pentru numarul de linii
        inc %ecx
        jmp parcurgere_matrice_linii_get

    et_restabilire_contor_get:
        mov contor_operatii, %ecx #restabilim contorul pentru numarul de fisiere
        inc %ecx
        jmp prelucrare_operatii

pregatire_delete:
    mov %ecx, contor_operatii #salvam contorul pentru numarul de fisiere in copiecontor

    push $descriptordelete #citirea descriptorului
    push $formatScanf
    call scanf

    pop %ebx
    pop %ebx
    xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului

    parcurgere_matrice_linii_delete:
        cmp $1024, %ecx #daca am ajuns la finalul vectorului de lungimi 
        je pregatire_afisare_matrice_delete

        mov (%esi, %ecx, 4), %eax #citim lungimea liniei
        mov %eax, lungimeVector #salvam lungimea liniei

        mov $1024, %eax #salvam in eax 1024
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        mov $4, %edx
        mul %edx #salvam in eax inmultirea cu 4 pentru a accesa corect linia urmatoare
        mov %eax, inmultire1024

        mov %ecx, contorlinii #salvam contorul pentru numarul de linii
        xor %ecx, %ecx #initializam contorul pentru parcurgerea matricei pe linii

    parcurgere_vector_delete:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je et_restabilire_contor_linii_delete #daca am ajuns la finalul liniei trecem la urmatoarea linie

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov (%edi, %eax), %ebx #citim elementul de pe pozitia curenta
        cmp descriptordelete, %ebx #comparam elementul citit cu descriptorul
        je et_interval_element_delete

        inc %ecx
        add $4, %eax
        jmp parcurgere_vector_delete

    et_interval_element_delete:
        mov $0, %ebp
        mov %ebp, (%edi, %eax) #stergem elementul din matrice
        
        inc %ecx
        add $4, %eax #adaugam 4 pentru a trece la urmatorul element

        mov (%edi, %eax), %ebx #citim elementul urmator
        cmp descriptordelete, %ebx #comparam elementul urmator cu descriptorul
        je et_interval_element_delete #daca elementul urmator este descriptorul il stergem

        jmp pregatire_afisare_matrice_delete

    et_restabilire_contor_linii_delete:
        mov contorlinii, %ecx #restabilim contorul pentru numarul de linii
        inc %ecx
        jmp parcurgere_matrice_linii_delete

    pregatire_afisare_matrice_delete:
        xor %ecx, %ecx
        push %esi #salvam adresa vectorului pentru lungimile liniilor

    parcurgere_matrice_linii_delete_afisare:
        cmp $1024, %ecx #daca am ajuns la finalul vectorului de lungimi de linii
        je et_restabilire_contor_delete #terminam afisarea matricei

        pop %esi #scoatem adresa vectorului pentru lungimile liniilor
        mov (%esi, %ecx, 4), %eax #citim lungimea liniei
        mov %eax, lungimeVector #salvam lungimea liniei
        push %esi #salvam adresa vectorului pentru lungimile liniilor

        mov $1024, %eax #salvam in eax 1024
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        mov $4, %edx
        mul %edx #salvam in eax inmultirea cu 4 pentru a accesa corect linia urmatoare
        mov %eax, inmultire1024

        mov %ecx, contorlinii #salvam contorul pentru numarul de linii
        xor %ecx, %ecx #initializam contorul pentru parcurgerea matricei pe linii

    pregatire_afisare_vector_delete:
        xor %ecx, %ecx
        xor %esi, %esi
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je et_restabilire_contor_linii_afisare #daca am ajuns la finalul liniei trecem la urmatoarea linie

    afisare_vector_delete:
        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov (%edi, %eax), %ebx #citim elementul de pe pozitia curenta

        inc %ecx
        add $4, %eax
    
    afisare_finala_delete:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je afisare_finala_element

        mov (%edi, %eax), %edx #citim elementul de pe pozitia curenta
        cmp %edx, %ebx #parcurgem vectorul pana gasim un element diferit de ebx
        jne afisare_element_delete

        inc %ecx #incrementam contorul pentru a parcurge vectorul
        add $4, %eax #adaugam 4 pentru a trece la urmatorul element
        jmp afisare_finala_delete

    afisare_element_delete:
        cmp $0, %ebx #daca elementul este 0 nu il afisam
        je nu_afiseaza

        push %eax #salvam adresa elementului

        sub $1, %ecx #scadem 1 pentru a arata pozitia initiala a elementului
        push %edx #salvam elementul urmator

        push %ecx #pozitia finala a intervalului
        push contorlinii #pozitia finala a intervalului

        push %esi #pozitia initiala a intervalului
        push contorlinii #pozitia initiala a intervalului

        push %ebx #afisam elementul
        push $formatPrintfadd
        call printf

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        pop %ecx
        pop %edx
        pop %eax

        mov %edx, %ebx #mutam elementul urmator in ebx
        inc %ecx #incrementam contorul pentru a parcurge vectorul
        add $4, %eax #adaugam 4 pentru a trece la urmatorul element

        mov %ecx, %esi #salvam pozitia initiala a elementului
        inc %ecx
        jmp afisare_finala_delete

    nu_afiseaza:

        mov %ecx, %esi #salvam pozitia initiala a elementului
        inc %ecx
        add $4, %eax #adaugam 4 pentru a trece la urmatorul element

        mov %edx, %ebx #mutam elementul urmator in ebx
        jmp afisare_finala_delete

    afisare_finala_element:
        cmp $0, %ebx #daca elementul este 0 nu il afisam
        je et_restabilire_contor_linii_afisare

        sub $1, %ecx #scadem 1 pentru a arata pozitia initiala a elementului
        
        push %ecx #pozitia finala a intervalului
        push contorlinii #pozitia finala a intervalului

        push %esi #pozitia initiala a intervalului
        push contorlinii #pozitia initiala a intervalului

        push %ebx #afisam elementul
        push $formatPrintfadd
        call printf

        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx
        pop %ebx

        jmp et_restabilire_contor_linii_afisare

    et_restabilire_contor_linii_afisare:
        mov contorlinii, %ecx #restabilim contorul pentru numarul de linii
        
        inc %ecx
        jmp parcurgere_matrice_linii_delete_afisare

    et_restabilire_contor_delete:
        pop %esi #scoatem adresa vectorului pentru lungimile liniilor
        mov contor_operatii, %ecx #restabilim contorul pentru numarul de fisiere
        inc %ecx
        jmp prelucrare_operatii
        
pregatire_defrag:
    mov %ecx, contor_operatii #salvam contorul pentru numarul de fisiere in copiecontor
    xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului

    parcurgere_matrice_linii_defrag:
        cmp $1024, %ecx #daca am ajuns la finalul vectorului de lungimi 
        je pregatire_afisare_matrice_delete

        mov (%esi, %ecx, 4), %eax #citim lungimea liniei
        mov %eax, lungimeVector #salvam lungimea liniei

        mov $1024, %eax #salvam in eax 1024
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        mov $4, %edx
        mul %edx #salvam in eax inmultirea cu 4 pentru a accesa corect linia urmatoare
        mov %eax, inmultire1024

        cmp $0, %ecx #daca suntem pe prima linie
        je pregatire_defrag_vector #facem direct defragmentarea

        mov %ecx, contorlinii #salvam contorul pentru numarul de linii
        xor %ecx, %ecx #initializam contorul pentru parcurgerea matricei pe linii

    pregatire_parcurgere_vector_defrag_schimbare_linie:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je pregatire_defrag_vector #daca am ajuns la finalul liniei facem direct defragmentarea

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        mov %ecx, %ebp #salvam pozitia initiala a elementului 

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov (%edi, %eax), %ebx #citim elementul de pe pozitia curenta

        inc %ecx
        add $4, %eax

    parcurgere_vector_defrag_schimbare_linie:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je et_restabilire_contor_linie_curenta_defrag #daca am ajuns la finalul liniei trecem la urmatoarea linie

        mov (%edi, %eax), %edx #citim elementul de pe pozitia curenta
       
        inc %ecx
        add $4, %eax

        cmp %edx, %ebx #daca elementul este 0 sarim la urmatorul element
        jne et_schimbare_linie

        jmp parcurgere_vector_defrag_schimbare_linie

    et_schimbare_linie:
        cmp $0, %ebx #daca elementul este 0 sarim la urmatorul element
        je pregatire_parcurgere_vector_defrag_schimbare_linie

        push %ebp #salvam pozitia initiala a elementului
        push %ecx #salvam pozitia finala a elementului
        sub %ebp, %ecx #calculam lungimea intervalului
        mov %ecx, %ebp #salvam lungimea intervalului

        mov %ebp, lungime_interval #salvam lungimea intervalului
        mov %ebx, descriptor #salvam elementul pe care il adaugam pe linia anteriora

        mov contor_linii, %ecx #salvam contorul pentru numarul de linii
        dec %ecx #scadem 1 pentru a accesa linia anterioara

        mov (%esi, %ecx, 4), %ebx #citim lungimea liniei

        mov $1024, %ecx #salvam in eax 1024
        sub %ebx, %ecx #scadem lungimea intervalului pentru a calcula lungimea libera din linia anterioara

        cmp %ecx, %ebp #daca lungimea intervalului este mai mare decat lungimea libera din linia anterioara
        jg pregatire_defrag_vector #facem direct defragmentarea

        pop %ecx #restabilim pozitia finala a elementului
        pop %ebp #restabilim pozitia initiala a elementului

        //push %eax #salvam adresa elementului urmator
        //push %ecx #salvam pozitia finala a elementului urmator

        mov %eax, adresa_element_defrag #salvam adresa elementului urmator
        mov %ecx , pozitie_finala_element_defrag #salvam pozitia finala a elementului urmator

        mov %ecx, %eax #salvam pozitia finala a elementului
        mov %ebp, %ecx #salvam pozitia initiala a elementului

    et_delete_defrag:
        cmp %ecx, %eax
        je et_add_defrag

        push %eax #salvam adresa elementului

        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov $0, %ebp #stergem elementul din matrice
        mov %ebp, (%edi, %eax) 

        pop %eax #restabilim adresa elementului

        inc %ecx
        jmp et_delete_defrag

    pregatire_add_defrag:
        mov contor_linii, %ecx #salvam contorul pentru numarul de linii
        dec %ecx #scadem 1 pentru a accesa linia anterioara

        mov (%esi, %ecx, 4), %ebx #citim lungimea liniei anterioare
        mov lungime_interval, %ebp #salvam lungimea intervalului de adaugat

        mov %ebx, %edx #salvam punctul de inceput al intervalului
        add %ebp, %ebx #calculam noua lungime a liniei anterioare

        mov %ebx, (%esi, %ecx, 4) #salvam noua lungime a liniei anterioare
        mov %ebx, lungimeVector #salvam noua lungime a liniei anterioare

        mov $1024, %eax #salvam in eax 1024
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        
        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementulor de pe linia curenta
        mov %eax, inmultire1024

        mov %edx, %ecx #salvam punctul de inceput al intervalului

    et_add_defrag:
        cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
        je et_restabilire_contor_linie_curenta_defrag #continuam defragmentarea pe linia initiala
        
        mov inmultire1024, %ebx #mutam in eax inmultirea cu 1024
        mov %ecx, %eax #mutam in eax contorul pentru a parcurge vectorul

        imull $4, %eax #inmultim contorul cu 4 pentru a obtine pozitia elementului curent
        add %ebx, %eax #adunam 1024*nrliniei pentru parcurgerea matricei pe linii pentru a obtine pozitia elementului curent

        mov descriptor, %ebx #adauga descriptorul pe linia precedenta
        mov %ebx, (%edi, %eax)

        inc %ecx
        jmp et_add_defrag

    et_restabilire_contor_linie_curenta_defrag:
        //pop %ecx
        //pop %eax

        mov adresa_element_defrag, %eax #restabilim adresa elementului urmator
        mov pozitie_finala_element_defrag, %ecx #restabilim pozitia finala a elementului urmator

        mov (%esi, %ecx, 4), %ebx #citim lungimea liniei
        mov %ebx, lungimeVector #salvam lungimea liniei
        jmp parcurgere_vector_defrag_schimbare_linie

    pregatire_defrag_vector:
        mov contor_linii, %ecx #salvam contorul pentru numarul de linii
        mov (%esi, %ecx, 4), %eax #citim lungimea liniei
        mov %eax, lungimeVector #salvam lungimea liniei

        mov $1024, %eax #salvam in eax 1024
        mul %ecx #salvam inmultirea lui 1024 cu contorul pentru linii
        mov $4, %edx
        mul %edx #salvam in eax inmultirea cu 4 pentru a accesa corect linia urmatoare

        xor %ecx, %ecx #initializam contorul pentru parcurgerea vectorului
        et_defrag:
            cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
            jge et_restabilire_contor_linii_defrag #daca am ajuns la finalul liniei trecem la urmatoarea linie

            mov (%edi, %eax), %ebx #citim elementul de pe pozitia curenta
            cmp $0, %ebx #daca elementul este 0 sarim la urmatorul element
            je et_defrag_element

            inc %ecx
            add $4, %eax
            jmp et_defrag
        
        et_defrag_element:
            mov %ecx, %ebp #salvam pozitia initiala a elementului
            push %eax #salvam adresa elementului
            decl lungimeVector #scadem lungimea vectorului
            
        shiftare_stanga_vector:
            mov %ecx, %edx #salvam elementului anterior
            inc %ecx
            add $4, %eax

            cmp lungimeVector, %ecx #verificam daca am ajuns la finalul liniei
            jge et_final_defrag #daca am ajuns la finalul liniei trecem la urmatoarea linie

            mov (%edi, %eax), %ebx #citim elementul de pe pozitia curenta
            sub $4 , %eax #scadem 4 pentru a trece la elementul anterior

            mov %ebx, (%edi, %eax) #mutam elementul curent pe pozitia anterioara
            add $4, %eax #adaugam 4 pentru a trece la elementul curent

            jmp shiftare_stanga_vector
        
        et_final_defrag:
            mov %ebp, %ecx #restabilim contorul pentru parcurgerea vectorului
            pop %eax #restabilim adresa elementului
            jmp et_defrag

        et_restabilire_contor_linii_defrag:
            mov contor_linii, %ecx #restabilim contorul pentru numarul de linii
            mov lungimeVector, %eax #mutam lungimea vectorului in eax
            mov %eax, (%esi, %ecx, 4) #salvam lungimea vectorului in vectorul pentru lungimile liniilor
            inc %ecx
            jmp parcurgere_matrice_linii_defrag


    


        








exit:
    mov $1, %eax
    mov $0, %ebx
    int $0x80 
