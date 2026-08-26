#!/usr/bin/env bash

capitulo_03_preparar() {
    mkdir -p -- \
        "$MUNDO/nivel3/planta_baja/deposito" \
        "$MUNDO/nivel3/planta_baja/tablero" \
        "$MUNDO/nivel3/planta_baja/salida"
    crear_archivo_si_falta "$MUNDO/nivel3/planta_baja/.codigo_emergencia" \
        $'CÓDIGO DE EMERGENCIA: 1708\nEl tablero necesita además un fusible.\nSi encuentra a la criatura en la recepción, no la alimente después de medianoche.\nTampoco antes y, sobre todo, no deje que se alimente de usted. En realidad, nadie sabe quién escribió esto.'
    crear_archivo_si_falta "$MUNDO/nivel3/planta_baja/deposito/fusible" \
        $'Fusible industrial.\nPROPIEDAD DEL EDIFICIO.\nDevolver antes del fin del mundo.'
    crear_archivo_si_falta "$MUNDO/nivel3/planta_baja/deposito/mapa_evacuacion" \
        "SALIDA A LA CALLE: atravesar recepción. Si el portero no tiene rostro, evitar conversación sobre fútbol."
}

capitulo_03_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel3/planta_baja"
    titulo "CAPÍTULO 3 — La planta baja respira"
    decir "Esperabas encontrar un subsuelo, un estacionamiento o, por lo menos, alguna explicación razonable para el número -12."
    decir "En cambio, reconocés la planta baja del edificio. El mostrador de recepción está volcado y los sillones aparecen cubiertos por una vegetación oscura que nace entre las baldosas."
    decir "Del techo cuelgan cables cortados que se balancean, aunque no corre una sola corriente de aire. El indicador del ascensor continúa marcando -12. Decidís no discutir con él."
    decir "Das un paso fuera de la cabina. Las puertas se cierran inmediatamente y el ascensor comienza a subir sin vos."
    decir "Desde algún lugar detrás del mostrador escuchás un ruido húmedo. Algo se arrastra lentamente por el suelo y se detiene cuando vos te detenés."
    decir "La salida permanece bloqueada por el sistema de emergencia. Junto a ella hay un tablero abierto: le falta un fusible y la pantalla solicita un código que nadie dejó a la vista."
    decir "Un cartel indica: 'EN CASO DE EMERGENCIA, CONSERVE LA CALMA. Si no puede conservarla, procure gritar en horario administrativo'."
    decir "Necesitás encontrar el código oculto, recuperar el fusible y conseguir un mapa antes de abrir la salida."
}

capitulo_03_objetivo() {
    decir "Encontrá y leé el código oculto, mové el fusible a tablero/ y copiá mapa_evacuacion dentro de salida/."
}

capitulo_03_pista() {
    if [[ "${ESTADO[VIO_OCULTOS]:-0}" != 1 ]]; then
        decir "Paso 1: buscá archivos ocultos con: ls -a"
    elif [[ "${ESTADO[LEYO_CODIGO]:-0}" != 1 ]]; then
        decir "Paso 2: el código solo debe leerse: cat .codigo_emergencia"
    elif [[ ! -f "$MUNDO/nivel3/planta_baja/tablero/fusible" ]]; then
        decir "Paso 3: instalá el fusible: mv deposito/fusible tablero/fusible"
    elif [[ "${ESTADO[INGRESO_CODIGO]:-0}" != 1 ]]; then
        decir "Paso 4: el tablero ya tiene energía. Ingresá el código cuando lo solicite."
    elif [[ ! -f "$MUNDO/nivel3/planta_baja/salida/mapa" \
        && ! -f "$MUNDO/nivel3/planta_baja/salida/mapa_evacuacion" ]]; then
        decir "Paso 5: copiá el mapa: cp deposito/mapa_evacuacion salida/"
    else
        decir "Todo está en su lugar. Ejecutá objetivo para revisar la misión."
    fi
}

capitulo_03_despues_ls() {
    [[ "$1" == *a* ]] && ESTADO[VIO_OCULTOS]=1
}

capitulo_03_despues_cat() {
    [[ "$1" == "$MUNDO/nivel3/planta_baja/.codigo_emergencia" ]] && ESTADO[LEYO_CODIGO]=1
}

capitulo_03_antes_prompt() {
    local codigo
    if [[ "${ESTADO[LEYO_CODIGO]:-0}" == 1 \
        && "${ESTADO[INGRESO_CODIGO]:-0}" != 1 \
        && -f "$MUNDO/nivel3/planta_baja/tablero/fusible" ]]; then
        titulo "TABLERO DE EMERGENCIA"
        decir "El fusible encaja. La pantalla cobra vida y solicita el código de cuatro cifras."
        printf 'TABLERO — INGRESE CÓDIGO: '
        if ! IFS= read -r codigo; then decir ""; guardar_progreso; SALIR_JUEGO=1; return 0; fi
        decir ""
        if [[ "$codigo" == "1708" ]]; then
            ESTADO[INGRESO_CODIGO]=1
            decir "CÓDIGO ACEPTADO. MECANISMO DE SALIDA HABILITADO."
            evaluar_nivel
        else
            decir "CÓDIGO INCORRECTO. Intentos restantes: demasiados. La administración dejó de contarlos."
        fi
        return 0
    fi
    return 1
}

capitulo_03_evaluar() {
    if [[ "${ESTADO[VIO_OCULTOS]:-0}" == 1 \
        && "${ESTADO[LEYO_CODIGO]:-0}" == 1 \
        && "${ESTADO[INGRESO_CODIGO]:-0}" == 1 \
        && -f "$MUNDO/nivel3/planta_baja/tablero/fusible" \
        && ( -f "$MUNDO/nivel3/planta_baja/salida/mapa" \
            || -f "$MUNDO/nivel3/planta_baja/salida/mapa_evacuacion" ) ]]; then
        avanzar_nivel
    fi
}

capitulo_03_cierre() {
    printf '%sCapítulo superado.%s La puerta se abre. El aire de la calle huele a lluvia vieja y cables quemados.\n' "$C_OK" "$C_RESET"
    decir "Las luces se encienden una por una, avanzando desde el depósito hacia la recepción."
    decir "Con cada luz distinguís un poco más de aquello que se escondía detrás del mostrador. Primero ves una mano. Después otra. Después demasiadas."
    decir "Las puertas se abren con una lentitud insoportable. No esperás a que terminen: apretás la mochila contra el cuerpo, sujetás el mapa y te escurrís por la abertura."
    decir "Detrás tuyo, algo golpea la puerta. Una vez. Dos veces. Después escuchás la voz infantil del ascensor: 'Se olvidó de registrar su salida'."
    decir "Estás en la calle. Los edificios del Microcentro se levantan cubiertos de raíces bajo el cielo amarillo. A lo lejos, el Obelisco sobresale entre las torres abandonadas."
    decir "Pero vos necesitás ir en la dirección contraria. Hacia Retiro."
}

capitulo_03_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
      _______          /\             __________
     | [] [] |        /  \           | []  []  |
  ___| [] [] |___    /    \      ____| []  []  |____
 | []  []  []  [] |  |    |     | []  []  []  []  [] |
 | []  []  []  [] |  |    |     | []  []  []  []  [] |
_|________________|__|____|_____|____________________|_
              EL MICROCENTRO, AÑO 2526
ASCII
    printf '%s' "$C_RESET"
}
