#!/bin/bash

# Título: Ejercicio 1
# Descripción: Creamos un bash script para automatizar la gestión de gastos de una PYME

# ========== DECLARACIONES GLOBALES ==========
BIG_EXPENSES_MARGIN=10
EXPENSES_DIRECTORY="gastos"

# ========== CODIFICACIÓN DE FUNCIONES ==========
# Nombre: Main
# Descripción: Función que se encarga de inicializar el programa
# Argumentos: 
#   - [STRING] Cantidad de argumentos recibidos por el programa
#   - [STRING] Valor del primer argumento recibido por el programa
#   - [STRING] Valor del segundo argumento recibido por el programa
#   - [STRING] Valor del tercer argumento recibido por el programa
#   - [STRING] Valor del cuarto argumento recibido por el programa
# Retorno: Código de salida del programa (0 -> Sin errores | 1 -> Error)
function main(){

    # Variables necesarias
    local error=0
    local executing=1
    local option=0

    # Obtenemos los parámetros de la función
    local numberOfArguments=$1
    local expensesQ1=$2
    local expensesQ2=$3
    local expensesQ3=$4
    local expensesQ4=$5

    # Obtenemos los datos necesarios para el programa mediante el uso de command substitution con la función getParameters
    neededData=$(getParameters $numberOfArguments $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4)
    read error expensesQ1 expensesQ2 expensesQ3 expensesQ4 <<< "$neededData"

    # Comprobamos si la función anterior ha devuelto un error, si es así, mostramos error y salimos del programa
    if [ $error -eq 1 ]; then
        echo "ERROR: No se ha podido interpretar correctamente los parámetros, recuerda introducir los gastos de los 4 trimestres separados por espacios."
        return 1
    fi

    # Iniciamos el bucle de ejecución del menú principal del programa
    while [ $executing -eq 1 ]; do
        
        echo "----- Menú Principal -----"
        echo "1.- Introducir gastos."
        echo "2.- Calcular el gasto total anual."
        echo "3.- Detectar gastos superiores a 10K€."
        echo "4.- Crear directorio gastos."
        echo "5.- Exportar el gasto total anual."
        echo "6.- Salir."
        read -p "Opción: " option

        case "$option" in
            '1')
                neededData=$(setExpenses)
                read expensesQ1 expensesQ2 expensesQ3 expensesQ4 <<< "$neededData"
                ;;
            '2')
                getTotalExpenses $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4
                ;;
            '3')
                checkBigExpenses $BIG_EXPENSES_MARGIN $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4
                ;;
            '4')
                createExpensesDirectory $EXPENSES_DIRECTORY
                ;;
            '5')
                generateReport $EXPENSES_DIRECTORY $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4
                ;;
            '6')
                echo "Finalizando programa..."
                executing=0
                ;;
            '*')
                echo "ERROR: No se ha podido interpretar correctamente la opción seleccionada, inténtelo de nuevo..."
                ;;
        esac

    done

    return 0

}

# Nombre: Get Parameters
# Descripción: Obtiene los parámetros necesarios para que funcione el programa de gestión de gastos de la PYME
# Argumentos:
#   - [STRING] Número de parámetros recibidos por el programa
#   - [STRING] Valor del primer argumento recibido por el programa
#   - [STRING] Valor del segundo argumento recibido por el programa
#   - [STRING] Valor del tercer argumento recibido por el programa
#   - [STRING] Valor del cuarto argumento recibido por el programa
# Retorno:
#   - [STRING] Error: 0 -> No ha habido error | 1 -> Ha habido error
#   - [STRING] Valor numérico que representa los gastos del Q1 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q2 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q3 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q4 de la PYME
function getParameters(){

    # Variables necesarias
    local error=0
    local expenses=""

    # Obtenemos los parámetros de la funcion
    local numberOfArguments=$1
    local expensesQ1=$2
    local expensesQ2=$3
    local expensesQ3=$4
    local expensesQ4=$5

    # Si hemos recibido 0 argumentos solicitamos los datos por terminal
    if [ $numberOfArguments -eq 0 ]; then
        expenses=$(setExpenses)
    # En caso contrario, si el número de parámetros no concuerda con 4, o estos están vacíos, finalizamos el programa con error
    elif [ $numberOfArguments -ne 4 -o $(checkEmptyParameters $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4) -eq 1 ]; then
        error=1
    # En caso contrario, todos los parámetros han sido recibido correctamente por argumento, los almacenamos y los preparamos para devolver
    else
        expenses="$expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4"
    fi

    # Si los parámetros han sido obtenidos correctamente, de los argumentos, o mediante la terminal, los devolvemos mediante echo
    echo "$error $expenses"

}

