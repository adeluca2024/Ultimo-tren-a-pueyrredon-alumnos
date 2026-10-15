#!/usr/bin/env bash

readonly PROCESO_PID_FILE="${DATA_BASE}/sombra.pid"

capitulo_08_es_proceso() {
    local pid=${1:-} cmdline
    [[ "$pid" =~ ^[1-9][0-9]*$ && -r "/proc/$pid/cmdline" ]] || return 1
    cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
    [[ "$cmdline" == "sombra_de_la_torre 3600 " ]]
}

capitulo_08_recuperar_proceso() {
    local pid=""
    [[ ! -f "$PROCESO_PID_FILE" ]] || IFS= read -r pid < "$PROCESO_PID_FILE"
    if capitulo_08_es_proceso "$pid"; then ESTADO[SOMBRA_PID]=$pid; return 0; fi
    command rm -f -- "$PROCESO_PID_FILE"; unset 'ESTADO[SOMBRA_PID]'; return 1
}

capitulo_08_iniciar_proceso() {
    capitulo_08_recuperar_proceso && return
    bash -c 'exec -a sombra_de_la_torre sleep 3600' </dev/null >/dev/null 2>&1 &
    ESTADO[SOMBRA_PID]=$!
    printf '%s\n' "${ESTADO[SOMBRA_PID]}" > "$PROCESO_PID_FILE"
}

capitulo_08_limpiar() {
    if capitulo_08_recuperar_proceso; then command kill -- "${ESTADO[SOMBRA_PID]}" 2>/dev/null || true; fi
    command rm -f -- "$PROCESO_PID_FILE"
}

capitulo_08_preparar() {
    mkdir -p -- \
        "$MUNDO/nivel8/torre/sala_reloj" \
        "$MUNDO/nivel8/torre/escalera" \
        "$MUNDO/nivel8/torre/mecanismo"
    printf '%s\n' \
        "DIAGNÓSTICO DEL RELOJ" \
        "El mecanismo está bloqueado por un proceso llamado:" \
        "sombra_de_la_torre" \
        "1. Observá todos los procesos con: ps -ef" \
        "2. Encontrá su PID con: pgrep -f sombra_de_la_torre" \
        "3. Terminá únicamente ese PID con: kill PID" \
        "No uses kill -9. La Torre tiene que poder cerrar los ojos." \
        > "$MUNDO/nivel8/torre/sala_reloj/diagnostico"
    crear_archivo_si_falta "$MUNDO/nivel8/torre/mecanismo/placa" \
        "Fabricado en 1916. Modificado en 2526. Garantía anulada por alteración temporal y nido de palomas."
}

capitulo_08_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel8/torre"
    capitulo_08_iniciar_proceso
    titulo "CAPÍTULO 8 — El proceso de la Torre"
    decir "La puerta se cierra apenas entrás. Durante unos segundos escuchás a las estatuas golpeando desde afuera. Después, todas se detienen al mismo tiempo."
    decir "El interior es mucho más grande de lo que debería ser. Sobre tu cabeza, cientos de engranajes giran en direcciones opuestas. Entre ellos cuelgan cables, raíces y objetos que no pertenecen a ningún reloj."
    decir "Subís por una escalera de hierro. Tus pasos producen un eco que regresa con retraso. Primero escuchás tus propios pasos. Después escuchás uno adicional."
    decir "Al llegar a la sala del reloj encontrás una terminal conectada al mecanismo principal. La pantalla muestra cientos de procesos activos."
    decir "Del otro lado distinguís una sombra con tu altura y tu forma. Sus movimientos ocurren unos segundos después que los tuyos. Levantás una mano y la sombra te imita. Bajás la mano. La sombra no."
    decir "La terminal informa que un proceso está bloqueando el mecanismo. Necesitás identificarlo y terminarlo antes de que la sombra complete tus movimientos por su cuenta."
}

capitulo_08_ayuda() {
    decir "  ps -ef | ps aux"
    decir "  pgrep -f nombre"
    decir "  kill PID"
}

capitulo_08_objetivo() {
    decir "Leé el diagnóstico, observá los procesos, identificá sombra_de_la_torre y terminá únicamente su PID."
}

