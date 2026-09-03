#!/usr/bin/env bash

capitulo_05_preparar() {
    mkdir -p -- \
        "$MUNDO/nivel5/florida/cabina" \
        "$MUNDO/nivel5/florida/vidriera" \
        "$MUNDO/nivel5/florida/pasaje"
    crear_archivo_si_falta "$MUNDO/nivel5/florida/cartel" \
        "CALLE FLORIDA — Peatonal desde 1971. No se informa desde cuándo caminan solos los maniquíes."
    printf '%s\n' \
        "Si todavía podés leer esto, no estás solo; alguien sigue intentando encontrarte." \
        "No vayas hacia el PUERTO: lo que camina bajo el agua aprendió a pronunciar tu nombre." \
        "Para DESPERTAR, buscá el OBELISCO antes de las 1200; esta indicación fue escrita para engañarte." \
        "No respondas a la voz de la TORRE cuando marque 0000: conoce recuerdos que nunca le contaste a nadie." \
        "DESPERTAR TORRE 1742: ESTÁS EN UN SUEÑO. DESPERTÁ, TONTO. LLEGÁ A LA TORRE ANTES DE QUE EL TREN LLEGUE A PUEYRREDÓN." \
        "DESPERTAR TORRE 1742: ESTÁS EN UN SUEÑO. DESPERTÁ, TONTO. LLEGÁ A LA TORRE ANTES DE QUE EL TREN LLEGUE A PUEYRREDÓN." \
        "Si intentás DESPERTAR después de las 1800, la ciudad va a recordar que pertenecés acá." \
        "Cruzá la PLAZA a las 1742 sin mirar las estatuas; cuando las mirás, dejan de acercarse." \
        > "$MUNDO/nivel5/florida/cabina/nota"
    printf '%s\n' \
        "En el margen alguien escribió: 'Hay una sola frase verdadera. Filtrá DESPERTAR, después TORRE y finalmente 1742'." \
        "Debajo agregó: 'Ordená, quitá los duplicados y guardá lo que quede en mensaje'." \
        "La firma fue arrancada. Reconocés la letra y eso te produce una tristeza que no sabés explicar." \
        > "$MUNDO/nivel5/florida/cabina/pista_escrita"
    crear_archivo_si_falta "$MUNDO/nivel5/florida/vidriera/maniqui" \
        "El maniquí no tiene rostro. Cuando dejás de leer, su mano está apoyada del otro lado del vidrio."
}

capitulo_05_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel5/florida"
    titulo "CAPÍTULO 5 — La nota sin firma"
    decir "Avanzás por Florida siguiendo la ruta del mapa. Tus pasos resuenan entre los edificios, aunque a veces escuchás uno más de los que acabás de dar."
    decir "Las persianas están bajas y varias vidrieras fueron destruidas desde adentro. Solo una permanece intacta."
    decir "Detrás del cristal hay una fila de maniquíes vestidos con ropa de oficina. Todos miran hacia la calle. Uno lleva una corbata igual a la tuya."
    decir "Un teléfono comienza a sonar dentro de una cabina. Atendés, pero solo escuchás tu propia respiración con unos segundos de retraso. Antes de colgar distinguís un susurro: 'Deberías rendirte...'."
    decir "En el suelo encontrás una nota doblada. La letra te resulta dolorosamente familiar, aunque no recordás de quién es."
    decir "El texto contiene advertencias, horarios y destinos contradictorios. En el margen, alguien dejó instrucciones para separar una única frase verdadera."
    decir "Desde la vidriera llega un golpe seco. Después otro. Cuando volvés a mirar, uno de los maniquíes ya no está detrás del cristal."
}

capitulo_05_ayuda() {
    decir "  mkdir directorio"
    decir "  touch archivo"
    decir "  cp origen destino"
    decir "  mv origen destino"
    decir "  cat archivo | grep palabra | grep palabra | grep palabra | sort | uniq > destino"
}

