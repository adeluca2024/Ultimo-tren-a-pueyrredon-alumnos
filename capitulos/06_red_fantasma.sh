#!/usr/bin/env bash

capitulo_06_preparar() {
    mkdir -p -- "$MUNDO/nivel6/red_fantasma/cabina"
    capitulo_06_actualizar_estado_red
}

capitulo_06_actualizar_estado_red() {
    if [[ "${ESTADO[RENOVO_DIRECCION]:-0}" == 1 ]]; then
        printf '%s\n' \
            "RED DE EMERGENCIA CONECTADA" \
            "INTERFAZ: terminal0" \
            "DIRECCIÓN IP: 10.17.42.26/24" \
            "DESTINO: torre.local" \
            "USUARIO REMOTO: operador" \
            > "$MUNDO/nivel6/red_fantasma/cabina/estado_red"
    else
        printf '%s\n' \
            "RED DE EMERGENCIA DESCONECTADA" \
            "INTERFAZ: terminal0" \
            "DIRECCIÓN IP: NO ASIGNADA" \
            "DESTINO PENDIENTE: torre.local" \
            "USUARIO REMOTO: operador" \
            > "$MUNDO/nivel6/red_fantasma/cabina/estado_red"
    fi
}

capitulo_06_iniciar() {
    DIRECTORIO_ACTUAL="$MUNDO/nivel6/red_fantasma"
    titulo "CAPÍTULO 6 — La red fantasma"
    decir "El teléfono vuelve a sonar. Atendés, pero solamente escuchás tonos metálicos, como si dos máquinas intentaran comunicarse a través de una línea construida para humanos."
    decir "Debajo del aparato descubrís una terminal de mantenimiento. Un cable atraviesa la pared de la cabina y continúa bajo las baldosas, en dirección a Plaza San Martín."
    decir "La pantalla indica:"
    decir "'RED DE EMERGENCIA DESCONECTADA."
    decir "INTERFAZ: terminal0."
    decir "DIRECCIÓN IP: NO ASIGNADA."
    decir "DESTINO PENDIENTE: torre.local."
    decir "USUARIO REMOTO: operador'."
    decir "La terminal conserva una sesión de mantenimiento perteneciente a operador. Si recuperás la red, ese usuario debería permitirte entrar en la Torre mediante SSH."
    decir "Necesitás obtener una dirección, comprobar la conexión y acceder remotamente a la Torre."
}

capitulo_06_ayuda() {
    decir "  mkdir directorio"
    decir "  touch archivo"
    decir "  cp origen destino"
    decir "  mv origen destino"
    decir "  ip address show | ip addr show [terminal0] | ip a"
    decir "  sudo dhclient [-r] terminal0"
    decir "  ping torre.local | ping -c 3 torre.local"
    decir "  ssh operador@torre.local"
}

capitulo_06_objetivo() {
    decir "Restablecé la red de la cabina, comprobá la conexión con torre.local y accedé mediante SSH."
}

capitulo_06_pista() {
    if [[ "${ESTADO[VIO_INTERFAZ]:-0}" != 1 ]]; then decir "Paso 1: inspeccioná la interfaz: ip addr show terminal0"
    elif [[ "${ESTADO[LIBERO_DIRECCION]:-0}" != 1 ]]; then decir "Paso 2: liberá la dirección anterior: sudo dhclient -r terminal0"
    elif [[ "${ESTADO[RENOVO_DIRECCION]:-0}" != 1 ]]; then decir "Paso 3: solicitá una dirección: sudo dhclient terminal0"
    elif [[ "${ESTADO[COMPROBO_TORRE]:-0}" != 1 ]]; then decir "Paso 4: comprobá la conexión: ping -c 3 torre.local"
    elif [[ "${ESTADO[CONECTO_SSH]:-0}" != 1 ]]; then decir "Paso 5: conectate con: ssh operador@torre.local"
    fi
}