capitulo_08_pista() {
    if [[ "${ESTADO[LEYO_DIAGNOSTICO]:-0}" != 1 ]]; then decir "Paso 1: leé sala_reloj/diagnostico"
    elif [[ "${ESTADO[VIO_PROCESOS]:-0}" != 1 ]]; then decir "Paso 2: observá todos los procesos con: ps -ef"
    elif [[ "${ESTADO[IDENTIFICO_SOMBRA]:-0}" != 1 ]]; then decir "Paso 3: encontrá el PID con: pgrep -f sombra_de_la_torre"
    elif [[ "${ESTADO[DETUVO_SOMBRA]:-0}" != 1 ]]; then decir "Paso 4: reemplazá PID por el número obtenido: kill PID"
    else decir "La sombra se detuvo. El mecanismo vuelve a moverse."
    fi
}

capitulo_08_despues_cat() {
    [[ "$1" == "$MUNDO/nivel8/torre/sala_reloj/diagnostico" ]] && ESTADO[LEYO_DIAGNOSTICO]=1
}

capitulo_08_comando() {
    local orden=$1 pid
    shift
    case "$orden" in
        ps)
            if (( $# != 1 )) || [[ "$1" != "-ef" && "$1" != "aux" ]]; then error "uso habilitado: ps -ef | ps aux"; return 0; fi
            command ps "$1"; ESTADO[VIO_PROCESOS]=1
            ;;
        pgrep)
            if (( $# != 2 )) || [[ "$1 $2" != "-f sombra_de_la_torre" ]]; then error "uso habilitado: pgrep -f sombra_de_la_torre"; return 0; fi
            if capitulo_08_recuperar_proceso; then printf '%s\n' "${ESTADO[SOMBRA_PID]}"; ESTADO[IDENTIFICO_SOMBRA]=1; else error "el proceso sombra_de_la_torre ya no está activo."; fi
            ;;
        kill)
            pid=${1:-}
            if (( $# != 1 )) || [[ ! "$pid" =~ ^[1-9][0-9]*$ ]]; then error "uso habilitado: kill PID"; return 0; fi
            capitulo_08_recuperar_proceso || { error "el proceso sombra_de_la_torre ya no está activo."; return 0; }
            [[ "$pid" == "${ESTADO[SOMBRA_PID]}" ]] || { error "ese PID no pertenece a sombra_de_la_torre. No se terminó ningún proceso."; return 0; }
            command kill -- "$pid"; command rm -f -- "$PROCESO_PID_FILE"; unset 'ESTADO[SOMBRA_PID]'; ESTADO[DETUVO_SOMBRA]=1
            decir "Proceso $pid terminado."
            decir "La sombra se detiene. Por primera vez desde que entraste, no imita tus movimientos."
            decir "Su cabeza gira hacia la terminal. Después vuelve a mirarte y comienza a plegarse sobre sí misma, como si alguien intentara guardarla dentro de una caja demasiado pequeña."
            decir "Antes de desaparecer utiliza tu propia voz: 'Si me detenés, algo peor va a despertar'."
            ;;
        *) return 1 ;;
    esac
    return 0
}

capitulo_08_evaluar() {
    if [[ "${ESTADO[LEYO_DIAGNOSTICO]:-0}" == 1 && "${ESTADO[VIO_PROCESOS]:-0}" == 1 \
        && "${ESTADO[IDENTIFICO_SOMBRA]:-0}" == 1 && "${ESTADO[DETUVO_SOMBRA]:-0}" == 1 ]]; then avanzar_nivel; fi
}

capitulo_08_cierre() {
    decir "Los engranajes quedan inmóviles. Durante un segundo, la Torre permanece completamente en silencio."
    decir "Entonces el mecanismo vuelve a funcionar con un golpe que hace temblar las paredes. Las agujas avanzan por primera vez: 17:42... 17:43."
    decir "Debajo de la terminal se abre una compuerta. Una escalera desciende hacia la oscuridad y, desde el fondo, llega el sonido de un tren frenando sobre las vías."
    decir "Un cartel se enciende: 'ANDÉN 0. SERVICIO INTERRUMPIDO. PRÓXIMA FORMACIÓN: PUEYRREDÓN'."
    decir "Cuando comenzás a bajar, los altavoces reproducen un último mensaje: 'El proceso finalizó correctamente. El usuario, todavía no'."
}

capitulo_08_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
              .-17:43-.
             /    |     \
            |  -- + --  |
             \____|____/
                 ||
                 ||
            _____||_____
           |             |
           |   ANDÉN 0   |
           |      ↓      |
           |_____________|
ASCII
    printf '%s' "$C_RESET"
}
