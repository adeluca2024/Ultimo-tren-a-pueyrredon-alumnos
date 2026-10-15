#!/usr/bin/env bash

readonly SERVICIO_PID_FILE="${DATA_BASE}/sueno.pid"

capitulo_09_es_servicio() {
    local pid=${1:-} cmdline
    [[ "$pid" =~ ^[1-9][0-9]*$ && -r "/proc/$pid/cmdline" ]] || return 1
    cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
    [[ "$cmdline" == "sueno.service 3600 " ]]
}

capitulo_09_recuperar_servicio() {
    local pid=""
    [[ ! -f "$SERVICIO_PID_FILE" ]] || IFS= read -r pid < "$SERVICIO_PID_FILE"
    if capitulo_09_es_servicio "$pid"; then ESTADO[SERVICIO_PID]=$pid; return 0; fi
    command rm -f -- "$SERVICIO_PID_FILE"; unset 'ESTADO[SERVICIO_PID]'; return 1
}

capitulo_09_iniciar_servicio() {
    capitulo_09_recuperar_servicio && return
    bash -c 'exec -a sueno.service sleep 3600' </dev/null >/dev/null 2>&1 &
    ESTADO[SERVICIO_PID]=$!
    printf '%s\n' "${ESTADO[SERVICIO_PID]}" > "$SERVICIO_PID_FILE"
}

capitulo_09_limpiar() {
    if capitulo_09_recuperar_servicio; then command kill -- "${ESTADO[SERVICIO_PID]}" 2>/dev/null || true; fi
    command rm -f -- "$SERVICIO_PID_FILE"
}

capitulo_09_preparar() {
    mkdir -p -- "$MUNDO/nivel9/anden_0/control" "$MUNDO/nivel9/anden_0/vias"
    printf '%s\n' \
        "CONTROL DEL ANDÉN 0" \
        "El mundo que recorriste depende del servicio principal sueno.service." \
        "Consultá su estado con: systemctl status sueno.service" \
        "Para despertar, el servicio debe quedar detenido." \
        > "$MUNDO/nivel9/anden_0/control/informe"
    crear_archivo_si_falta "$MUNDO/nivel9/anden_0/vias/cartel" \
        "PRÓXIMA FORMACIÓN: PUEYRREDÓN. Demora estimada: quinientos años o cinco minutos de sueño."
}

capitulo_09_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel9/anden_0"
    capitulo_09_iniciar_servicio
    titulo "CAPÍTULO 9 — Andén 0"
    decir "Descendés por la escalera mientras la compuerta se cierra sobre tu cabeza. Con cada escalón, el sonido de los engranajes se vuelve más lejano y el ruido de un tren más intenso."
    decir "Llegás a un andén que no aparece en ningún mapa. No hay bancos ni salidas, solamente una vía que se pierde dentro de un túnel oscuro y tenebroso."
    decir "Un cartel anuncia: 'ANDÉN 0. DESTINO: PUEYRREDÓN. HORARIO DE PARTIDA: 17:42. DEMORA ESTIMADA: 500 AÑOS'."
    decir "Un tren vacío permanece detenido frente a vos. Cada ventana refleja un lugar diferente: la oficina, el kiosco, los maniquíes, las estatuas y la sala del reloj. En ninguna aparecés vos."
    decir "Los altavoces se encienden: 'El proceso sombra_de_la_torre fue detenido correctamente. Sin embargo, el servicio principal continúa en ejecución'."
    decir "'Mientras sueno.service permanezca activo, este entorno seguirá funcionando y el pasajero no podrá despertar'."
    decir "Al final del andén encontrás una cabina de control. Sobre el teclado descansa una credencial idéntica a la que llevás en la mochila."
}

capitulo_09_ayuda() {
    decir "  systemctl status sueno.service"
    decir "  systemctl stop sueno.service"
    decir "  sudo systemctl stop sueno.service"
}

capitulo_09_objetivo() {
    decir "Leé el informe, consultá el servicio principal e intentá detenerlo. Si requiere privilegios, utilizá sudo."
}

capitulo_09_pista() {
    if [[ "${ESTADO[LEYO_CONTROL]:-0}" != 1 ]]; then decir "Paso 1: leé control/informe"
    elif [[ "${ESTADO[CONSULTO_SERVICIO]:-0}" != 1 ]]; then decir "Paso 2: consultá la unidad con: systemctl status sueno.service"
    elif [[ "${ESTADO[INTENTO_SIN_PRIVILEGIOS]:-0}" != 1 ]]; then decir "Paso 3: intentá detenerla con: systemctl stop sueno.service"
    elif [[ "${ESTADO[DETUVO_SERVICIO]:-0}" != 1 ]]; then decir "Paso 4: la operación requiere privilegios: sudo systemctl stop sueno.service"
    fi
}

capitulo_09_despues_cat() {
    [[ "$1" == "$MUNDO/nivel9/anden_0/control/informe" ]] && ESTADO[LEYO_CONTROL]=1
}

