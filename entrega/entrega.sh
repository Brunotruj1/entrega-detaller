# Entrega Bruno Trujillo - 340300
#!/bin/bash

# Verificacion de Usuarios y Contraseñas
# (-s = entrada silenciosa, -p = prioridad solicitud de entrada) 

function verificacion(){
    echo "===================================="
    echo "==        INICIO DE SESION        =="
    echo "===================================="
    echo "==  INGRESE USUARIO Y CONTRASEÑA  =="
    echo "===================================="
    read -p "Usuario: " usuario
    read -s -p "Password: " password
    echo

    # Verificacion de Datos con los Guardados
    if grep -q "^$usuario:$password$" users.txt; then
        echo "Verificacion Correcta, Bienvenido $usuario!"
        sleep 2
        menu_principal
    else
        echo "Verificacion Fallida, Usuario o Contraseña Incorrectos."
        sleep 2
        clear
        verificacion
    fi
}

# Menu principal
function menu_principal() {
    echo "============================================="
    echo "==             MENU PRINCIPAL              =="
    echo "============================================="
    echo "== 1. Listar usuarios                      =="
    echo "== 2. Agregar usuario                      =="
    echo "== 3. Configurar letra inicial             =="
    echo "== 4. Configurar letra final               =="
    echo "== 5. Configurar letra contenida           =="
    echo "== 6. Consultar diccionario                =="
    echo "== 7. Configurar vocal                     =="
    echo "== 8. Listar palabras con unica vocal      =="
    echo "== 9. Algoritmo #1(Promedio,Menor y Mayor) =="
    echo "== 10. Algoritmo #2(Palabra Capicua)       =="
    echo "== 11. Salir                               =="
    echo "============================================="
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) list_users ;;
        2) add_user ;;
        3) configure_initial_letter ;;
        4) configure_final_letter ;;
        5) configure_contained_letter ;;
        6) consult_dictionary ;;
	7) enter_vowel ;;
        8) list_words_with_unique_vowel ;;
	9) algorithm_1 ;;
	10) algorithm_2 ;;
        11) exit ;;
        *) echo "Opción no válida"; menu_principal ;;
    esac
}

# Usuarios listados
function list_users() {
    echo "Usuarios registrados:"
    cut -d: -f1 users.txt
    menu_principal
}

# Agregar usuario
function add_user() {
    echo "Ingrese su nuevo nombre de usuario:"
    read NEW_USER
    if grep -q "^$NEW_USER:" users.txt; then
        echo "El nombre de usuario ya existe"
        menu_principal
        return
    fi
    echo "Ingrese la contraseña para su nuevo usuario:"
    read -s NEW_PASS
    echo "$NEW_USER:$NEW_PASS" >> users.txt
    echo "El usuario ha sido agregado con éxito"
    menu_principal
}

# Configurar letra inicial
function configure_initial_letter() {
    echo "Ingrese la letra inicial:"
    read INITIAL_LETTER
    save_config
    menu_principal
}

# Configurar letra final
function configure_final_letter() {
    echo "Ingrese la letra final:"
    read FINAL_LETTER
    save_config
    menu_principal
}

# Configurar letra contenida
function configure_contained_letter() {
    echo "Ingrese la letra contenida:"
    read CONTAINED_LETTER
    save_config
    menu_principal
}

# Guardar configuración
function save_config() {
    echo "INITIAL_LETTER=$INITIAL_LETTER" > config.txt
    echo "FINAL_LETTER=$FINAL_LETTER" >> config.txt
    echo "CONTAINED_LETTER=$CONTAINED_LETTER" >> config.txt
}

# Leer configuración
function read_config() {
    if [ -f config.txt ]; then
        source config.txt
    fi
}

# Consultar diccionario
function consult_dictionary() {
    read_config
    if [[ -z "$INITIAL_LETTER" || -z "$FINAL_LETTER" || -z "$CONTAINED_LETTER" ]]; then
        echo "Primero debe configurar la letra inicial, la letra final y la letra contenida"
        menu_principal
        return
    fi
    DATE=$(date '+%d-%m-%Y %H:%M:%S')
    LOG_FILE="log_$DATE.txt"
    TOTAL_WORDS=$(wc -w < diccionario.txt)
    MATCHING_WORDS=$(grep -E "^$INITIAL_LETTER.*$CONTAINED_LETTER.*$FINAL_LETTER$" diccionario.txt | wc -l)
    PERCENTAGE=$(echo "scale=2; ($MATCHING_WORDS * 100) / $TOTAL_WORDS" | bc)

    #Muestra de Resultados

    echo "Fecha: $DATE"
    echo "Total de Palabras: $TOTAL_WORDS"
    echo "Palabras que coinciden: $MATCHING_WORDS"
    echo "Porcentaje: $PERCENTAGE%"
    echo "Usuario: $usuario_actual"	

    #Guardado de Resultados en LOG

    echo "Fecha: $DATE" > "$LOG_FILE"
    echo "Total de palabras: $TOTAL_WORDS" >> "$LOG_FILE"
    echo "Palabras que coinciden: $MATCHING_WORDS" >> "$LOG_FILE"
    echo "Porcentaje: $PERCENTAGE%" >> "$LOG_FILE"
    echo "Usuario: $usuario_actual" >> "$LOG_FILE"
    echo "Resultados guardados en $LOG_FILE"
    menu_principal
}

# Ingresar vocal
function enter_vowel() {
    read -p "Ingrese una vocal: " VOCAL
    save_vowel_config
    menu_principal
}

# Guardar configuración de vocal
function save_vowel_config() {
    echo "VOCAL=$VOCAL" > vowel_config.txt
}

# Leer configuración de vocal
function read_vowel_config() {
    if [ -f vowel_config.txt ]; then
        source vowel_config.txt
    fi
}

# Listar palabras con única vocal
function list_words_with_unique_vowel() {
    read_vowel_config
    if [[ -z "$VOCAL" ]]; then
        echo "Primero debe ingresar una vocal"
        menu_principal
        return
    fi
    RESULTS=()
    for word in $(cat diccionario.txt); do
        if [[ $word =~ ^[^aeiou]*$VOCAL[^aeiou]*$ ]]; then
            RESULTS+=("$word")
        fi
    done
    echo "Palabras que contienen solo la vocal $VOCAL: ${RESULTS[@]}"
    menu_principal
}

# Algoritmo 1: Promedio, menor y mayor
function algorithm_1() {
    read -p "¿Cuántos datos desea ingresar? " n
    if ! [[ "$n" =~ ^[0-9]+$ ]]; then
        echo "Por favor ingrese un número válido."
        menu_principal
        return
    fi
    datos=()
    for (( i=0; i<n; i++ )); do
        read -p "Ingrese un número: " num
        datos+=("$num")
    done
    total=0
    menor=${datos[0]}
    mayor=${datos[0]}
    for num in "${datos[@]}"; do
        total=$((total + num))
        if [ "$num" -lt "$menor" ]; then
            menor=$num
        fi
        if [ "$num" -gt "$mayor" ]; then
            mayor=$num
        fi
    done
    promedio=$(echo "scale=2; $total / $n" | bc)
    echo "Promedio: $promedio, Menor: $menor, Mayor: $mayor"
    menu_principal
}

# Algoritmo 2: Palabra capicúa
function algorithm_2() {
    read -p "Ingrese una palabra: " palabra
    invertida=$(echo "$palabra" | rev)
    if [ "$palabra" == "$invertida" ]; then
        echo "La palabra es capicúa."
    else
        echo "La palabra no es capicúa."
    fi
    menu_principal
}

# Iniciar el script con la verificación de usuario
verificacion
