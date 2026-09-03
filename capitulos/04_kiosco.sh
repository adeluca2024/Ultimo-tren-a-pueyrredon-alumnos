#!/usr/bin/env bash

capitulo_04_preparar() {
    mkdir -p -- \
        "$MUNDO/nivel4/microcentro/kiosco/.sotano" \
        "$MUNDO/nivel4/microcentro/garage" \
        "$MUNDO/nivel4/microcentro/boca_subte"
    crear_archivo_si_falta "$MUNDO/nivel4/microcentro/cartel" \
        "RETIRO: dirección norte. SUBTE: cerrado por mantenimiento desde 2521. Disculpe las molestias retroactivas."
    crear_archivo_si_falta "$MUNDO/nivel4/microcentro/kiosco/terminal" \
        $'TERMINAL DE CONSULTAS URBANAS — Versión 2526\nLa navegación manual no alcanza para revisar toda la ciudad.\nBUSCAR un archivo en inglés se dice FIND. Hasta en el fin del mundo hay que saber inglés.\nEjecutá desde microcentro: find . -type f -name mapa\nCuando aparezca la ruta, buscá RETIRO dentro del mapa y resaltalo con grep --color=always.'
    printf '%s\n' \
        "RUTA 01 — OBELISCO: bloqueada por una sombra que cobra fotografías." \
        "RUTA 02 — PUERTO MADERO: inundada. Los peces ahora administran los consorcios." \
        "RUTA 03 — CONSTITUCIÓN: el último tren salió hace cuatrocientos años y todavía figura demorado." \
        "RUTA 04 — ONCE: descartada. Incluso el sistema considera que sería demasiado." \
        "RUTA 05 — RETIRO: continuar por Florida y buscar la entrada de Plaza San Martín." \
        "RUTA 06 — SUBTE: clausurado por presencia de pasajeros sin reflejo." \
        > "$MUNDO/nivel4/microcentro/kiosco/.sotano/mapa"
    printf '%s\n' \
        "Día 182396: se cortó la luz durante siete horas. Nadie notó la diferencia." \
        "Día 182397: un cliente pagó con una moneda fechada en 2026." \
        "Día 182398: cerré la heladera de bebidas. Volvió a abrirse sola." \
        "Día 182399: el tango comenzó a sonar al revés. No encuentro dónde desenchufarlo." \
        "Día 182400: las vidrieras de Florida amanecieron mirando hacia el norte." \
        "Día 182401: las palomas aprendieron a abrir paquetes." \
        "Día 182402: dejaron de aceptar migas; ahora exigen facturas." \
        "Día 182403: algo llegó desde Retiro preguntando por el hombre del reloj." \
        > "$MUNDO/nivel4/microcentro/kiosco/registro"
    crear_archivo_si_falta "$MUNDO/nivel4/microcentro/garage/nota" \
        "El último vehículo se fue sin conductor. Pagó la estadía completa, cosa que lo vuelve inmediatamente sospechoso."
}

capitulo_04_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel4/microcentro"
    titulo "CAPÍTULO 4 — El kiosco que seguía abierto"
    decir "La puerta se cierra detrás tuyo justo cuando algo golpea desde el interior del edificio. Por un instante pensás en volver a mirar. Decidís que algunas preguntas pueden esperar para siempre."
    decir "El Microcentro está desierto. Los semáforos cambian para autos que ya no existen y, desde algún edificio, suena un teléfono que nadie atiende."
    decir "Las raíces han levantado el asfalto y trepan por las fachadas. Muchas calles están bloqueadas, pero en la esquina distinguís un kiosco iluminado."
    decir "El cartel anuncia: 'DOS ALFAJORES POR EL PRECIO DE TRES. OFERTA VÁLIDA HASTA AGOTAR LA PACIENCIA'. Desde el interior suena un tango reproducido al revés."
    decir "No hay vendedor. Sobre el mostrador descansan diarios convertidos en polvo, una taza de café petrificada y una terminal antigua con letras verdes."
    decir "Pegada a la pantalla encontrás una nota: 'Si va a revisar, deje todo como estaba. Incluso el cadáver'."
    decir "Mirás alrededor. No encontrás ningún cadáver. Eso no te tranquiliza."
    decir "La terminal conserva un mapa de evacuación urbana, pero está perdido en algún lugar del sistema. En la pantalla aparece una palabra: BUSCAR."
    decir "Necesitás localizar el mapa, encontrar la ruta que conduce a Retiro y revisar las últimas anotaciones del kiosquero."
}

capitulo_04_ayuda() {
    decir "  mkdir directorio"
    decir "  touch archivo"
    decir "  cp origen destino"
    decir "  mv origen destino"
    decir "  find ruta -type f -name nombre"
    decir "  grep [-i|-n|--color=always] patrón archivo"
    decir "  tail [-n cantidad] archivo"
}

capitulo_04_objetivo() {
    decir "Leé la terminal del kiosco, usá FIND para ubicar el mapa, resaltá RETIRO con grep y leé las últimas tres entradas del registro."
}

