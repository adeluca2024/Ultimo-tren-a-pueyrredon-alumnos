#!/usr/bin/env bash

capitulo_07_preparar() {
    mkdir -p -- \
        "$MUNDO/nivel7/plaza/garita" \
        "$MUNDO/nivel7/plaza/.senderos/norte/pasaje" \
        "$MUNDO/nivel7/plaza/estatuas"
    if [[ ! -e "$MUNDO/nivel7/plaza/garita/advertencia" ]]; then
        printf '%s\n' \
            "MANTENIMIENTO DE LA TORRE — ACCESO DE EMERGENCIA" \
            "El sendero visible termina en una reja." \
            "El pasaje verdadero está oculto en: .senderos/norte/pasaje" \
            "El sistema de navegación solamente reconoce una entrada llamada acceso_torre." \
            "Creá un enlace simbólico con ese nombre y utilizalo para atravesar la reja." \
            "No mires a la estatua del caballo durante más de diez segundos o te atacará y te comerá. Lo haría si no fuera una estatua de piedra, que no come... pero aterroriza." \
            > "$MUNDO/nivel7/plaza/garita/advertencia"
        command chmod 000 -- "$MUNDO/nivel7/plaza/garita/advertencia"
    fi
    crear_archivo_si_falta "$MUNDO/nivel7/plaza/.senderos/norte/pasaje/destino" \
        "El pasaje desemboca frente a la Torre Monumental. El reloj sigue inmóvil en 17:42."
    crear_archivo_si_falta "$MUNDO/nivel7/plaza/estatuas/cartel" \
        "PATRIMONIO HISTÓRICO. Prohibido alimentar, tocar o mantener contacto visual con las estatuas después del atardecer."
}

capitulo_07_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel7/plaza"
    titulo "CAPÍTULO 7 — Las estatuas no parpadean"
    decir "Entrás en Plaza San Martín sin mirar hacia atrás. Los pasos de los maniquíes se detuvieron al comienzo de la plaza, como si algo les impidiera atravesarla. Eso debería tranquilizarte. No lo hace."
    decir "La niebla se desliza entre los árboles. A ambos lados del sendero hay estatuas: algunas pertenecen a monumentos que recordás; otras no deberían estar allí."
    decir "Una representa a un hombre sin rostro sosteniendo un reloj. Otra muestra una mujer con la boca tapada y un dedo señalando hacia la Torre."
    decir "Escuchás un golpe de piedra detrás de vos. Te detenés. El sonido también se detiene. Cuando girás, las estatuas parecen estar en el mismo lugar. Parecen."
    decir "Cerca de una reja encontrás una garita. En su terminal aparece un archivo llamado advertencia, pero no tiene permiso de lectura."
    decir "Debajo del monitor, un cartel informa: 'Si usted puede leer el archivo, entonces ya no está protegido. La administración agradece no pensar demasiado en esta contradicción'."
    decir "Necesitás recuperar el permiso, descubrir el sendero oculto y crear un acceso hacia la Torre."
}

capitulo_07_ayuda() {
    decir "  mkdir directorio"
    decir "  touch archivo"
    decir "  cp origen destino"
    decir "  mv origen destino"
    decir "  chmod u+r archivo | chmod 644 archivo"
    decir "  ln -s destino enlace"
}

capitulo_07_objetivo() {
    decir "Recuperá el permiso de garita/advertencia, descubrí el sendero oculto y creá el enlace simbólico acceso_torre."
}

capitulo_07_pista() {
    if [[ "${ESTADO[LEYO_ADVERTENCIA]:-0}" != 1 ]]; then
        decir "Inspeccioná los permisos con:"
        decir "ls -l garita/advertencia"
        decir "Después habilitá la lectura con una de estas formas:"
        decir "chmod u+r garita/advertencia"
        decir "chmod 644 garita/advertencia"
    elif [[ "${ESTADO[DESCUBRIO_SENDERO]:-0}" != 1 ]]; then
        decir "El aviso menciona un sendero oculto. Mostralo con: ls -a"
    elif [[ "${ESTADO[CREO_ENLACE]:-0}" != 1 ]]; then
        decir "Mostrá primero el sendero oculto con: ls -a"
        decir "Después creá el acceso: ln -s .senderos/norte/pasaje acceso_torre"
    else
        decir "El acceso a la torre está preparado."
    fi
}