capitulo_05_objetivo() {
    decir "Leé la pista escrita y descifrá la nota en un archivo llamado mensaje. Después leé el resultado."
}

capitulo_05_pista() {
    if [[ "${ESTADO[DESCIFRO_MENSAJE]:-0}" != 1 ]]; then
        decir "Leé cabina/pista_escrita. Después ejecutá:"
        decir "cat cabina/nota | grep DESPERTAR | grep TORRE | grep 1742 | sort | uniq > mensaje"
    elif [[ "${ESTADO[LEYO_MENSAJE]:-0}" != 1 ]]; then
        decir "El mensaje quedó guardado. Leelo con: cat mensaje"
    else
        decir "Ya sabés qué hacer: llegar a la torre a las 17:42."
    fi
}

capitulo_05_despues_cat() {
    if [[ "$1" == "$MUNDO/nivel5/florida/"* && "$(basename -- "$1")" == "mensaje" ]]; then
        ESTADO[LEYO_MENSAJE]=1
    fi
}

capitulo_05_procesar_entrada() {
    local entrada=$1 normalizada archivo_nota nota destino
    [[ "$entrada" == *'|'* || "$entrada" == *'>'* ]] || return 1
    normalizada=$(printf '%s' "$entrada" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//; s/ ?\| ?/ | /g; s/ ?> ?/ > /g')
    case "$normalizada" in
        "cat nota | grep DESPERTAR | grep TORRE | grep 1742 | sort | uniq > mensaje") archivo_nota=nota ;;
        "cat cabina/nota | grep DESPERTAR | grep TORRE | grep 1742 | sort | uniq > mensaje") archivo_nota=cabina/nota ;;
        *)
        error "los comandos o filtros no coinciden con la pista. Ejecutá pista."
        return 0
            ;;
    esac
    nota=$(resolver_existente_seguro "$archivo_nota") || { error "no se encontró la nota desde el directorio actual."; return 0; }
    if [[ "$nota" != "$MUNDO/nivel5/florida/cabina/nota" ]]; then
        error "el primer archivo debe ser la nota encontrada en la cabina."
        return 0
    fi
    destino=$(resolver_nuevo_seguro "mensaje") || { error "no se pudo crear mensaje dentro del mundo."; return 0; }
    command cat -- "$nota" \
        | command grep -- "DESPERTAR" \
        | command grep -- "TORRE" \
        | command grep -- "1742" \
        | command sort \
        | command uniq \
        > "$destino"
    ESTADO[DESCIFRO_MENSAJE]=1
    decir "La cadena terminó. El resultado quedó guardado en mensaje."
    return 0
}

capitulo_05_evaluar() {
    if [[ "${ESTADO[DESCIFRO_MENSAJE]:-0}" == 1 && "${ESTADO[LEYO_MENSAJE]:-0}" == 1 ]]; then avanzar_nivel; fi
}

capitulo_05_cierre() {
    decir "Ahora sabés que la Torre no es solamente el lugar donde comenzó todo. También podría ser la única salida."
    decir "El teléfono vuelve a sonar. Una voz idéntica a la tuya dice: 'No llegues tarde otra vez'. La comunicación se corta."
    decir "Detrás tuyo escuchás varios pasos sobre los vidrios. No necesitás mirar para saber que los maniquíes salieron de la vidriera."
    decir "Guardás el mensaje en la mochila y corrés hacia Plaza San Martín. Los pasos te siguen por Florida y se detienen todos al mismo tiempo cuando llegás al final de la peatonal."
    decir "Frente a vos aparece la plaza, cubierta por una niebla espesa. Entre los árboles distinguís varias figuras inmóviles. Parecen estatuas. Esperás que lo sean."
}

capitulo_05_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
       ||  ||  ||       .-17:42-.
       || []  []||      /          \
       ||______||      /    TORRE   \
  ====== FLORIDA =====/==============\===>
          pasos --->       PLAZA
       _o_  _o_  _o_      o     o
ASCII
    printf '%s' "$C_RESET"
}