capitulo_06_comando() {
    local orden=$1 pausa respuesta argumentos
    shift
    case "$orden" in
        ip)
            argumentos="$*"
            case "$argumentos" in
                "a"|"addr show"|"addr show terminal0"|"address show"|"address show terminal0"|"a show terminal0") ;;
                *) error "uso habilitado: ip address show | ip addr show [terminal0] | ip a"; return 0 ;;
            esac
            decir "7: terminal0: <BROADCAST,MULTICAST,UP> mtu 1500 state UP"
            decir "    link/ether 17:42:25:26:00:01"
            if [[ "${ESTADO[RENOVO_DIRECCION]:-0}" == 1 ]]; then decir "    inet 10.17.42.26/24 scope global dynamic terminal0"; else decir "    DIRECCIÓN IP: NO ASIGNADA"; fi
            ESTADO[VIO_INTERFAZ]=1
            ;;
        sudo)
            if (( $# == 3 )) && [[ "$1 $2 $3" == "dhclient -r terminal0" ]]; then
                [[ "${ESTADO[VIO_INTERFAZ]:-0}" == 1 ]] || { error "primero inspeccioná terminal0."; return 0; }
                ESTADO[LIBERO_DIRECCION]=1
                ESTADO[RENOVO_DIRECCION]=0
                capitulo_06_actualizar_estado_red
                decir "Dirección anterior liberada. La terminal ya no pertenece a ninguna red."
            elif (( $# == 2 )) && [[ "$1 $2" == "dhclient terminal0" ]]; then
                [[ "${ESTADO[LIBERO_DIRECCION]:-0}" == 1 ]] || { error "primero liberá la dirección anterior."; return 0; }
                decir "DHCPDISCOVER on terminal0"
                decir "DHCPOFFER from 10.17.42.1"
                decir "DHCPREQUEST for 10.17.42.26"
                decir "DHCPACK from 10.17.42.1"
                decir "Dirección IP asignada: 10.17.42.26/24"
                decir "DNS configurado: torre.local"
                ESTADO[RENOVO_DIRECCION]=1
                capitulo_06_actualizar_estado_red
            else error "uso habilitado: sudo dhclient [-r] terminal0"; fi
            ;;
        ping)
            if ! { (( $# == 1 )) && [[ "$1" == "torre.local" ]]; } \
                && ! { (( $# == 3 )) && [[ "$1 $2 $3" == "-c 3 torre.local" ]]; }; then
                error "uso habilitado: ping torre.local | ping -c 3 torre.local"; return 0
            fi
            [[ "${ESTADO[RENOVO_DIRECCION]:-0}" == 1 ]] || { error "terminal0 todavía no tiene una dirección IP."; return 0; }
            pausa=${JUEGO_PAUSA_PING:-1}; [[ "$pausa" =~ ^([0-9]+)(\.[0-9]+)?$ ]] || pausa=1
            decir "PING torre.local (10.17.42.53): 56 data bytes"
            command sleep "$pausa"; decir "64 bytes from 10.17.42.53: icmp_seq=1 ttl=42 time=1742 ms"; decir "LAS ESTATUAS SE ESTÁN MOVIENDO"
            command sleep "$pausa"; decir "64 bytes from 10.17.42.53: icmp_seq=2 ttl=41 time=1742 ms"; decir "TODOS LOS QUE CONOCÍAS YA NO ESTÁN"
            command sleep "$pausa"; decir "From 10.17.42.53 icmp_seq=3 Destination Host Unreachable"; decir "INALCANZABLE ES LA SALIDA"
            decir "--- torre.local ping statistics ---"; decir "3 packets transmitted, 2 received, 33% packet loss"
            ESTADO[COMPROBO_TORRE]=1
            ;;
        ssh)
            if (( $# != 1 )) || [[ "$1" != "operador@torre.local" ]]; then error "uso habilitado: ssh operador@torre.local"; return 0; fi
            [[ "${ESTADO[COMPROBO_TORRE]:-0}" == 1 ]] || { error "primero comprobá la conexión con torre.local."; return 0; }
            decir "The authenticity of host 'torre.local (10.17.42.53)' can't be established."
            decir "ED25519 key fingerprint is SHA256:MTc0MlRPUlJFX1BVRTI1MjY."
            printf 'Are you sure you want to continue connecting (yes/no)? '
            if ! IFS= read -r respuesta; then decir ""; return 0; fi
            decir ""
            [[ "$respuesta" == "yes" ]] || { decir "Host key verification failed."; return 0; }
            decir "Warning: Permanently added 'torre.local' to the list of known hosts."
            decir "Conexión establecida."
            decir "Si estás leyendo esto, la red todavía recuerda tu nombre."
            decir "La entrada está en Plaza San Martín. Buscá la garita de mantenimiento."
            decir "Recuperá el archivo que ya no puede leerse. No mires las estatuas."
            decir "Ellas se acercan cuando la latencia aumenta."
            decir "Connection to torre.local closed."
            ESTADO[CONECTO_SSH]=1
            ;;
        *) return 1 ;;
    esac
    return 0
}

capitulo_06_evaluar() {
    if [[ "${ESTADO[VIO_INTERFAZ]:-0}" == 1 && "${ESTADO[LIBERO_DIRECCION]:-0}" == 1 \
        && "${ESTADO[RENOVO_DIRECCION]:-0}" == 1 && "${ESTADO[COMPROBO_TORRE]:-0}" == 1 \
        && "${ESTADO[CONECTO_SSH]:-0}" == 1 ]]; then avanzar_nivel; fi
}

capitulo_06_cierre() {
    decir "Al cerrarse la conexión, todos los teléfonos de Florida comienzan a sonar simultáneamente."
    decir "Las puertas de la cabina se abren solas. A través de la niebla distinguís la entrada de Plaza San Martín y varias siluetas de piedra que antes no estaban allí."
}

capitulo_06_transicion() {
    printf '\n%s' "$C_OK"
    cat <<'ASCII'
       __________________                 .-17:42-.
      | CABINA DE RED    |               /        \
      | [ terminal0 ]    |==============|  TORRE   |
      |__________________|   )))  )))     \________/
             FLORIDA          PULSOS          RETIRO
ASCII
    printf '%s' "$C_RESET"
}