capitulo_07_despues_ls() {
    if [[ "$1" == *a* && "$2" == "$MUNDO/nivel7/plaza" ]]; then ESTADO[DESCUBRIO_SENDERO]=1; fi
}

capitulo_07_despues_cat() {
    [[ "$1" == "$MUNDO/nivel7/plaza/garita/advertencia" ]] && ESTADO[LEYO_ADVERTENCIA]=1
}

capitulo_07_comando() {
    local orden=$1 modo archivo ruta objetivo enlace destino_real enlace_real
    shift
    case "$orden" in
        chmod)
            if (( $# == 2 )); then modo=$1; archivo=$2
            elif (( $# == 3 )) && [[ "$1" == "u+r" ]]; then modo=$1; archivo=$2; error "uso: chmod u+r archivo o chmod 644 archivo"; return 0
            else error "uso habilitado: chmod u+r archivo | chmod 644 archivo"; return 0; fi
            [[ "$modo" == "u+r" || "$modo" == "644" ]] || { error "uso habilitado: chmod u+r archivo | chmod 644 archivo"; return 0; }
            ruta=$(resolver_existente_seguro "$archivo") || { error "archivo inexistente o fuera del mundo."; return 0; }
            command chmod "$modo" -- "$ruta"
            ;;
        ln)
            if (( $# != 3 )) || [[ "$1" != "-s" ]]; then error "uso habilitado: ln -s destino enlace"; return 0; fi
            objetivo=$2; enlace=$3
            [[ "${ESTADO[DESCUBRIO_SENDERO]:-0}" == 1 ]] || { error "primero descubrí el sendero oculto con ls -a."; return 0; }
            destino_real=$(resolver_existente_seguro "$objetivo") || { error "destino inexistente o fuera del mundo."; return 0; }
            enlace_real=$(resolver_nuevo_seguro "$enlace") || { error "enlace inválido o fuera del mundo."; return 0; }
            if [[ "$destino_real" != "$MUNDO/nivel7/plaza/.senderos/norte/pasaje" || "$enlace_real" != "$MUNDO/nivel7/plaza/acceso_torre" ]]; then
                error "el acceso debe llamarse acceso_torre y apuntar al pasaje oculto indicado."; return 0
            fi
            command ln -s -- "$objetivo" "$enlace_real"
            ESTADO[CREO_ENLACE]=1
            ;;
        *) return 1 ;;
    esac
    return 0
}

capitulo_07_evaluar() {
    if [[ "${ESTADO[LEYO_ADVERTENCIA]:-0}" == 1 && "${ESTADO[DESCUBRIO_SENDERO]:-0}" == 1 \
        && "${ESTADO[CREO_ENLACE]:-0}" == 1 && -L "$MUNDO/nivel7/plaza/acceso_torre" ]]; then avanzar_nivel; fi
}

capitulo_07_cierre() {
    decir "A simple vista no cambió nada, pero al acercarte a la reja descubrís una abertura donde antes solo había barrotes."
    decir "Atravesás el enlace. Detrás tuyo escuchás un estruendo de piedra contra piedra: las estatuas ya no intentan ocultar que se están moviendo."
    decir "Caminás sin mirar atrás. Cada vez que acelerás, los pasos de piedra también aceleran. Cada vez que te detenés, la plaza queda completamente en silencio."
    decir "La niebla comienza a disiparse. Frente a vos se levanta la Torre Monumental, mucho más alta de lo que recordabas. Detrás de cada ventana distinguís una figura observándote."
    decir "El reloj continúa marcando las 17:42. A tus espaldas, una voz de piedra susurra: 'Llegaste tarde'."
    decir "La puerta de la Torre se abre sola."
}

capitulo_07_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
         o        o        o
        /|\      /|\      /|\
   _____/ \______/ \______/ \________
              PLAZA SAN MARTÍN
                       \
                        \ acceso_torre
                         \________________
                                          ||
                                      ____||____
                                     /   17:42  \
                                    |    TORRE   |
                                    |      ()    |
                                    |_____||||___|
ASCII
    printf '%s' "$C_RESET"
}