capitulo_04_pista() {
    if [[ "${ESTADO[USO_FIND]:-0}" != 1 ]]; then
        if [[ "${ESTADO[LEYO_MAPA]:-0}" == 1 ]]; then
            decir "Encontraste el mapa navegando, pero la terminal pide practicar una búsqueda: find . -type f -name mapa"
        else
            decir "Leé primero kiosco/terminal. BUSCAR en inglés es FIND."
        fi
    elif [[ "${ESTADO[ENCONTRO_RETIRO]:-0}" != 1 ]]; then
        decir "Resaltá RETIRO dentro del mapa: grep --color=always RETIRO kiosco/.sotano/mapa"
    elif [[ "${ESTADO[LEYO_REGISTRO]:-0}" != 1 ]]; then
        decir "Paso 3: leé el final del registro: tail -n 3 kiosco/registro"
    else
        decir "Ya encontraste la ruta. Algo te está esperando cerca de Retiro."
    fi
}

capitulo_04_despues_cat() {
    [[ "$1" == "$MUNDO/nivel4/microcentro/kiosco/.sotano/mapa" ]] && ESTADO[LEYO_MAPA]=1
}

capitulo_04_comando() {
    local orden=$1 ruta opcion="" patron archivo cantidad
    local -a grep_opciones=()
    shift
    case "$orden" in
        find)
            if (( $# == 5 )) && [[ "$1 $2 $3 $4 $5" == ". -type f -name mapa" ]]; then
                ruta=$(resolver_existente_seguro "$1") || { error "ruta inexistente o fuera del mundo."; return 0; }
                command find "$ruta" -type f -name mapa | sed "s#^$MUNDO/##"
            elif (( $# == 3 )) && [[ "$1 $2 $3" == ". -name mapa" ]]; then
                ruta=$(resolver_existente_seguro "$1") || { error "ruta inexistente o fuera del mundo."; return 0; }
                command find "$ruta" -name mapa | sed "s#^$MUNDO/##"
            else
                error "uso habilitado: find . [-type f] -name mapa"; return 0
            fi
            ESTADO[USO_FIND]=1
            ;;
        grep)
            if (( $# == 3 )) && [[ "$1" == "-i" || "$1" == "-n" || "$1" == "--color" || "$1" == "--color=always" ]]; then
                opcion=$1; patron=$2; archivo=$3; grep_opciones=("$opcion")
            elif (( $# == 2 )); then patron=$1; archivo=$2
            else error "uso: grep [-i|-n|--color=always] patrón archivo"; return 0; fi
            ruta=$(resolver_existente_seguro "$archivo") || { error "archivo inexistente o fuera del mundo."; return 0; }
            command grep "${grep_opciones[@]}" -- "$patron" "$ruta"
            if [[ "${patron^^}" == "RETIRO" && "$ruta" == "$MUNDO/nivel4/microcentro/kiosco/.sotano/mapa" ]]; then ESTADO[ENCONTRO_RETIRO]=1; fi
            ;;
        tail)
            if (( $# == 3 )) && [[ "$1" == "-n" && "$2" =~ ^[1-9][0-9]*$ ]]; then cantidad=$2; archivo=$3
            elif (( $# == 2 )) && [[ "$1" =~ ^-n([1-9][0-9]*)$ ]]; then cantidad=${BASH_REMATCH[1]}; archivo=$2
            elif (( $# == 2 )) && [[ "$1" =~ ^-([1-9][0-9]*)$ ]]; then cantidad=${BASH_REMATCH[1]}; archivo=$2
            elif (( $# == 1 )); then cantidad=10; archivo=$1
            else error "uso: tail [-n cantidad] archivo"; return 0; fi
            ruta=$(resolver_existente_seguro "$archivo") || { error "archivo inexistente o fuera del mundo."; return 0; }
            command tail -n "$cantidad" -- "$ruta"
            if [[ "$cantidad" == 3 && "$ruta" == "$MUNDO/nivel4/microcentro/kiosco/registro" ]]; then ESTADO[LEYO_REGISTRO]=1; fi
            ;;
        *) return 1 ;;
    esac
    return 0
}

capitulo_04_evaluar() {
    if [[ "${ESTADO[USO_FIND]:-0}" == 1 && "${ESTADO[ENCONTRO_RETIRO]:-0}" == 1 && "${ESTADO[LEYO_REGISTRO]:-0}" == 1 ]]; then avanzar_nivel; fi
}

capitulo_04_cierre() {
    decir "Terminás de leer la última línea. Algo llegó desde Retiro y estaba preguntando por vos."
    decir "El tango se detiene. La terminal parpadea: 'RUTA CONFIRMADA. CONTINUAR POR FLORIDA. EVITE MIRAR LAS VIDRIERAS'."
    decir "Desde el techo llega un aleteo. Decenas de palomas te observan desde las estanterías. Una sostiene entre las patas un paquete de galletitas perfectamente abierto."
    decir "La paloma inclina la cabeza. Vos hacés lo mismo. Por alguna razón, eso parece ofenderla."
    decir "Salís antes de que las demás decidan intervenir. Frente a vos se extiende Florida, cubierta de papeles y persianas oxidadas."
    decir "A lo lejos distinguís la Torre Monumental. El reloj continúa marcando las 17:42."
}

capitulo_04_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
       | KIOSCO |        |  SUBTE  |
       |________|        |_________|
            \                 X
  ===========\== CALLE FLORIDA =================>
               \          PLAZA SAN MARTÍN
                \               17:42
                 \______________TORRE
ASCII
    printf '%s' "$C_RESET"
}