capitulo_09_comando() {
    local orden=$1 accion unidad
    shift
    case "$orden" in
        systemctl)
            accion=${1:-}; unidad=${2:-}
            if (( $# != 2 )) || [[ "$unidad" != "sueno.service" || ( "$accion" != "status" && "$accion" != "stop" ) ]]; then
                error "uso habilitado: systemctl status|stop sueno.service"; return 0
            fi
            if [[ "$accion" == "status" ]]; then
                if capitulo_09_recuperar_servicio; then
                    decir "● sueno.service - Servicio principal que mantiene activo el sueño"
                    decir "     Loaded: loaded (mundo del juego; enabled)"
                    decir "     Active: active (running)"
                    decir "   Main PID: ${ESTADO[SERVICIO_PID]} (sueno.service)"
                else
                    decir "○ sueno.service - Servicio ficticio que mantiene activo el sueño"
                    decir "     Active: inactive (dead)"
                fi
                ESTADO[CONSULTO_SERVICIO]=1
            else
                capitulo_09_recuperar_servicio || { error "sueno.service ya está detenido."; return 0; }
                ESTADO[INTENTO_SIN_PRIVILEGIOS]=1
                error "operación rechazada: se requieren privilegios administrativos."
                decir "La credencial encontrada habilita una única operación con sudo."
            fi
            ;;
        sudo)
            if (( $# == 3 )) && [[ "$1 $2 $3" == "systemctl status sueno.service" ]]; then
                decir "La consulta de estado no requiere privilegios; sudo no era necesario."
                if capitulo_09_recuperar_servicio; then
                    decir "● sueno.service - Servicio principal que mantiene activo el sueño"
                    decir "     Loaded: loaded (mundo del juego; enabled)"
                    decir "     Active: active (running)"
                    decir "   Main PID: ${ESTADO[SERVICIO_PID]} (sueno.service)"
                else
                    decir "○ sueno.service - Servicio ficticio que mantiene activo el sueño"
                    decir "     Active: inactive (dead)"
                fi
                ESTADO[CONSULTO_SERVICIO]=1
                return 0
            fi
            if (( $# != 3 )) || [[ "$1 $2 $3" != "systemctl stop sueno.service" ]]; then
                error "uso habilitado: systemctl status sueno.service | sudo systemctl stop sueno.service"
                return 0
            fi
            if [[ "${ESTADO[CONSULTO_SERVICIO]:-0}" != 1 || "${ESTADO[INTENTO_SIN_PRIVILEGIOS]:-0}" != 1 ]]; then
                error "primero consultá el servicio e intentá detenerlo sin privilegios."; return 0
            fi
            capitulo_09_recuperar_servicio || { error "sueno.service ya está detenido."; return 0; }
            command kill -- "${ESTADO[SERVICIO_PID]}"; command rm -f -- "$SERVICIO_PID_FILE"; unset 'ESTADO[SERVICIO_PID]'
            ESTADO[DETUVO_SERVICIO]=1
            decir "sueno.service se detuvo correctamente."
            NIVEL=10; guardar_progreso; capitulo_09_final; SALIR_JUEGO=1
            ;;
        *) return 1 ;;
    esac
    return 0
}

capitulo_09_final() {
    titulo "FINAL — PRÓXIMA ESTACIÓN: PUEYRREDÓN"
    decir "Las luces del andén comienzan a apagarse una tras otra, desde el fondo del túnel hasta llegar a la cabina de control. En las ventanas del tren, los maniquíes se desvanecen y las estatuas inclinan lentamente la cabeza."
    decir "El último reflejo muestra tu oficina tal como era antes de que comenzara todo. Los escritorios están intactos, la luz de la tarde entra por las ventanas y, sobre tu escritorio, distinguís una fotografía de tu familia."
    decir "La oscuridad alcanza finalmente la cabina. Antes de que la terminal se apague, los altavoces emiten un último mensaje distorsionado: 'Servicio principal detenido. Iniciando procedimiento de despertar'."
    decir "La estación comienza a desarmarse a tu alrededor. Las paredes se fragmentan en pequeñas líneas de texto que ascienden y desaparecen, mientras los rieles se doblan hacia el techo como si hubieran perdido todo peso."
    decir "Entonces el tren avanza directamente hacia vos. Intentás apartarte, pero tu cuerpo ya no responde. El ruido de los motores crece hasta llenar toda la estación. Cerrás los ojos cuando escuchás el chirrido de los frenos a pocos metros de distancia."
    decir "Después, solamente queda el silencio."
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
       __________________________________________________________
      |                    VILLA PUEYRREDÓN                       |
      |___________________________________________________________|
              ||                                         ||
     __________||_________________       __________________||__________
    /  LÍNEA MITRE          17:43 \_____/  LÍNEA MITRE               \
   |  [__]  [__]  [__]  [__]     |     |  [__]  [__]  [__]  [__]   |
   |_______________________________|_____|____________________________|
       O--O       O--O       O--O             O--O       O--O
  =====================================================================
ASCII
    printf '%s\n' "$C_RESET"
    decir "Abrís los ojos de golpe. Estás sentado junto a la ventana de un tren de la línea Mitre, con la frente apoyada contra el vidrio. Durante unos segundos no reconocés dónde estás: la ciudad abandonada, los maniquíes y la Torre todavía parecen más reales que los pasajeros a tu alrededor."
    decir "Entonces una voz anuncia por los altavoces: 'Próxima estación: Pueyrredón'. Consultás tu reloj. Son las 17:43. Desde que miraste la Torre Monumental solamente transcurrió un minuto."
    decir "El tren se detiene y las puertas se abren. Todavía confundido, te levantás, bajás del vagón y recorrés el andén en dirección a la salida. Los demás pasajeros continúan con sus vidas sin prestarte atención. Nadie parece haber visto la ciudad destruida ni escuchado aquella otra voz."
    decir "Mientras caminás, metés una mano en el bolsillo y sentís algo que no recordabas llevar. Lo sacás y reconocés inmediatamente la credencial del ascensor con la que escapaste del edificio del Microcentro."
    decir "En el frente tiene grabada una fecha de fabricación: JULIO DE 2526. Te detenés durante unos segundos, pero finalmente decidís guardarla. Tal vez todavía no estés preparado para cuestionar lo que acaba de suceder."
    decir "Continuás caminando hacia la salida preguntándote si realmente fue un sueño... o si el proceso principal todavía sigue corriendo en algún lugar."
    decir "FIN"
}