# Nombre: Check Empty Parameters
# Descripción: Función que comprueba si alguno de los parámetros introducidos está vacío
# Argumentos: 
#   - [STRING] Valor numérico que representa los gastos del Q1 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q2 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q3 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q4 de la PYME
# Retorno: 1 si hay alguno vacío y 0 si no
function checkEmptyParameters(){

    if [ $# -ne 4 ]; then
        echo "1"
    elif [ -z $1 -o -z $2 -o -z $3 -o -z $4 ]; then
        echo "1"
    else
        echo "0"
    fi

}

# Nombre: Set Expenses
# Descripción: Solicita los gastos por terminal y los devuelve para ser almacenados
# Argumentos: Ninguno
# Retorno:
#   - [STRING] Valor numérico que representa los gastos del Q1 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q2 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q3 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q4 de la PYME
function setExpenses(){

    # Variables necesarias
    local emptyParameters=1
    local expensesQ1=0
    local expensesQ2=0
    local expensesQ3=0
    local expensesQ4=0

    while [ $emptyParameters -eq 1 ]; do

        read -p "Introduzca los gastos del primer trimestre: " expensesQ1
        read -p "Introduzca los gastos del segundo trimestre: " expensesQ2
        read -p "Introduzca los gastos del tercer trimestre: " expensesQ3
        read -p "Introduzca los gastos del cuarto trimestre: " expensesQ4
        emptyParameters=$(checkEmptyParameters $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4)

        if [ $emptyParameters -eq 1 ]; then
            # Redirigimos el mensaje de error a la salida standard (STDOUT -> 2) para que aparezca por la terminal y no se guarde como retorno de la función
            # para el command substitution
            echo "ERROR: Se han introducido valores vacíos, inténtelo de nuevo..." >&2
        fi
    
    done
    
    echo "$expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4"

}

# Nombre: Get Total Expenses
# Descripción: Función con la que obtenemos la suma de todos los gastos anuales de la empresa
# Argumentos:
#   - [STRING] Gastos del Q1
#   - [STRING] Gastos del Q2
#   - [STRING] Gastos del Q3
#   - [STRING] Gastos del Q4
# Retorno: Mensaje con la operación realizada
function getTotalExpenses(){

    # Variables necesarias
    local totalExpenses=$(( $1 + $2 + $3 + $4 ))
    
    echo "Gasto total anual: $1 + $2 + $3 + $4 = $totalExpenses"

}

# Nombre: Check Big Expenses
# Descripción: Función que comprueba si existe algún trimestre en el que el gasto supere la cantidad indicada
# Argumentos: 
#   - [STRING] Cantidad umbral
#   - [STRING] Valor numérico que representa los gastos del Q1 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q2 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q3 de la PYME
#   - [STRING] Valor numérico que representa los gastos del Q4 de la PYME
# Retorno: Mensaje con los trimestres que superen el umbral
function checkBigExpenses(){

    # Variables necesarias
    local counter=0

    # Obtenemos los parámetros
    local margin=$1
    local allParameters=$@

    # Recorremos la lista de parámetros para comprobar si algún Q supera el umbral
    for element in $allParameters; do
        
        # Incrementamos el contador para llevar la cuenta del argumento por el que vamos
        ((counter++))

        # Si nos encontramos en el primer elemento (el umbral) saltamos al siguiente
        if [ $counter -eq 1 ]; then
            continue
        fi

        # Si el elemento actual supera el umbral lo mostramos
        if [ $element -gt $margin ]; then
            echo "Los gastos del Q$(( $counter - 1 )) superan el umbral de $margin K€"
        fi

    done

}

# Nombre: Create Expenses Directory
# Description: Función que comprueba si existe el directorio de gastos y si no es así lo crea
# Argumentos: 
#   - [STRING] Nombre del directorio a comprobar y crear
# Retorno: Mensaje de la operación realizada
function createExpensesDirectory(){

    # Variables necesarias
    local fullPath=""

    # Obtenemos los parámetros de la función
    local expensesDirectory=$1

    # Configuramos la ruta completa
    fullPath="$(pwd)/$expensesDirectory"

    # Si no existe el directorio lo creamos
    if ! [ -d $fullPath ]; then
        mkdir $fullPath
        echo "Directorio creado en la ruta: $fullPath"
    fi

}

# Nombre: Generate Report
# Descripción: Función que solicita el año para almacenar un reporte de los gastos con el nombre de dicho año
# Argumentos:
#   - [STRING] Nombre del directorio de gastos
#   - [STRING] Gastos del Q1
#   - [STRING] Gastos del Q2
#   - [STRING] Gastos del Q3
#   - [STRING] Gastos del Q4
# Retorno: Mensaje de la operación realizada
function generateReport(){

    # Variables necesarias
    local fullPath=""
    local currentYear=""

    # Obtenemos los parámetros de la función
    local expensesDirectory=$1
    local expensesQ1=$2
    local expensesQ2=$3
    local expensesQ3=$4
    local expensesQ4=$5

    # Nos aseguramos de que exista el directorio de gastos
    createExpensesDirectory $expensesDirectory

    # Obtenemos el año actual
    read -p "Introduzca el año para almacenar el reporte de gastos: " currentYear

    # Configuramos la ruta absoluta
    fullPath="$(pwd)/$expensesDirectory/$currentYear.txt"

    # Volcamos el reporte de gastos anuales al fichero
    getTotalExpenses $expensesQ1 $expensesQ2 $expensesQ3 $expensesQ4 > $fullPath

    echo "Reporte generado con éxito en la ruta: $fullPath"

}

# ========== EJECUCIÓN PRINCIPAL ==========
# Llamamos al main pasándole como parámetros el número de argumentos recibidos por el script y los 4 primeros
main $# $1 $2 $3 $4
exitCode=$?
exit $exitCode